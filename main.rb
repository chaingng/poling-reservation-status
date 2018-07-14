require './reservation/jal'

start_month = ARGV[0]
start_day = ARGV[1]
start_port = ARGV[2]
end_month = ARGV[3]
end_day = ARGV[4]
end_port = ARGV[5]
to_email = ARGV[6]

jal = JAL.new(start_month, start_day, start_port, end_month, end_day, end_port, to_email)
jal.login
jal.goto_milage_page
jal.input_flight_details
result = jal.revervation_status
#jal.reservation_screenshot
jal.record_and_send_email(result)
jal.quit
