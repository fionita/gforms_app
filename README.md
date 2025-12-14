# GForms App

A Rails application for creating and managing forms with responses.

## Requirements

* Ruby 3.2.5
* Rails 8.1.1
* SQLite3
* For running feature specs: Chrome/Chromium or Firefox browser with corresponding webdriver

## Setup

```bash
bin/setup
```

This will install dependencies, prepare the database, and start the development server.

## Running the Application

```bash
bin/dev
```

The application will be available at http://localhost:3000

## Running Tests

### Unit/Integration Tests
```bash
bundle exec rspec
```

### Feature Tests (require a browser)
```bash
bundle exec rspec spec/features
```

**Browser Requirements for Feature Tests:**
The test suite will automatically detect and use Chrome or Firefox. Install one of the following:

**Chrome/Chromium:**
```bash
# Ubuntu/Debian
sudo apt install chromium-browser
# or
sudo apt install google-chrome-stable
```

**Firefox:**
```bash
# Ubuntu/Debian
sudo apt install firefox
# Also install geckodriver
sudo snap install geckodriver
```

The Capybara configuration (`spec/support/capybara.rb`) will automatically use whichever browser is available.
