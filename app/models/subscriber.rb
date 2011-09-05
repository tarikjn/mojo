class Subscriber < ActiveRecord::Base
  validates :email, :presence => true,
                    :uniqueness => true,
                    :email => true
  
  #disabled while importing?
  after_create :add_to_list
  
private

  def add_to_list
    # http://www.campaignmonitor.com/api/subscribers/#adding_a_subscriber
    auth = {:username => SETTINGS[Rails.env]['CampaignMonitor']['APIKey'], :password => nil}
    q = {
      "EmailAddress" => self.email,
      "CustomFields" => [
          {
            "Key"    => "location",
            "Value"  => self.location
          },
          {
            "Key"    => "ip",
            "Value"  => self.remote_addr
          }],
      "Resubscribe"  => true }
    HTTParty.post("http://api.createsend.com/api/v3/subscribers/#{SETTINGS[Rails.env]['CampaignMonitor']['SubscriberListID']}.json",
      basic_auth: auth,
      body: ActiveSupport::JSON.encode(q) )
  end
  
end
