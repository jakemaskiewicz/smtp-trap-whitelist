require 'rubygems'
require 'eventmachine'
require 'socket'

require 'emailstore.rb'

class EmailServer < EM::P::SmtpServer
	
	def p_inst
		p @@inst
	end

	def receive_plain_auth(user, pass)
		true
	end

	def get_server_domain
		"mock.smtp.server.local"
	end

	def get_server_greeting
		"mock smtp server greets you with impunity"
	end

	def receive_sender(sender)
		current.sender = sender
		true
	end

	def receive_recipient(recipient)
		current.recipient = recipient
		true
	end

	def receive_message
		current.received = true
		current.completed_at = Time.now
		
		EmailStore.instance.add_email(current)
		puts "Email Recieved (e:#{EmailStore.instance.email_size},p:#{EmailStore.instance.pass_size})"
		
		@current = OpenStruct.new
		true
	end

	def receive_ehlo_domain(domain)
		@ehlo_domain = domain
		true
	end

	def receive_data_command
		current.data = ""
		true
	end

	def receive_data_chunk(data)
		current.data << data.join("\n")
		true
	end

	def receive_transaction
		if @ehlo_domain
			current.ehlo_domain = @ehlo_domain
			@ehlo_domain = nil
		end
		true
	end

	def current
		@current ||= OpenStruct.new
	end

	def self.start(host = EmailServer::get_ip, port = 2525)
		require 'ostruct'
		@server = EM.start_server host, port, self
			
		puts "Server Running on #{host}:#{port}"
	end

	def self.stop
		if @server
			EM.stop_server @server
			@server = nil
		end
	end

	def self.running?
		!!@server
	end

	def self.get_ip
		orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true

		UDPSocket.open do |s|
			s.connect '64.233.187.99', 1 #google
			return s.addr.last
		end
	ensure
		Socket.do_not_reverse_lookup = orig
	end
end

if __FILE__ == $0
	EM.run{ EmailServer.start }
end

