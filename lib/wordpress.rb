require 'wordpress/version'
require 'mechanize'

module Wordpress
  class AuthError < StandardError; end
  class PostError < StandardError; end
  class HostError < StandardError; end
  class TagsError < StandardError; end

  class Client
    DEFAULT_URL = 'http://wordpress.com/wp-login.php'
    LOGIN_FORM  = 'loginform'
    POST_FORM   = 'post'
    IS_ADMIN    = 'body.wp-admin'
    IS_LOGIN    = 'body.login'

    attr_reader   :login_url, :username, :password, :agent

    def initialize usr, pwd, login_url = DEFAULT_URL
    
      # should I 
      raise   AuthError, "You must provide a username and password" \
        if      usr.empty? || pwd.empty?

      raise   AuthError, "Login Url should end with wp-login.php" \
        unless  login_url =~ /\/wp-login[.]php$/

      @username  = usr
      @password  = pwd
      @login_url = login_url
      @agent     = Mechanize.new
    end

    def valid_login_page?
      !login_page.search("form[name=#{LOGIN_FORM}]").empty?
    end

    def valid_user?
      logged_into? dashboard_page
    end

    def blog_url
      dashboard_page.at("#{IS_ADMIN} #wphead h1 a")['href'] rescue nil
    end

    def post title, body, tags=nil
      raise PostError, "A post requires a title or body."                       if  title.empty? && body.empty?
      post_form      = dashboard_page.form(POST_FORM)
      raise HostError, "Missing QuickPress on dashboard page or bad account."   unless  post_form
      tags           = tags.join(", ") if tags
      post_form      = build_post(post_form, title, body, tags)
      post_response    @agent.submit(post_form, post_form.buttons.last), title
    end

  private

    def login_page
      @agent.get @login_url
    end

    def dashboard_page
      page             = login_page
      login_form       = page.form(LOGIN_FORM)
      if login_form
        login_form.log = @username
        login_form.pwd = @password
        page           = @agent.submit login_form
      end
      page
    end

    def logged_into? page
      !page.search(IS_ADMIN).empty?
    end

    def build_post form, title, body, tags
      form.post_title = title
      form.content    = body
      form.tags_input = tags
      form
    end

    def post_response page, title
      links = page.search("div.message p a")
      if links.first && links.last
        url = links.first['href'] ? links.first['href'].gsub("?preview=1", "")  : nil
        pid = links.last['href']  ? links.last['href'].sub(/.*post=(\d*)/,'\1') : nil
        if pid && url
          return {"rsp" => {"post" => {"title" => "#{title}", "url" => "#{url}", "id" => "#{pid}"}, "stat" => "ok" }}
        end
      end
      {"rsp" => {"err" => {"msg" => "Post was unsuccessful.", "title" => "#{title}"}, "stat" => "fail"}}
    end
  end
end