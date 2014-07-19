module CompaniesHelper

	def get_fake_company(id)
		{
			id: id,
			city: 'Magnitogorsk',
			title: "Тарелка #{id}",
			rating: sprintf('%.2f', rand * 5).to_f,
			description: 'Служба доставки еды “Тарелка ” – это ваши любимые блюда и напитки в кратчайшие сроки у вас дома, в гостях, в офисе, на даче, и где угодно! В меню вы найдете ассортимент знакомых заведений города: CityBar, Печеная Картошка и CityFood.',
			fullLogoUrl: "http://bublik.galaxias.co/images/fake_companies/full/#{1 + rand(9)}.jpg",
		}
	end

end
