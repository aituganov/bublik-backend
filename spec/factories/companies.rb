# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :company do |c|
		c.title 'Company'
		c.slogan 'Cool slogan'
		c.description 'Very very long description'
		c.rating 4.89
	end

	factory :company_second, class: 'Company' do |c|
		c.title 'Company second'
		c.slogan 'Cool slogan second'
		c.description 'Very very long description second'
		c.rating 3.0
	end
end
