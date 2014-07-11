module UserHelper

	def get_fake_anonymous_data
		{
			anonymous: true,
			menuItems: get_fake_menu,
			widgets: [topCompanies: {preview: get_fake_company, hasMore: true}],
			canSearching: true
		}
	end

	def get_fake_menu
		['register', 'login', 'aboutUs']
	end

	def get_fake_company
		[{
			id: 1,
			title: 'McDonald’s',
			description: 'крупнейшая в мире сеть ресторанов быстрого питания',
			rating: 3.89,
			logoUrl: 'http://bublik.galaxias.co/images/fake_companies/mc.jpg'
		 },
		 {
			id: 2,
			title: 'IKEA',
			description: 'Нидерландская компания, владелец одной из крупнейших в мире торговых сетей по продаже мебели и товаров для дома. ',
			rating: 4.5,
			logoUrl: 'http://bublik.galaxias.co/images/fake_companies/ikea.png'
		 },
		 {
			id: 3,
			title: 'Amazon',
			description: 'Американская компания, крупнейшая в мире по обороту среди продающих товары и услуги через Интернет и один из первых интернет-сервисов, ориентированных на продажу реальных товаров массового спроса',
			rating: 4.2,
			logoUrl: 'http://bublik.galaxias.co/images/fake_companies/amazon.jpg'
		 }
		]
	end

end
