# encoding: utf-8

require 'net/smtp'

app = Rack::Builder.new do
  use Rack::CommonLogger
  run Proc.new {|env| [404, {"Content-Type" => "text/html"}, []]}

  map '/sendmail' do
    run Proc.new { |env|
      req = Rack::Request.new(env)
      params = req.params
      if params.has_key?('name') && params.has_key?('email') && params.has_key?('subject') && params.has_key?('message')

        message = "From: #{params['email']}\n" +
                  "To: dest@test.com\n" +
                  "Content-type: text/html\n" +
                  "Subject: #{params['subject']}\n\n" +
                  "<html><head><title>#{params['subject']}</title>" +
                  '</head><body>' +
                  "<p><b>Nom:</b> #{params['name']}</p>" +
                  "<p><b>Email:</b> #{params['email']}</p>" +
                  "<p>#{params['message']}</p>" +
                  '</body></html>'

        smtp = Net::SMTP.new 'smtp.gmail.com', 587
        smtp.enable_starttls
        smtp.start('', 'login_name', 'login_password', :login) do |smtp|
          smtp.send_message message, params['email'], 'dest@test.com'
        end

        [200, {"Content-Type" => "text/html"}, ['Message is sended.']]
      else
        [401, {"Content-Type" => "text/html"}, []]
      end
    }
  end


end

run app
