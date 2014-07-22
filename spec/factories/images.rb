# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :image do |i|
		i.preview_url  '/preview/url'
		i.fullsize_url '/fullsize/url'
  end
end
