class Admin::AdminController < ApplicationController
  before_filter :require_admin #, :require_ssl
end
