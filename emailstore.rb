require 'base64'
require 'net/smtp'

require 'config.rb'

class EmailStore
	
	SMTP_SERVER = Config::SETTINGS[:remote][:host]
	SMTP_PORT = Config::SETTINGS[:remote][:port]

	def initialize
		@emailarray = Array.new

		@whitelist = Array.new

		File.open('whitelist.txt','r').each_line do |line|
			@whitelist << "<#{line.strip!}>"
		end
	end
 
	@@instance = EmailStore.new

	def self.instance
		return @@instance
	end

	def add_email(msg)

		sixfour = msg.data[/base64\n*(.*)\n+------.*base64/m,1]
		

		unless sixfour.nil? || sixfour.empty?
			msgbody = Base64.decode64(sixfour)
			
			msg.plaintext = msgbody

		end

		@emailarray << msg
		
		if @whitelist.include? msg.recipient
			puts "Forwarding message through #{SMTP_SERVER}"

			Net::SMTP.start(SMTP_SERVER,SMTP_PORT) do |smtp|
				smtp.send_message msg.data, msg.sender, msg.recipient
			end

		end

	end

	def get_email(i = -1 )
		return @emailarray[i] unless i == -1
		return @emailarray.last
	end

	def email_size
		return @emailarray.size
	end

	private_class_method :new
end

