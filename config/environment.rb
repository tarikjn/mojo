# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Mojo::Application.initialize!

# Mail settings
Mojo::Application.configure do
  config.action_mailer.delivery_method = :smtp
  
  config.action_mailer.smtp_settings = {
    :address              => "smtp.gmail.com",
    :port                 => 587,
    :domain               => "mojo.co",
    :authentication       => "plain",
    :user_name            => "mailer@mojo.co",
    :password             => "br8pRasw",
    :enable_starttls_auto => true
  }
  
  config.action_mailer.raise_delivery_errors = true
end
