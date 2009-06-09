require 'rubygems'
require 'mechanize'

module Wordpress

  VERSION = '0.1.5'

  class AuthError < StandardError; end
  class PostError < StandardError; end
  class HostError < StandardError; end
  class TagsError < StandardError; end

  class Post

    DEFAULT_URL = 'http://wordpress.com/wp-login.php'
    LOGIN_FORM  = 'loginform'
    POST_FORM   = 'post'
    IS_ADMIN    = 'body.wp-admin'
    IS_LOGIN    = 'body.login'

    attr_accessor :title, :body
    attr_reader   :login_url, :username, :password, :tags, :post_url, :agent

    def initialize usr, pwd, login_url = DEFAULT_URL
      raise   AuthError, "Blank Username or Password or not a string." \
        unless  usr.is_a?(String) && pwd.is_a?(String) && !usr.empty? && !pwd.empty?

      raise   AuthError, "Url should end with wp-login.php" \
        unless  login_url =~ /\/wp-login[.]php$/

      @username  = usr
      @password  = pwd
      @login_url = login_url
      @agent     = WWW::Mechanize.new
      @post_url  = @tags = @title = @body = nil
    end

    def tags= ary
      raise TagsError, 'Tags must added using an array' unless ary.is_a?(Array)
      @tags = ary.join(", ")
    end

    def valid_login_page?
      !login_page.search("form[name=#{LOGIN_FORM}]").empty?
    end

    def valid_user?
      logged_into? dashboard_page
    end

    def blog_url
      dashboard_page.search("#{IS_ADMIN} #wphead h1 a").first['href'] rescue nil
    end

    def submit
      raise PostError, "A post requires a title or body."                       unless @title || @body
      post_form      = dashboard_page.form(POST_FORM)
      raise HostError, "Missing QuickPress on dashboard page or bad account."   unless post_form
      post_form      = build_post(post_form)
      post_response    @agent.submit(post_form, post_form.buttons.last)
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

    def build_post form
      form.post_title = @title
      form.content    = @body
      form.tags_input = @tags
      form
    end

    def post_response page
      links = page.search("div.message p a")
      if links.first && links.last
        url = links.first['href'] ? links.first['href'].gsub("?preview=1", "")  : nil
        pid = links.last['href']  ? links.last['href'].sub(/.*post=(\d*)/,'\1') : nil
        if pid && url
          return { "rsp" => { "post" => { "title" => "#{@title}", "url" => "#{url}", "id" => "#{pid}" }, "stat" => "ok" }}
        end
      end
      { "rsp" => { "err" => { "msg" => "Post was unsuccessful.", "title" => "#{@title}" }, "stat" => "fail" } }
    end
  end
end