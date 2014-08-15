# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :image do |i|
		i.image_data Base64.encode64(File.open("#{Rails.root}/spec/fixtures/images/test.jpg", 'rb').read)
		i.content_type 'image/jpeg'
		i.crop_x 1
		i.crop_y 1
		i.crop_l 10
	end

	factory :image_wrong, class: 'Image' do |i|
		i.image_data ''
		i.content_type ''
		i.crop_x -1
		i.crop_y -1
		i.crop_l -1
	end

	factory :image_hash, class:Hash do |i|
		i.send('image_data', Base64.encode64(File.open("#{Rails.root}/spec/fixtures/images/test.jpg", 'rb').read))
		i.send('content_type', 'image/jpeg')
		i.send('crop_x', 1)
		i.send('crop_y', 1)
		i.send('crop_l', 10)

		initialize_with {attributes.stringify_keys}
	end
end
