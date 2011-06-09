# SimpleGeo, TODO: move to Gemfiles and yml config files
#require 'simple_geo'
#SimpleGeo::Client.set_credentials('Yd967f9YW4W6UyR9bdZgvgScKehmjVfD', 'FVZY8ddMhDtesvyh4y6fSEJuKpaWZpsm')

# load YAML config
SETTINGS = YAML.load_file("#{Rails.root}/config/settings.yml")

# CarrierWave S3 config
CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',       # required
    :aws_access_key_id      => SETTINGS[Rails.env]['s3']['access_key_id'],       # required
    :aws_secret_access_key  => SETTINGS[Rails.env]['s3']['secret_access_key'],       # required
    #:region                 => 'eu-west-1'  # optional, defaults to 'us-east-1'
  }
  config.fog_directory  = SETTINGS[Rails.env]['bucket']                     # required
  # TODO: fix to simply use http? or use amazon domain
  #config.fog_host       = 'http://dev-media.mojo.co.s3.amazonaws.com'            # optional, defaults to nil
  #config.fog_public     = false                                   # optional, defaults to true
  #config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
end

# include libs
require 'sms'
require 'form_helper'
require 'validations'
require 'model_extensions'
