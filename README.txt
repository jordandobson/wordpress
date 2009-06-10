= wordpress

* http://github.com/jordandobson/wordpress/tree/master

== DESCRIPTION:

The Wordpress gem provides posting to a Wordpress.com blog or a self hosted wordpress by providing your username, password, login url(if you host your blog) and your blog content. With this gem, you have access to add a text entry on Wordpress blog by providing these options: title text, body text, and a tag array. You must include at least title text or body text with your post.

Posting images with posts, posting only images and pulling down your posts will be available very soon.

== FEATURES/PROBLEMS:

* Either Title or Body is optional
* Adding Images are not yet implemented
* Posting Only, Reading & Images are not yet included
* Check if a username and password are valid
* Check if a provided login_url is valid
* Get the users blog url
* This is very throughly tested

== SYNOPSIS:

1. Instantiate your post with your account info

    * Provide just the username and password as strings
    
        account = Wordpress::Client.new('username', 'password')
      
    * OR Provide the url of your login page if it's self hosted

        account = Wordpress::Client.new('username', 'password', 'http://blog.mysite.com/wp-login.php')

2. Validate the provided account info and request the users blog url homepage if needed

    * Check if the user is valid. Returns true or false
    
        account.valid_user?
      
    * Check if the specified login page is valid. Returns true or false
    
        account.valid_login_page?
      
    * Get the users blog page url. Returns nil if it can't be found.
    
        account.blog_url

3. Send your post to your Wordpress Blog

    * Set to a variable to work with the response
    
        response = account.post("My title", "Body Text", ["Glue", "Wordpress"])
        
        response = account.post("", "Body Text", ["Glue", "Wordpress"])
        
        response = account.post("My title", "")

        response = account.post("", "Body Text")

4. You get a success or error hash back

    * Your response should look something like this if successful
    
        response #=> { "rsp" => { "post" => { "title" => "My Title", "url" => "http://getglue.wordpress.com/2009/06/06/my-title/", "id" => "69" },  "stat" => "ok" } }
    
    * Your response would look like this if it failed
    
        response #=> { "rsp" => { "err" => { "msg" => "Post was unsuccessful.", "title" => "My Title" }, "stat" => "fail" } }
    

== REQUIREMENTS:

* mechanize, & Mocha (For Testing)

== INSTALL:

* sudo gem install wordpress

== LICENSE:

(The MIT License)

Copyright (c) 2009 Jordan Dobson

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
