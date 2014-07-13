module WidgetsHelper
	include CompaniesHelper

	def get_fake_widget(widget_id, level, offset, limit)
		companies = []
		limit.times { |t|
			companies.push(get_fake_company(offset + t + 1))
		}
		{
			id: widget_id,
			level: level,
			items: companies,
			itemsCnt: limit
		}

	end

end
