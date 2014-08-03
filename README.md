# Bublik BackEnd REST API #

request prefix: /api

supported requests:

* Get backend version

        /version - GET current backend version

* Get localization

        /version - GET localization by header language

* User actions

        /user/:id - GET user information request. For registered users request cookies must contain ACCESS_TOKEN value. If token is undefined, response contain information for anonymous user
        /user/:id/created_company - GET user created companies. For registered users request cookies must contain ACCESS_TOKEN value.
        /user/new - PUT request for user registration, JSON params {login, password, first_name, last_name}. Response contain access_token for created user
        /user/login - PUT request for user login, JSON params {login, password}. Response contain access_token for created user
        /user/login/check/:login - GET request for login available checking where query string parameter :login - user login for check. Response code 200 for available login and 201 if login already existed
        /user/:id - POST request for user update, JSON params {first_name, last_name, city, e.t.c.}. Request cookies must contain ACCESS_TOKEN value.
        /user/:id - DELETE request for marked user as deleted. Request cookies must contain ACCESS_TOKEN value.
        /user/:id/interests - PUT request for interests create, JSON params {interests: ['first', 'second']}. Request cookies must contain ACCESS_TOKEN value.
        /user/:id/interests - DELETE request for interests delete, JSON params {interests: ['first', 'second']}. Request cookies must contain ACCESS_TOKEN value.

* Get user menu

        /menu - GET user menu. Request cookies must contain ACCESS_TOKEN value.

* Get company info

        /company/:id - GET company information request.
        /company/new - PUT request for company registration, JSON params {title, slogan, description}. Response contain created company id. Company owner setted by cookies access token
        /company/:id - POST request for company update, JSON params {title, slogan, description, tags}. Tags structure: tags: [tag_id, ...] Request cookies must contain owner ACCESS_TOKEN value.
        /company/:id - DELETE request which marking company as deleted. Request cookies must contain owner ACCESS_TOKEN value.
        /company/:id/tags - PUT request for tags create, JSON params {tags: ['first', 'second']}. Request cookies must contain ACCESS_TOKEN value.
        /company/:id/tags - DELETE request for tags delete, JSON params {interests: ['first', 'second']}. Request cookies must contain ACCESS_TOKEN value.


* Get widget data

        /widget/:name?level=:level&limit=:limit&offset=:offset - get widget data, where :name - widget name

* Tags

        /tag/:name?limit=:limit - GET request for finding tag where :name - tag name, :limit - find limit