require 'signet/oauth_1/client'

namespace :maintenance do
  task :clean_places => :environment do
    
    used_places = Sortie.all.map { |s| s.place_id  }.uniq
    Place.all.each do |p|
      p.destroy if !used_places.include?(p.id)
    end
    
  end
  
  task :add_place_yelp => :environment do
    
    Place.all.each do |p|
      if p.provider == 'yelp' and p.yelp.nil?
        
        # Yelp APIv2: business search, TODO: refactor into a Class/ActiveRecord...
        client = Signet::OAuth1::Client.new(SETTINGS[Rails.env]['YelpV2'])

        #puts "Querying Yelp API..."

        response = client.fetch_protected_resource(
          :uri => "http://api.yelp.com/v2/business/#{p.provider_id}"
        )
        # The Rack response format is used here
        status, headers, body = response

        b = ActiveSupport::JSON.decode(body[0])
        #puts n.inspect
        
        p.yelp = PlaceYelp.new({
          :url => b['url'],
          :review_count => b['review_count'],
          :rating_img_url_small => b['rating_img_url_small']
        })
        p.save
        
        puts "done with #{p.provider_id}"
        
      end
    end
    
  end
end
