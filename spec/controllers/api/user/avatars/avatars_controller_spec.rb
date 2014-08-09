require 'spec_helper'

describe Api::User::Avatars::AvatarsController do
	context 'actions with user avatars' do
		include CarrierWave::Test::Matchers
		before :each do
			@correct_user = FactoryGirl.create(:user)
			@correct_user.should be_valid
			@id_structure = {id: @correct_user.id}
			@id_wrong_structure = {id: @correct_user.id - 1}
			request.cookies[:ACCESS_TOKEN] = @correct_user.access_token

			@new_user = FactoryGirl.create(:user_second)
			@new_user.should be_valid
			@id_new_user_structure = {id: @new_user.id}

			@image_path = "#{Rails.root}/spec/fixtures/images/test.jpg"
			file = File.open(@image_path, 'rb')
			@file_content = file.read
			@data = Base64.encode64(@file_content)
			file.close
		end

		context 'create' do
			it 'should 400 for avatar illegal data' do
				post :create, {id: @correct_user.id, illegal_data: ''}
				response.status.should eq 400
			end

			it 'should 400 for particial user avatar data' do
				post :create, {id: @correct_user.id, data: @file_content}
				response.status.should eq 400

				post :create, {id: @correct_user.id, data: @file_content, content_type: 'js'}
				response.status.should eq 400

				post :create, {id: @correct_user.id, data: @file_content, content_type: 'js', crop_x: 0}
				response.status.should eq 400

				post :create, {id: @correct_user.id, data: @file_content, content_type: 'js', crop_x: 0, crop_y: 0}
				response.status.should eq 400
			end

			it 'should 400 for illegal avatar content type' do
				post :create, {id: @correct_user.id, data: @file_content, content_type: 'js', crop_x: 0, crop_y: 0, crop_l: 0}
				response.status.should eq 400
			end

			it 'should 200 & coorect urls for legal user avatar data' do
				post :create, {id: @correct_user.id, data: @data, content_type: 'image/jpeg', crop_x: 10, crop_y: 10, crop_l: 10 }
				response.status.should eq 200
				@correct_user.get_current_image.file.read.should eq @file_content
				rs_avatar_data = JSON.parse(response.body)['data']['avatar']
				rs_avatar_data.should_not be_nil
				rs_avatar_data['id'].should eq @correct_user.get_current_image.id
				rs_avatar_data['current'].should be_true
				rs_avatar_data['preview_url'].should eq @correct_user.get_current_image.file.preview.url
				rs_avatar_data['fullsize_url'].should eq @correct_user.get_current_image.file.url
			end

			it 'should 403 & for not owner' do
				cookies['ACCESS_TOKEN'] = @new_user.access_token
				post :create, {id: @correct_user.id, data: @data, content_type: 'image/jpeg', crop_x: 10, crop_y: 10, crop_l: 10 }
				response.status.should eq 403
				@correct_user.get_current_image.should be_nil
			end

			it 'should 403 & for anonymous' do
				cookies['ACCESS_TOKEN'] = ''
				post :create, {id: @correct_user.id, data: @data, content_type: 'image/jpeg', crop_x: 10, crop_y: 10, crop_l: 10 }
				response.status.should eq 403
				@correct_user.get_current_image.should be_nil
			end

			it 'should 200 & correct preview size' do
				post :create, {id: @correct_user.id, data: @data, content_type: 'image/jpeg', crop_x: 10, crop_y: 10, crop_l: 10 }
				response.status.should eq 200
				rs_avatar_data = JSON.parse(response.body)['data']['avatar']
				rs_avatar_data.should_not be_nil
				img = Magick::Image.read( "#{AppSettings.images.dir}#{rs_avatar_data['preview_url']}" ).first
				img.columns.should eq AppSettings.images.preview_size
				img.rows.should eq AppSettings.images.preview_size
			end

			it 'should 200 & correct current' do
				post :create, {id: @correct_user.id, data: @data, content_type: 'image/jpeg', crop_x: 10, crop_y: 10, crop_l: 10 }
				response.status.should eq 200
				@current_first = @correct_user.get_current_image
				rs_avatar_data = JSON.parse(response.body)['data']['avatar']
				rs_avatar_data['id'].should eq @current_first.id

				post :create, {id: @correct_user.id, data: @data, content_type: 'image/jpeg', crop_x: 10, crop_y: 10, crop_l: 10 }
				response.status.should eq 200
				@current_second = @correct_user.get_current_image
				rs_avatar_data = JSON.parse(response.body)['data']['avatar']
				rs_avatar_data['id'].should eq @current_second.id

				@current_first.reload
				@current_first.current.should_not be_true
				@current_first.should_not eq @current_second
			end
		end

		context 'read update delete' do
			before do
				@ids = []
				3.times do
					post :create, {id: @correct_user.id, data: @data, content_type: 'image/jpeg', crop_x: 10, crop_y: 10, crop_l: 10 }
					response.status.should eq 200
					@ids.push(JSON.parse(response.body)['data']['avatar']['id'].to_i)
				end
				@current = @correct_user.get_current_image #last image is current
			end

			it 'get all should 404 for not existed user' do
				get :index, @id_wrong_structure
				response.status.should eq 404
			end

			it 'get all should 200 & correct data' do
				get :index, @id_structure
				response.status.should eq 200
				rs = JSON.parse(response.body)['data']['avatars']
				rs.should have(3).items
				rs.each do |a|
					i = Image.find(a['id'].to_i)
					a['current'].should eq i.current
					a['fullsize_url'].should eq i.file.url
					a['preview_url'].should eq i.file.preview.url
					if @current == i
						@current.should eq i;
						a['current'].should be_true
					end
				end
			end

			it 'get all should 200 & correct data for not owner' do
				cookies['ACCESS_TOKEN'] = @new_user.access_token
				get :index, @id_structure
				response.status.should eq 200
				rs = JSON.parse(response.body)['data']['avatars']
				rs.should have(3).items
			end

			it 'get all should 200 & correct data for anonymous' do
				cookies['ACCESS_TOKEN'] = ''
				get :index, @id_structure
				response.status.should eq 200
				rs = JSON.parse(response.body)['data']['avatars']
				rs.should have(3).items
			end

			it 'set current should 404 for not existed user' do
				cookies['ACCESS_TOKEN'] = @id_structure
				get :set_current, @id_wrong_structure.merge({avatar_id: (@ids[0] - 1)})
				response.status.should eq 404
			end

			it 'set current should 404 for not existed avatar' do
				cookies['ACCESS_TOKEN'] = @id_structure
				get :set_current, @id_structure.merge({avatar_id: (@ids[0] - 1)})
				response.status.should eq 404
			end

			it 'set current should 403 for not owner' do
				cookies['ACCESS_TOKEN'] = @new_user.access_token
				get :set_current, @id_structure.merge({avatar_id: @ids[0]})
				response.status.should eq 403
			end

			it 'set current should 200 for correct params' do
				@ids.each do |id|
					get :set_current, @id_structure.merge({avatar_id: id})
					response.status.should eq 200

					c = @correct_user.get_current_image
					rs = JSON.parse(response.body)['data']['avatar']
					rs['id'].should eq c.id
					rs['current'].should be_true
					c.should eq Image.where(imageable_id: @correct_user.id, current: true).take
				end
			end

			it 'set double current should 200' do
				get :set_current, @id_structure.merge({avatar_id: @current.id})
				response.status.should eq 200

				c = @correct_user.get_current_image
				rs = JSON.parse(response.body)['data']['avatar']
				rs['id'].should eq c.id
				rs['current'].should be_true
				c.should eq Image.where(imageable_id: @correct_user.id, current: true).take
			end

			it 'delete should 404 for not existed user' do
				cookies['ACCESS_TOKEN'] = @id_structure
				delete :delete, @id_wrong_structure.merge({avatar_id: (@ids[0] - 1)})
				response.status.should eq 404
			end

			it 'delete should 404 for not existed avatar' do
				cookies['ACCESS_TOKEN'] = @id_structure
				delete :delete, @id_structure.merge({avatar_id: (@ids[0] - 1)})
				response.status.should eq 404
			end

			it 'delete should 403 for not owner' do
				cookies['ACCESS_TOKEN'] = @new_user.access_token
				delete :delete, @id_structure.merge({avatar_id: @ids[0]})
				response.status.should eq 403
			end

			it 'delete should 200 for correct params' do
				@ids.each do |id|
					fullsize_url = Image.find(id).file.url
					preview_url = Image.find(id).file.preview.url

					delete :delete, @id_structure.merge({avatar_id: id})
					response.status.should eq 200
					expect { Image.find id }.to raise_error(ActiveRecord::RecordNotFound)

					File.exist?("#{AppSettings.images.dir}#{fullsize_url}").should be_false
					File.exist?("#{AppSettings.images.dir}#{preview_url}").should be_false
				end
				Image.where(imageable_id: @correct_user.id).take.should be_nil
			end
		end
	end
end