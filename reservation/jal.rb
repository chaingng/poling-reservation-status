require 'selenium-webdriver'
require 'nokogiri'
require 'gmail'
require 'mini_magick'

class JAL

  def initialize(start_month, start_day, start_port, end_month, end_day, end_port, to_email)
    @start_month = start_month
    @start_day = start_day
    @start_port = start_port
    @end_month = end_month
    @end_day = end_day
    @end_port = end_port
    @to_email = to_email
    @file_name = "queries/#{@start_month}_#{@start_day}_#{@start_port}_#{@end_month}_#{@end_day}_#{@end_port}.log"
    self.init_driver
  end

  def init_driver
    @driver = Selenium::WebDriver.for :chrome
    @driver.manage.timeouts.implicit_wait = 30
    @driver.navigate.to 'https://www.jal.co.jp/'
  end

  def login
    @driver.find_element(:xpath, "//div[@id='JS_loginBoxHeader']/div/div/ul/li[2]/a/div").click
    @driver.find_element(:id, "member_no").send_keys ENV["JAL_ID"]
    @driver.find_element(:id, "access_cd").send_keys ENV["JAL_PW"]
    @driver.find_element(:css, "button.btn-submit").click
    @driver.find_element(:id, "JS_login").click
  end

  def goto_milage_page
    @driver.find_element(:link, "マイレージ").click
    @driver.find_element(:css, "li.member-menu-item.member_menu_item-nth-1 > a").click
    sleep 1
    @driver.find_element(:css, "div.u-list-item").click
    @driver.find_element(:css, "input.image.linkButtonB").click
  end

  def input_flight_details
    Selenium::WebDriver::Support::Select.new(@driver.find_element(:name, "boardMonth1")).select_by(:text, @start_month)
    Selenium::WebDriver::Support::Select.new(@driver.find_element(:name, "boardDay1")).select_by(:text, @start_day)

    Selenium::WebDriver::Support::Select.new(@driver.find_element(:name, "boardMonth2")).select_by(:text, @end_month)
    Selenium::WebDriver::Support::Select.new(@driver.find_element(:name, "boardDay2")).select_by(:text, @end_day)

    Selenium::WebDriver::Support::Select.new(@driver.find_element(:name, "departurePortCode1")).select_by(:text, @start_port)
    Selenium::WebDriver::Support::Select.new(@driver.find_element(:name, "arrivalPortCode1")).select_by(:text, @end_port)

    Selenium::WebDriver::Support::Select.new(@driver.find_element(:name, "departurePortCode2")).select_by(:text, @end_port)
    Selenium::WebDriver::Support::Select.new(@driver.find_element(:name, "arrivalPortCode2")).select_by(:text, @start_port)

    @driver.find_element(:css, "input.image.linkButtonA").click
  end

  def revervation_status
    result = []
    html = @driver.page_source
    doc = Nokogiri::HTML(html)
    doc.css('div.priceTable-body').css('tbody').each do |item|
      next if item.css('td.pricebtn img').attr('alt').text == "満席"
      result << [
        item.css('td.depart li').text,
        item.css('td.arrive li').text,
        item.css('td.pricebtn img').attr('alt').text
      ].join(',')
    end
    result
  end

  def reservation_screenshot
    @driver.execute_script('window.scrollTo(0, 300);')
    @driver.save_screenshot('screen_shots/filename.png')
  end

  def quit
    @driver.quit
  end

  def send_email(result_body, email_to)
    gmail_user_name = ENV["GMAIL_USER_NAME"]
    gmail_password = ENV["GMAIL_PW"]

    gmail = Gmail.new(gmail_user_name, gmail_password)

    message =
    gmail.generate_message do
      to email_to
      subject "JAL予約状況"
      html_part do
        content_type "text/html; charset=UTF-8"
        body result_body
      end
      add_file 'screen_shots/filename.png'
    end

    gmail.deliver(message)
    gmail.logout
  end

  def same_result?(result)
    return false if !File.exist?(@file_name)
    prev_result = File.open(@file_name).read
    result.join(',') == prev_result.chomp
  end

  def record_and_send_email(result)
    if !same_result?(result)
      puts result
      File.open(@file_name, "w") { |file| file.puts(result.join(',')) }
      result_body = ""
      result.each {|r| result_body = result_body + r + '<br>' }
      send_email(result_body, @to_email)
    else
      puts "same result"
    end
  end
end
