# frozen_string_literal: true

require "capybara/rspec"
require "selenium-webdriver"

# Configure headless Chrome driver
Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument("--headless=new")
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-dev-shm-usage")
  options.add_argument("--disable-gpu")
  options.add_argument("--window-size=1400,1400")

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

# Configure headless Firefox driver (for snap-installed Firefox)
Capybara.register_driver :headless_firefox do |app|
  options = Selenium::WebDriver::Firefox::Options.new
  options.add_argument("-headless")
  
  # Firefox installed via snap - point to actual binary
  options.binary = "/snap/firefox/current/usr/lib/firefox/firefox"

  Capybara::Selenium::Driver.new(app, browser: :firefox, options: options)
end

# Auto-detect which browser to use
def detect_browser_driver
  # Check for Chrome/Chromium
  if system("which google-chrome > /dev/null 2>&1") || system("which chromium-browser > /dev/null 2>&1") || system("which chromium > /dev/null 2>&1")
    return :headless_chrome
  end
  
  # Check for Firefox
  if system("which firefox > /dev/null 2>&1")
    return :headless_firefox
  end
  
  # Default to Chrome (will fail with helpful error if not installed)
  :headless_chrome
end

Capybara.javascript_driver = detect_browser_driver

# Configure Capybara defaults
Capybara.default_max_wait_time = 5
Capybara.server = :puma, { Silent: true }
