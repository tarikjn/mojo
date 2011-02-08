#require 'twiliolib'

# TODO: convert into module?
class Sms
  
  #include Twilio
  
  # send is a reserved Ruby keyword, use deliver
  def self.deliver(recipient, message)
    
    logger = RAILS_DEFAULT_LOGGER.debug
    set = SETTINGS[Rails.env]['Twilio']
    
    # parameters sent to Twilio REST API
    d = {
        'From' => set['CALLER_ID'],
        'To' => recipient,
        'Body' => message
    }
  
    begin
        account = Twilio::RestAccount.new(set['ACCOUNT_SID'], set['ACCOUNT_TOKEN'])
        resp = account.request(
            "/#{set['API_VERSION']}/Accounts/#{set['ACCOUNT_SID']}/SMS/Messages",
            'POST', d)
        resp.error! unless resp.kind_of? Net::HTTPSuccess
    rescue StandardError => bang
        logger.debug({ :action => '.', 'msg' => "Error #{ bang }"})
        return
    end
  
  end
  
end
