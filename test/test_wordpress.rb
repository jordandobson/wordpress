p $:

require "test/unit"
require_relative "../lib/wordpress"

require 'mocha/test_unit'

class Wordpress::Client
  public :login_page, :dashboard_page, :logged_into?, :build_post, :post_response
end

# Should Test The Following
# * build_post
# * dashboard_page
# * Post Response failure
# * Tags error without being an array
# * Body and tags are returned in response
# * Testing that username, password & login url respond to empty

class TestWordpress < Test::Unit::TestCase

  def setup
    @u = 'jordandobson'
    @p = 'password'

    @account                    = Wordpress::Client.new @u, @p
    @account_bad                = Wordpress::Client.new @u, 'x'
    @account_invalid_login_page = Wordpress::Client.new @u, @p, 'http://notapage.gd/wp-login.php'
    @account_hosted_account     = Wordpress::Client.new @u, @p, 'http://blog.getglue.net/wp-login.php'

    login_html   = '<html><body class="login"><form name="loginform"></form></body></html>'
    admin_html   = '<html><body class="wp-admin"><div id="wphead"><h1><a href="http://getglue.wordpress.com/" title="Visit Site">Get Glue</a></h1></div><form name="post"><input type="text" name="post_title"/><textarea name="content"></textarea><input type="text" name="tags_input"/><input type="submit" name="publish" /></form></body></html>'
    success_html = '<div class="updated"><p><a href="http://success.com/2009/">preview</a><a href="http://success.com/wp-admin/post.php?post=99">edit</a></p></div>'
    fail_html    = '<div class="message"><p></p></div>'

    @login_pg   = setup_mock_mechanize_pg login_html, @account.agent
    @admin_pg   = setup_mock_mechanize_pg admin_html, @account.agent
    @success_pg = setup_mock_mechanize_pg success_html, @account.agent
    @fail_pg    = setup_mock_mechanize_pg fail_html, @account_bad.agent
  end

  def setup_mock_mechanize_pg html, agent
    Mechanize::Page.new(nil, {'content-type' => 'text/html'}, html, 200, agent)
  end

  def test_sets_account_info_on_initialize
    actual       = Wordpress::Client.new @u, @p
    assert_equal   [@u, @p], [actual.username, actual.password]
  end

  def test_raises_if_username_is_blank
    assert_raise Wordpress::AuthError do
      Wordpress::Client.new "", @p
    end
  end

  def test_raises_if_password_is_blank
    assert_raise Wordpress::AuthError do
      Wordpress::Client.new @u, ""
    end
  end

  def test_login_url_uses_default_if_witheld
    assert_equal Wordpress::Client::DEFAULT_URL, @account.login_url
  end
  
  def test_users_url_does_not_raise
    assert_equal 'http://notapage.gd/wp-login.php', @account_invalid_login_page.login_url
  end

  def test_raises_on_bad_login_url
    assert_raise Wordpress::AuthError do
      Wordpress::Client.new @u, @p, 'http://bad.login/url.php'
    end
  end

  def test_login_page_is_valid
    actual = Wordpress::Client.new @u, @p
    actual.stubs(:login_page).returns(@login_pg)
    assert_equal true, actual.valid_login_page?
  end

  def test_login_page_is_invalid
    @account_invalid_login_page.stubs(:login_page).returns(@fail_pg)
    assert_equal false, @account_invalid_login_page.valid_login_page?
  end

  def test_is_a_valid_user
    @account.stubs(:dashboard_page).returns(@admin_pg)
    assert_equal true, @account.valid_user?
  end

  def test_is_an_invalid_user
    @account_bad.stubs(:dashboard_page).returns(@login_pg)
    assert_equal false, @account_bad.valid_user?
  end

  def test_is_a_valid_hosted_user
    @account_hosted_account.stubs(:dashboard_page).returns(@admin_pg)
    assert_equal true, @account_hosted_account.valid_user?
  end

  def test_private_logged_in_is_true
    assert_equal  true,  @account.logged_into?(@admin_pg)
  end

  def test_private_logged_in_is_false
    assert_equal  false, @account.logged_into?(@login_pg)
  end

  def test_returns_blog_url
    @account_hosted_account.stubs(:dashboard_page).returns(@admin_pg)
    assert_equal 'http://getglue.wordpress.com/', @account_hosted_account.blog_url
  end

  def test_returns_blog_url_bad
    @account_invalid_login_page.stubs(:dashboard_page).raises(SocketError)
    assert_nil @account_invalid_login_page.blog_url
  end

  def test_post_raises_without_title_or_body
    assert_raise Wordpress::PostError do
      @account.post("", "")
    end
  end

  def test_post_raises_without_post_form
    @account_bad.stubs(:dashboard_page).returns(@fail_pg)
    assert_raise Wordpress::HostError do
      @account_bad.post("My Title", "")
    end
  end

  def test_post_response_returns_good_response
    assert_equal "ok", @account.post_response(@success_pg, "")["rsp"]["stat"]
  end

  def test_post_returns_fail
    title          = "My Title"
    res            = @account.post_response(@fail_pg, title)
    assert_equal     "fail",                      res["rsp"]["stat"]
    assert_equal     "Post was unsuccessful.",    res["rsp"]["err"]["msg"]
    assert_equal     title,                       res["rsp"]["err"]["title"]
  end

  def test_post_returns_ok
    @account.stubs(:dashboard_page).returns(@admin_pg)
    @account.agent.stubs(:submit).returns(@success_pg)
    title          = "My Title"
    body           = "Body Text"
    actual         = @account.post(title, body)
    assert_equal     "ok",                        actual["rsp"]["stat"]
    assert_equal     title,                       actual["rsp"]["post"]["title"]
    assert_equal     "99",                        actual["rsp"]["post"]["id"]
    assert_equal     "http://success.com/2009/",  actual["rsp"]["post"]["url"]
  end

  def test_post_returns_ok_with_only_title
    @account.stubs(:dashboard_page).returns(@admin_pg)
    @account.agent.stubs(:submit).returns(@success_pg)
    title          = "My Title"
    actual         = @account.post(title, "")
    assert_equal     "ok",                        actual["rsp"]["stat"]
    assert_equal     title,                       actual["rsp"]["post"]["title"]
  end

  def test_post_returns_ok_with_only_body
    @account.stubs(:dashboard_page).returns(@admin_pg)
    @account.agent.stubs(:submit).returns(@success_pg)
    body           = "Body Text"
    actual         = @account.post("", body)
    assert_equal     "ok",                        actual["rsp"]["stat"]
    assert_equal     "",                          actual["rsp"]["post"]["title"]
  end
end