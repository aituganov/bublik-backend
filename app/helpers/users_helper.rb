module UsersHelper

	def get_fake_anonymous_data
		{
			anonymous: true,
			menuItems: get_fake_menu,
			widgets: ['topCompanies'],
			canSearching: true
		}
	end

	def get_fake_menu
		['register', 'login', 'aboutUs']
	end

	def get_fake_companies
		[{
			id: 1,
			title: 'McDonald’s',
			description: 'крупнейшая в мире сеть ресторанов быстрого питания',
			rating: 3.89,
			logoUrl: 'http://bublik.galaxias.co/images/fake_companies/preview/1.jpg'
		 },
		 {
			id: 2,
			title: 'IKEA',
			description: 'Нидерландская компания, владелец одной из крупнейших в мире торговых сетей по продаже мебели и товаров для дома. ',
			rating: 4.5,
			logoUrl: 'http://bublik.galaxias.co/images/fake_companies/preview/2.png'
		 },
		 {
			id: 3,
			title: 'Amazon',
			description: 'Американская компания, крупнейшая в мире по обороту среди продающих товары и услуги через Интернет и один из первых интернет-сервисов, ориентированных на продажу реальных товаров массового спроса',
			rating: 4.2,
			logoUrl: 'http://bublik.galaxias.co/images/fake_companies/preview/3.jpg'
		 }
		]
	end

end
