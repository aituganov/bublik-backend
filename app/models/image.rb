include AppUtils

class Image < ActiveRecord::Base
	belongs_to :imageable, polymorphic: true
	mount_uploader :file, ImageUploader

	before_create :import_image_from_rq, if: :need_image_import?
	after_create :crop_proccess, if: :cropping?

	validates :data, :content_type, presence: true
	validates_integrity_of :file
	validates_processing_of :file

	attr_accessor :data, :content_type, :crop_x, :crop_y, :crop_l

	@@CACHE_KEY = '_current_avatar';

	def self.get_current(imageable)
		cache_key = "#{imageable.id}#{@@CACHE_KEY}"
		cached = from_cache cache_key
		image = Image.where(cached.nil? ? {imageable_id: imageable.id, current: true} : {id: cached}).take
		if image.nil? && !cached.nil?
			cache_val = nil
		elsif !image.nil? && image.id != cached
			cache_val = image.id
		end
		to_cache cache_key, cache_val
		image
	end

	def set_current
		self.current = true;
		res = self.save
		to_cache("#{self.imageable_id}#{@@CACHE_KEY}", self.id) if res
		res
	end

	def set_uncurrent
		self.current = false;
		res = self.save
		to_cache("#{self.imageable_id}#{@@CACHE_KEY}", nil) if res
		res
	end

	def build_response
		{id: self.id, current: true, preview_url: self.file.preview.url, fullsize_url: self.file.url}
	end

	private

	def need_image_import?
		!data.blank?
	end

	def cropping?
		!crop_x.blank? && !crop_y.blank? && !crop_l.blank? && !self.file.url.nil?
	end

	def import_image_from_rq
		begin
			logger.info "Create image with content_type #{content_type}"
			extension = Rack::Mime::MIME_TYPES.invert[content_type]  #=> ".jpg"
			if extension.nil?
				raise_exception ArgumentError, 'image: invalid content type'
			end
			logger.info "File extension #{extension}"

			prepared_data = data.index('base64,').nil? ? data :
				data[(data.index('base64,') + 7)..-1] # cut content_type
			tmpfile = Tempfile.new([Time.now.to_time.to_i, extension], Rails.root.join('tmp'), encoding: 'BINARY')
			tmpfile.write(Base64.decode64(prepared_data))
			file = CarrierWave::SanitizedFile.new(tmpfile)
			file.content_type = content_type

			self.file = file
		ensure
			unless tmpfile.nil?
				tmpfile.close!
				tmpfile.unlink
			end
		end
	end

	def crop_proccess
		raise_exception ArgumentError, 'crop: invalid parameters value' if crop_x.to_i < 0 || crop_y.to_i < 0 || crop_l.to_i < 10
		self.file.preview.manualcrop(crop_x, crop_y, crop_l)
		self.file.recreate_versions!

		self.save!
	end

end
