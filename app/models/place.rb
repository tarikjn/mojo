class Place < ActiveRecord::Base
  
  has_many :sorties
  has_many :reviews, :class_name => "PlaceReview"
  
  has_one :yelp, :class_name => "PlaceYelp", :dependent => :destroy
  
  # GeoKit
  acts_as_mappable :default_units => :miles, 
                   :default_formula => :sphere, 
                   :distance_field_name => :distance,
                   :lat_column_name => :lat,
                   :lng_column_name => :lng
  
  # static methods
  def self.process_yelp_business(business)
    
    place = Place.where({:kind => 'business', :provider => 'yelp', :provider_id => business['id']}).first
    
    if (!place)
      
      place = Place.new({
        :kind => 'business',
        :provider => 'yelp',
        :provider_id => business['id'],
        :name => business['name'],
        :lat => business['location']['coordinate']['latitude'],
        :lng => business['location']['coordinate']['longitude'],
        :address => business['location']['address'].join(" "),
        :city => business['location']['city'],
        :state_code => business['location']['state_code'],
        :postal_code => business['location']['postal_code'],
        :country_code => business['location']['country_code'],
        :cross_streets => business['location']['cross_streets'],
        :neighborhoods => (business['location']['neighborhoods'].is_a? Array)? business['location']['neighborhoods'].join(", ") : nil
      })
      
      place.yelp = PlaceYelp.new({
        :url => business['url'],
        :review_count => business['review_count'],
        :rating_img_url_small => business['rating_img_url_small']
      })
      
      # save record
      place.save
      
    end
    
    # returns the place
    place
  end
end
