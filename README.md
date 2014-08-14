Bublik BackEnd REST API
=====================

*request prefix: /api*

---------

**supported requests:**

Get backend version:
---------
> - **/version** - **GET** current backend version.

Get localization:
---------
> - **/version** - **GET** localization by header language.

User actions:
---------
*actions prefix: /user*

> - **/:id?company_limit=:limit** - **GET** user information request. For registered users request cookies must contain ACCESS_TOKEN value. If token is undefined, response contain information for anonymous user. **Params: :id** - *user ID*, **:limit** - *limit for user companies count in response data.*
> - **/:id/created_company?company_limit=:limit&company_offset=:offset** - **GET** user created companies. For registered users request cookies must contain ACCESS_TOKEN value. **Params: :id** - *see above,* **:limit** - *see above*, **:offset** - *user created companies offset.*
> - **/new** - **PUT** request for user registration. **Request payload: login, password, first_name, last_name.** Response contain access_token for created user
> - **/login** - **PUT** request for user login. **Request payload: login, password.** Response contain access_token for created user
> - **/login/check/:login** - **GET** request for login available checking. **Params: :login** - *user login for check.* Response code 200 for available login and 201 if login already existed
> - **/:id** - **POST** request for user update. **Request payload: first_name, last_name, city, e.t.c..** Request cookies must contain ACCESS_TOKEN value.
> - **/:id** - **DELETE** request for marked user as deleted. Request cookies must contain ACCESS_TOKEN value.
> - **/:id/interests** - **PUT** request for interests create. **Request payload: interests: ['first', 'second'].** Request cookies must contain ACCESS_TOKEN value.
> - **/:id/interests** - **DELETE** request for interests delete. **Request payload: interests: ['first', 'second'].** Request cookies must contain ACCESS_TOKEN value.
> - **/:id/avatars** - **GET** request for all user avatars. **Params: :id** - *user id, avatars owner.*
> - **/:id/avatar** - **POST** request for create new avatar for user. **Request payload: id** - *user id,* **data** - *base 64 image data,* **content_type** - *image content type,* **crop_x** - *x coord for crop (>=0),* **crop_y** - *y coord for crop (>=0),* **crop_l** - *cropped square side length (>=10)*.
> - **/:id/avatar/current/:avatar_id** - **POST** request for set avatar as current. **Params: :id** - *user id,* *:*avatar_id **- *avatar id*.
> - **/:id/avatar/:avatar_id** - **DELETE** request for delete avatar. **Params: :id** - *user id,* **:avatar_id **- *avatar id*.

Get user menu:
---------
> - **/menu** - **GET** user menu. Request cookies must contain ACCESS_TOKEN value.

Get company info:
---------
*actions prefix: /company*

> - **/:id** - **GET** company information request. **Params: :id** - company id**.
> - **/new** - **PUT** request for company registration. **Request payload: title, slogan, description.** Response contain created company id. Company owner setted by cookies access token
> - **/:id** - **POST** request for company update. **Params: :id** - company id**. **Request payload: title, slogan, description, tags.** Request cookies must contain owner ACCESS_TOKEN value.
> - **/:id** - **DELETE** request which marking company as deleted. **Params: :id** - company id**. Request cookies must contain owner ACCESS_TOKEN value.
> - **/:id/tags** - **PUT** request for tags create. **Request payload: tags: ['first', 'second'].** Request cookies must contain ACCESS_TOKEN value.
> - **/:id/tags** - **DELETE** request for tags delete. **Request payload: tags: ['first', 'second'].** Request cookies must contain ACCESS_TOKEN value.
> - **/:id/logotypes** - **GET** request for all company logotypes. **Params: :id** - company id**.
> - **/:id/logotype** - **POST** request for create new logo for company. **Request payload: id** - *company id,* **data** - *base 64 image data,* **content_type** - *image content type,* **crop_x** - *x coord for crop (>=0),* **crop_y** - *y coord for crop (>=0),* **crop_l** - *cropped square side length (>=10)*.
> - **/:id/logotype/current/:logo_id** - **POST** request for set logo as current. **Params: :id** - *company id*, **:logo_id** - *logotype id*.
> - **/:id/logotype/:logo_id** - **DELETE** request for delete logo. **Params: :id** - *company id*, **:logo_id** - *logotype id*.

Get widget data:
---------
> - **/widget/:name?level=:level&limit=:limit&offset=:offset** - **GET** widget data. **Params: :name** - *widget name.*

Search:
---------
*actions prefix: /search*

> - **/tag/:name?limit=:limit** - *POST* request for finding tag. **Params: :name** - *tag name,* **:limit** - *find limit.* **Request payload: :exculde** - *array of excluded tags*.