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

* User actions

        /user/ - GET user information request. For registered users request cookies must contain ACCESS_TOKEN value. If token is undefined, response contain information about anonymous user
        /user/new - PUT request for user registration, JSON params {user: {login, password, first_name, last_name}}. Response contain access_token for created user
        /user/login - PUT request for user login, JSON params {user: {login, password}}. Response contain access_token for created user
        /user/login/check - PUT request for login available checking, JSON params {user: {login}}. Response code 200 for available login and 201 if login already existed
        /user/- POST request for user update, JSON params {user: {first_name, last_name, city, e.t.c.}}. Request cookies must contain ACCESS_TOKEN value. 
        /user/- DELETE request for marked user as deleted. Request cookies must contain ACCESS_TOKEN value. 