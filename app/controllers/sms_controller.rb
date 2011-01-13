# your Twilio authentication credentials
ACCOUNT_SID = 'ACe04542bb0bb52dd68d5ed9e03b87ef99'
ACCOUNT_TOKEN = 'ce45261ee3ced1c7c3af8deb41fddf93'
 
# version of the Twilio REST API to use
API_VERSION = '2010-04-01'
 
# base URL of this application
BASE_URL = "http://demo.twilio.com/welcome/sms"
 
# Outgoing Caller ID you have previously validated with Twilio
CALLER_ID = '(415) 599-2671'

class SmsController < ApplicationController
  def send_sms
    # parameters sent to Twilio REST API
    d = {
        'From' => CALLER_ID,
        'To' => '650-644-9308',
        'Body' => 'This is Mojo dumbass!'
    }
    
    begin
        account = Twilio::RestAccount.new(ACCOUNT_SID, ACCOUNT_TOKEN)
        resp = account.request(
            "/#{API_VERSION}/Accounts/#{ACCOUNT_SID}/SMS/Messages",
            'POST', d)
        resp.error! unless resp.kind_of? Net::HTTPSuccess
    rescue StandardError => bang
        redirect_to({ :action => '.', 'msg' => "Error #{ bang }" })
        return
    end
    
  end
end
