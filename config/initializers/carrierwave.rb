# CarrierWave config/S3
CarrierWave.configure do |config|
  
  # uploads directory --supported by Heroku
  config.cache_dir = "uploads"
  config.root = Rails.root.join('tmp')
  
  # S3 settings
  config.fog_credentials = {
    :provider               => 'AWS', # required
    :aws_access_key_id      => SETTINGS[Rails.env]['s3']['access_key_id'], # required
    :aws_secret_access_key  => SETTINGS[Rails.env]['s3']['secret_access_key'], # required
    #:region                 => 'eu-west-1'  # optional, defaults to 'us-east-1'
  }
  
  config.fog_directory  = SETTINGS[Rails.env]['bucket'] # required
  
  # required, or CarrierWave defaults to https
  config.fog_host       = "http://#{SETTINGS[Rails.env]['bucket']}.s3.amazonaws.com" # optional, defaults to nil
  
  #config.fog_public     = false                                   # optional, defaults to true
  #config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
end
