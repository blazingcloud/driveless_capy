require 'rubygems'
require "bundler/setup"
require 'capybara/rspec'
require 'capybara/dsl'
require 'selenium-webdriver'
require 'ruby-debug'
require 'capybara/firebug'

sauce_user = ENV["SAUCE_USERNAME"]
sauce_key = ENV["SAUCE_ACCESS_KEY"]

if sauce_user && sauce_key
  require 'sauce'
  require 'sauce/capybara'
  Sauce.config do |c|
    #c.browser_url = "http://my.drivelesschallenge.com"
    # If you use the above env vars you don't need these lines
    #c.username = sauce_user
    #c.access_key = sauce_key
    c.browsers = [
        #["Windows 2003", "firefox", "3.6."],
        #["Windows 2003", "googlechrome", ""],
        #["Windows 2003", "safari", "4."],
        #["Windows 2003", "opera", "11."],
        #["Windows 2003", "firefox", "3.6."],
        #["Windows 2003", "firefox", "3.6."],
        ["Windows 2008", "iexplore", "9."],
        #["Windows 2008", "firefox", "4."],
        #["Linux", "firefox", "3.6."]
    ]
  end
  # Only if using tunnel
    #c.application_host = "my.drivelesschallenge.com"
    #c.application_port = "80"

  Capybara.default_driver = :sauce
else
  Capybara.default_driver = :selenium #_with_firebug
end

Capybara.app_host = "my.drivelesschallenge.com"
Capybara.run_server = false

RSpec.configure do |config|
  config.include(Capybara)
end

describe "Drive Less Challenge" do
  class << self
    alias :she :it
    alias :he :it
    alias :they :it
    alias :we :it
    alias :you :it
  end

  def window_handles
    browser.window_handles
  end 

  def current_window
    browser.window_handle
  end

  def browser
    driver.browser
  end

  def driver
    Capybara.current_session.driver
  end

  describe "Login" do
    describe "When the user has not yet logged in to either the Web site or Facebook and goes to the front page" do
      before do
        visit 'http://my.drivelesschallenge.com/'
      end

      she "should be prompted to log in" do
        page.should have_content("Login")
        page.should have_content("Nickname")
        page.should have_content("Password")
      end

      describe "and she provides valid login information" do
        before do
          fill_in "Nickname", :with => 'Capybara'
          fill_in "Password", :with => 'caplin'
          click_button "Login"
        end

        she "should see her My Trips page" do
          current_path.should == "/account"
          page.find('div.navigation ol li.current').should have_content("My Trips")
        end
      end

      describe "and she clicks on te Facebook button" do
        before do
          #@app_window = current_window

          fb_connect = Capybara.current_session.driver.browser.find_element(:id, 'RES_ID_fb_login_image')
          fb_connect.click
        end

        she "should see a popup window to login with Facebook" do
          within_window("Login | Facebook") do
            page.should have_content("Log in to use your Facebook account with Drive Less Challenge.")
          end
        end 

        describe "and she enters her Facebook login information" do
          before do
            #handle = driver.find_window( "Login | Facebook" )
            #browser.switch_to.window(handle)
            within_window("Login | Facebook") do
              page.should have_content("Log in to use your Facebook account with Drive Less Challenge.")
              fill_in "Email:", :with => "jenmei@blazingcloud.net"
              fill_in "Password:", :with => "webrat"
              # The window disappears after the click, so resynchronizing fails
              driver.options[:resynchronize] = false
              begin
                find('input[name=login]').click
              ensure
                driver.options[:resynchronize] = true
              end
            end
            #browser.switch_to.window(@app_window)
          end

          she "she should be shown her My Trips page" do
            page.driver.browser.save_screenshot('file.png')
            save_page
            page.find('div.navigation ol li.current').should have_content("My Trips")
          end
        end

      end

    end
  end 
end
