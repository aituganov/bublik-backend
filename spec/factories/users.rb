# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :user, :class => 'User'  do |u|
		u.login      'test@email.ru'
		u.password   'test_password'
		u.first_name 'First_name'
		u.last_name  'Last_name'
	end

	factory :wrong_user, :class => 'User'  do |u|
		u.login      'wrong_login_format'
		u.password   'password'
		u.first_name 'First_name'
		u.last_name  'Last_name'
	end
end
