# SMTP Trap w/ Whitelist

## Description

We ran into some issues using our production SMTP server as our default smtp server when we added test users with false email addresses. This usually can be fixed by using an SMTP trap, which is a dummy SMTP server that stops all email that gets to it. The problem with this method is that it can't forward through the real emails needed to get to the admin user.

As a solution, I've written an SMTP trap with a whitelist. If any email that reaches the trap is addressed to a recipient whose email is on the whitelist, the trap will forward the message through the real SMTP server so that it will actually be sent. All other email is stored into an array for easy access.

## How to Install

### Command Line

To run from the command line, you will need ruby and the eventmachine gem. To install the gem, simply use `gem install eventmachine` from the console. Once you've installed the requisite gem, simply extract all of the files into a folder and run `ruby smtpserver.rb`

### Config

Be sure to edit config.yml to include your production SMTP server settings and port. Leave :local: :host: as "" in order to use the current machine's ip address.

### The Whitelist

To add an email to the whitelist, stop the server and open whitelist.txt. Add one email for each line, and then restart the server.

### Testing

For testing purposes, there is also a mail sending script that you can use with ruby sendmail.rb sender recipient "message", of course replacing the sender, recipient, and message with your desired text.

### Your Test Setup

In order to use this mailserver with your application, simply point your SMTP sending code to use your machine's ip address in as the host, and port 2525. (http://whatsmyip.net/ is a quick way to get your ip).  Running the server will also tell you (in stdout) what ip the server is running at.

### EmailStore

If you want to have better access to the actual contents of the trapped emails, you can run the smtp server inside of ruby, either by writing your own script, or by doing so in irb. Inside of ruby, you can launch the server by doing `EM.run{ EmailServer.start }` after requiring `smtpserver.rb`.

I recommend launching the server in a thread so that it wont lock up your main thread like so: `t = Thread.new { ... }`. Once your server is running inside of the thread, you can access the EmailStore singleton like so: `EmailStore.instance` (after requiring `emailstore.rb`)

### Useful Methods

- get_email ( i = -1 )

Gets the email at given index, if index is -1 (default) it returns the most recent email. The email is an openstruct with various fields including recipient, sender, data, plaintext. Note that plaintext will only be present if the email was base64 encoded, and it is the decoded plain text (not html) segment of the message.

- email_size

Gets the current number of emails inside the store

##Thanks 

If you find this script useful, or if you'd like any features to be added to it, let me know! I'd love to hear from you, and I'll see what I can do about it.
