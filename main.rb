require 'selenium-webdriver'
require 'nokogiri'

driver = Selenium::WebDriver.for :chrome
driver.manage.timeouts.implicit_wait = 30

driver.navigate.to 'https://www.jal.co.jp/'

driver.find_element(:xpath, "//div[@id='JS_loginBoxHeader']/div/div/ul/li[2]/a/div").click

driver.find_element(:id, "member_no").send_keys ENV["JAL_ID"]
driver.find_element(:id, "access_cd").send_keys ENV["JAL_PW"]
driver.find_element(:css, "button.btn-submit").click

driver.find_element(:id, "JS_login").click
driver.find_element(:link, "マイレージ").click

driver.find_element(:css, "li.member-menu-item.member_menu_item-nth-1 > a").click
until driver.find_element(:css, "div.u-list-item") do
  sleep 1
end
driver.find_element(:css, "div.u-list-item").click
until driver.find_element(:css, "input.image.linkButtonB") do
  sleep 1
end
driver.find_element(:css, "input.image.linkButtonB").click

Selenium::WebDriver::Support::Select.new(driver.find_element(:name, "boardMonth1")).select_by(:text, "10")
Selenium::WebDriver::Support::Select.new(driver.find_element(:name, "boardDay1")).select_by(:text, "28")

Selenium::WebDriver::Support::Select.new(driver.find_element(:name, "boardMonth2")).select_by(:text, "10")
Selenium::WebDriver::Support::Select.new(driver.find_element(:name, "boardDay2")).select_by(:text, "31")

Selenium::WebDriver::Support::Select.new(driver.find_element(:name, "departurePortCode1")).select_by(:text, "東京(羽田)")
Selenium::WebDriver::Support::Select.new(driver.find_element(:name, "arrivalPortCode1")).select_by(:text, "沖縄(那覇)")

Selenium::WebDriver::Support::Select.new(driver.find_element(:name, "departurePortCode2")).select_by(:text, "沖縄(那覇)")
Selenium::WebDriver::Support::Select.new(driver.find_element(:name, "arrivalPortCode2")).select_by(:text, "東京(羽田)")

driver.find_element(:css, "input.image.linkButtonA").click

html = driver.page_source
doc = Nokogiri::HTML(html)

result = []
doc.css('div.priceTable-body').css('tbody').each do |item|
  next if item.css('td.pricebtn img').attr('alt').text == "満席"
  result << [
    item.css('td.depart li').text,
    item.css('td.arrive li').text,
    item.css('td.pricebtn img').attr('alt').text
  ].join(',')
end

puts result
driver.quit
