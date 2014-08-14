Bublik BackEnd REST API
=====================

request prefix: /api

---------

**supported requests:**

Get backend version:
---------
> - **/version** - GET current backend version

Get localization:
---------
> - **/version** - GET localization by header language

User actions:
---------
> - **/user/:id?company_limit=:limit** - GET user information request. For registered users request cookies must contain ACCESS_TOKEN value. If token is undefined, response contain information for anonymous user. Params: :id - user ID, :limit - limit for user companies count in response data
> - **/user/:id/created_company?company_limit=:limit&company_offset=:offset** - GET user created companies. For registered users request cookies must contain ACCESS_TOKEN value. Params: :id - see above, :limit - see above, :offset - user created companies offset
> - **/user/new** - PUT request for user registration, JSON params {login, password, first_name, last_name}. Response contain access_token for created user
> - **/user/login** - PUT request for user login, JSON params {login, password}. Response contain access_token for created user
> - **/user/login/check/:login** - GET request for login available checking where query string parameter :login - user login for check. Response code 200 for available login and 201 if login already existed
> - **/user/:id** - POST request for user update, JSON params {first_name, last_name, city, e.t.c.}. Request cookies must contain ACCESS_TOKEN value.
> - **/user/:id** - DELETE request for marked user as deleted. Request cookies must contain ACCESS_TOKEN value.
> - **/user/:id/interests** - PUT request for interests create, JSON params {interests: ['first', 'second']}. Request cookies must contain ACCESS_TOKEN value.
> - **/user/:id/interests** - DELETE request for interests delete, JSON params {interests: ['first', 'second']}. Request cookies must contain ACCESS_TOKEN value.
> - **/user/:id/avatars** - GET request for all user avatars, rq param id - user id, avatars owner.
> - **/user/:id/avatar** - POST request for create new avatar for user, JSON params {id: user id, data: base 64 image data, content_type: image content type, crop_x: x coord for crop (>=0), crop_y: y coord for crop (>=0), crop_l: cropped square side length (>=10)}.
> - **/user/:id/avatar/current/:avatar_id** - POST request for set avatar as current, rq params id - user id, avatar_id - avatar id.
> - **/user/:id/avatar/:avatar_id** - DELETE request for delete avatar, rq params id - user id, avatar_id - avatar id.

Get user menu:
---------
> - **/menu** - GET user menu. Request cookies must contain ACCESS_TOKEN value.

Get company info:
---------
> - **/company/:id** - GET company information request.
> - **/company/new** - PUT request for company registration, JSON params {title, slogan, description}. Response contain created company id. Company owner setted by cookies access token
> - **/company/:id** - POST request for company update, JSON params {title, slogan, description, tags}. Tags structure: tags: [tag_id, ...] Request cookies must contain owner ACCESS_TOKEN value.
> - **/company/:id** - DELETE request which marking company as deleted. Request cookies must contain owner ACCESS_TOKEN value.
> - **/company/:id/tags** - PUT request for tags create, JSON params {tags: ['first', 'second']}. Request cookies must contain ACCESS_TOKEN value.
> - **/company/:id/tags** - DELETE request for tags delete, JSON params {interests: ['first', 'second']}. Request cookies must contain ACCESS_TOKEN value.
> - **/company/:id/logotypes** - GET request for all company logotypes, rq param id - company id.
> - **/company/:id/logotype** - POST request for create new logo for company, JSON params {id: company id, data: base 64 image data, content_type: image content type, crop_x: x coord for crop (>=0), crop_y: y coord for crop (>=0), crop_l: cropped square side length (>=10)}.
> - **/company/:id/logotype/current/:logo_id** - POST request for set logo as current, rq params id - company id, logo_id - logotype id.
> - **/company/:id/logotype/:logo_id** - DELETE request for delete logo, rq params id - company id, logo_id - logotype id.


Get widget data:
---------
> - **/widget/:name?level=:level&limit=:limit&offset=:offset** - get widget data, where :name - widget name

Tags:
---------
> - **/search/tag/:name?limit=:limit** - GET request for finding tag where :name - tag name, :limit - find limit. Request payload: :exculde - array of excluded tags