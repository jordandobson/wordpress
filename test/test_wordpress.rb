require "test/unit"
require "wordpress"

######
# USED TO TEST PRIVATE METHODS
class Class
  def private_methods
    m = self.private_instance_methods
    self.class_eval { public( *m ) }
    yield
    self.class_eval { private( *m ) }
  end
end


class TestWordpress < Test::Unit::TestCase

  def setup
    @u = 'jordandobson'
    @p = 'password'

    @account                    = Wordpress::Client.new @u, @p
    @account_bad                = Wordpress::Client.new @u, 'x'
    @account_invalid_login_page = Wordpress::Client.new @u, @p, 'http://is.gd/wp-login.php'

    @admin_pg = Nokogiri::HTML( Nokogiri::HTML::Builder.new { html { body( :class => 'wp-admin') } }.to_html )
    @login_pg = Nokogiri::HTML( Nokogiri::HTML::Builder.new { html { body( :class => 'login'   ) } }.to_html )
    
    #make sure this is used twice
    @success_html = Nokogiri::HTML( Nokogiri::HTML::Builder.new { div.message { p_ {
        a( :href => 'http://success.com/2009/?preview=1' )
        a( :href => 'http://success.com/wp-admin/post.php?post=99' )
      } } }.to_html )

    #make sure this is used twice
    @fail_html  = Nokogiri::HTML( Nokogiri::HTML::Builder.new { div.message { p_ } }.to_html )
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

  def test_raises_if_password_is_not_srting
    assert_raise Wordpress::AuthError do
      Wordpress::Client.new @u, 00
    end
  end

  def test_raises_if_username_is_not_srting
    assert_raise Wordpress::AuthError do
      Wordpress::Client.new 00, @p
    end
  end

  def test_login_url_uses_default_if_witheld
    assert_equal Wordpress::Client::DEFAULT_URL, @account.login_url
  end

  def test_uses_url_does_not_raise
    assert_equal 'http://is.gd/wp-login.php', @account_invalid_login_page.login_url
  end
  
  def test_raises_on_bad_login_url
    assert_raise Wordpress::AuthError do
      Wordpress::Client.new @u, @p, 'http://bad.login/url.php'
    end
  end
  
  def test_login_page_is_valid
    actual = Wordpress::Client.new @u, @p
    assert_equal true, actual.valid_login_page?
  end

  def test_login_page_is_invalid
    assert_equal false, @account_invalid_login_page.valid_login_page?
  end
  
  def test_is_a_valid_user
    assert_equal    true, @account.valid_user?
  end
  
  def test_is_an_invalid_user
    assert_equal    false, @account_bad.valid_user?
  end
  
  def test_is_a_valid_hosted_user
    account       = Wordpress::Client.new('nonbreakablespace', 'Password1', 'http://blog.nonbreakablespace.com/wp-login.php')
    assert_equal    true, account.valid_user?
  end

  def test_returns_blog_url
    expected      = 'http://blog.nonbreakablespace.com/'
    account       = Wordpress::Client.new('nonbreakablespace', 'Password1', "#{expected}wp-login.php")
    assert_equal    expected, account.blog_url
    # Need to stub dashboard_page
  end
 
  def test_returns_blog_url_bad
    account       = Wordpress::Client.new(@u, @p, 'http://is.gd/wp-login.php')
    assert_nil    account.blog_url
  end
  
  def test_private_logged_in_is_true
    Wordpress::Client.private_methods { assert_equal true,  @account.logged_into?(@admin_pg) }
  end

  def test_private_logged_in_is_false
    Wordpress::Client.private_methods { assert_equal false, @account.logged_into?(@login_pg) }
  end
  
  def test_add_post_raises_without_title_or_body
    assert_raise Wordpress::PostError do
      @account.add_post
    end
  end
  
  def test_add_post_raises_without_post_form
    assert_raise Wordpress::PostError do
      @account_bad.add_post
    end  
  end
  
  def test_post_response_returns_good_response
    Wordpress::Client.private_methods {
      assert_equal "ok", @account.post_response(@success_html)["rsp"]["stat"]
    }
  end
  
  def test_add_post_returns_ok
    #stub with success response
    @account.title = Time.now
    @account.body  = "updated next"
    actual         = @account.add_post
    assert_equal   "ok", actual["rsp"]["stat"]
  end
  
  def test_add_post_returns_fail
    Wordpress::Client.private_methods { 
      assert_equal "fail",  @account.post_response(@fail_html)["rsp"]["stat"]
    }
  end

end
