# Bublik BackEnd API #

request prefix: /api

supported requests:

* Get backend version

	/version

* Get localization

	/localization

* Get anonymous user info

	/user

* Get company info

	/company/:id
	where :id - identificator of requested company

* Get widget data

	/widget/:name?level=:level&limit=:limit&offset=:offset
	where :name - widget name 