require 'net/smtp'
require 'socket'

def get_ip

	orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true

	UDPSocket.open do |s|
		s.connect '64.233.187.99', 1 #google
		return s.addr.last
	end

ensure
	Socket.do_not_reverse_lookup = orig
end

message = <<MESSAGE_END
From: <#{ARGV[0]}>
To: <#{ARGV[1]}>
Subject: SMTP e-mail test

#{ARGV[2]}
MESSAGE_END

Net::SMTP.start(get_ip, 2525) do |smtp|
	smtp.send_message message, ARGV[0], ARGV[1]
end
