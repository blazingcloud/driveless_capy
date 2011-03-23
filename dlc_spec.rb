require 'rubygems'
require "bundler/setup"
require 'capybara/rspec'
require 'capybara/dsl'
require 'selenium-webdriver'
require 'ruby-debug'
require 'capybara/firebug'

sauce_user = ENV["SAUCE_USER"]
sauce_key = ENV["SAUCE_KEY"]

if sauce_user && sauce_key
  require 'sauce'
  require 'sauce/capybara'
  Sauce.config do |conf|
    conf.username = sauce_user
    conf.access_key = sauce_key
    conf.browsers = [
        ["Linux", "firefox", "3.6."]
    ]
  end

  Capybara.default_driver = :sauce
else
  Capybara.default_driver = :selenium #_with_firebug
  Selenium::WebDriver::Firefox::Binary.path = "/Applications/Firefox 3.6.app/Contents/MacOS/firefox-bin"
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
    Capybara.current_session.driver.browser
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
          @app_window = current_window

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
            within_window("Login | Facebook") do
              page.should have_content("Log in to use your Facebook account with Drive Less Challenge.")
              fill_in "Email:", :with => "jenmei@blazingcloud.net"
              fill_in "Password:", :with => "webrat"
              find('input[name=login]').click
            end
            browser.switch_to.window(@app_window)
            debugger
            fb_connect = Capybara.current_session.driver.browser.find_element(:id, 'RES_ID_fb_login_image')
            fb_connect.click
          end

          she "she should be shown her My Trips page" do
            current_path.should == "/account"
            page.find('div.navigation ol li.current').should have_content("My Trips")
          end
        end

      end

    end
  end 
end
