# SimpleGeo, TODO: move to Gemfiles and yml config files
#require 'simple_geo'
#SimpleGeo::Client.set_credentials('Yd967f9YW4W6UyR9bdZgvgScKehmjVfD', 'FVZY8ddMhDtesvyh4y6fSEJuKpaWZpsm')

# load YAML config
SETTINGS = YAML.load_file("#{Rails.root}/config/settings.yml")

# include libs
require 'sms'
require 'form_helper'
require 'validations'
require 'model_extensions'
