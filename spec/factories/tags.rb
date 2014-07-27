# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tag_wrong, class: 'Tag' do
  end

  factory :tag_first, class: 'Tag' do |t|
	  t.name 'First tag'
  end

  factory :tag_second, class: 'Tag' do |t|
	  t.name 'Second tag'
  end

  factory :tag_third, class: 'Tag' do |t|
	  t.name 'Third tag'
  end
end
