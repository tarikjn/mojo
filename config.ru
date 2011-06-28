# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

# serve static assets in tmp/uploads for CarrierWave's cache
use Rack::Static, :urls => ['/uploads'], :root => 'tmp'

run Mojo::Application
