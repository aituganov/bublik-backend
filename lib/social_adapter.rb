module SocialAdapter

	@@offset = AppSettings.offset_default
	@@limit = AppSettings.limit_preview

	def get_followed(klass, follower, limit, offset)
		limit ||= @@limit
		offset ||= @@offset
		klass.where(:id => Follow.select(:followable_id).
						where(:followable_type => klass.table_name.classify).
						where(:follower_type => follower.class.to_s).
						where(:follower_id => follower.id).limit(limit).offset(offset))
	end

	def get_followers(klass, followable, limit, offset)
		limit ||= @@limit
		offset ||= @@offset
		klass.where(:id => Follow.select(:follower_id).
						where(:follower_type => klass.table_name.classify).
						where(:followable_type => followable.class.to_s).
						where(:followable_id => followable.id).limit(limit).offset(offset))
	end
end