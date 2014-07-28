# Bublik BackEnd REST API #

request prefix: /api

supported requests:

* Get backend version

        /version - GET current backend version

* Get localization

        /version - GET localization by header language

* Get company info

        /company/:id - GET company information request.
        /company/new - PUT request for company registration, JSON params {title, slogan, description}. Response contain created company id. Company owner setted by cookies access token
        /company/:id - POST request for company update, JSON params {title, slogan, description, tags}. Tags structure: tags: [tag_id, ...] Request cookies must contain owner ACCESS_TOKEN value.
        /company/:id - DELETE request which marking company as deleted. Request cookies must contain owner ACCESS_TOKEN value.


* Get widget data

        /widget/:name?level=:level&limit=:limit&offset=:offset - get widget data, where :name - widget name

* User actions

        /user/ - GET user information request. For registered users request cookies must contain ACCESS_TOKEN value. If token is undefined, response contain information about anonymous user
        /user/new - PUT request for user registration, JSON params {user: {login, password, first_name, last_name}}. Response contain access_token for created user
        /user/login - PUT request for user login, JSON params {user: {login, password}}. Response contain access_token for created user
        /user/login/check/:login - GET request for login available checking where query string parameter :login - user login for check. Response code 200 for available login and 201 if login already existed
        /user/ - POST request for user update, JSON params {user: {first_name, last_name, city, e.t.c.}}. Interests structure: interests:[tag_id, ...] Request cookies must contain ACCESS_TOKEN value.
        /user/ - DELETE request for marked user as deleted. Request cookies must contain ACCESS_TOKEN value.

* Tags
        /tag/new/:name - PUT request for tag creation where :name - tag name
        /tag/:name?limit=:limit - GET request for finding tag where :name - tag name, :limit - find limit