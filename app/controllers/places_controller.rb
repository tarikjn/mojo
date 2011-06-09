require 'signet/oauth_1/client'
class PlacesController < ApplicationController
  
  # disabled for stepflow
  #before_filter :require_access
  
  def search
    
    cache = ActiveSupport::Cache::FileStore.new('tmp/cache')
    
    # using fixed bounds on SF for API limit savings
    results = cache.fetch("yelp_37.679889,-122.544389,37.869849,-122.294451_{params[:q]}") do
      get_results(params[:bounds], params[:q])
    end
    
    response = ActiveSupport::JSON.decode(results[0])
    p response.inspect
    
    @places = []
    markers = []
    response['businesses'].each do |b|
      @places << Place::process_yelp_business(b)
      
      markers << [@places.last.lat, @places.last.lng]
    end

    respond_to do |format|
      format.json {
        with_format('html') do
          render :json => {
            # tells to the JS client how to render the response (next, prev, error)
            :markers => markers,
            # view with no layout (complete form with nav)
            :block => render_to_string(:action => :search, :layout => false)
          }
        end
      }
    end # /respond_to
    
  end
  
private
  
  def get_results(g_bounds, q)
  
    # receiving bounds in Google Maps format: lat_lo,lng_lo,lat_hi,lng_hi
    bounds = g_bounds.split(',')
  
    # looking for query as an address, poi or business
    
    # using GeoKit Geocoding
    
    # Yelp APIv2: business search, TODO: refactor into a Class/ActiveRecord...
    client = Signet::OAuth1::Client.new(
      :client_credential_key    => '86ypn4Dpn4ohLwMF_f24qw',
      :client_credential_secret => '92_sq_DgnNeTiHF96upfP_KHlEI',
      :token_credential_key     => 'Mm7BAz8uK0_a1LCYTOJDwWIaMkpuIUzc',
      :token_credential_secret  => 'K0o42jJQL9HeeH2YUiRtpC3yFdc'
    )
    # yelp bounds format: bounds=sw_latitude,sw_longitude|ne_latitude,ne_longitude
    query_params = {
      :bounds => "#{bounds[0]},#{bounds[1]}|#{bounds[2]},#{bounds[3]}",
      :term => q
    }.to_params # use this?
    
    Logger.new(STDOUT).info("Querying Yelp API...")
    
    response = client.fetch_protected_resource(
      :uri => "http://api.yelp.com/v2/search?bounds=#{bounds[0]},#{bounds[1]}|#{bounds[2]},#{bounds[3]}&term=#{q}&limit=8"
    )
    # The Rack response format is used here
    status, headers, body = response
    
    #resp = ActiveSupport::JSON.decode(body)
    
    body
  
  end
  
  def get_cafe
    ["{\"region\":{\"span\":{\"latitude_delta\":0.18995999999999924,\"longitude_delta\":0.24993800000000022},\"center\":{\"latitude\":37.774869000000002,\"longitude\":-122.41942}},\"total\":4035,\"businesses\":[{\"rating_img_url_small\":\"http://media2.px.yelpcdn.com/static/201012161127761206/i/ico/stars/stars_small_4_half.png\",\"mobile_url\":\"http://mobile.yelp.com/biz/Q9KeURmTqRFLKb_3Dxq6Jw\",\"rating_img_url\":\"http://media4.px.yelpcdn.com/static/201012163106483837/i/ico/stars/stars_4_half.png\",\"review_count\":138,\"name\":\"Cafe Murano\",\"url\":\"http://www.yelp.com/biz/cafe-murano-san-francisco\",\"phone\":\"4157710888\",\"snippet_text\":\"This is a great little cafe to work.  When I went there was plenty of space to hunker down and use their free wifi.  The chocolate mouse was out of this...\",\"image_url\":\"http://media2.px.yelpcdn.com/bphoto/PBoGV_3pRtA2_Od-9ABDDQ/ms\",\"snippet_image_url\":\"http://media1.px.yelpcdn.com/photo/nNCDMy3obBx_nIwmF9r1Mw/ms\",\"display_phone\":\"+1-415-771-0888\",\"id\":\"cafe-murano-san-francisco\",\"categories\":[[\"Coffee & Tea\",\"coffee\"]],\"location\":{\"cross_streets\":\"Post St & Sutter St\",\"city\":\"San Francisco\",\"display_address\":[\"1777 Steiner St\",\"(b/t Post St & Sutter St)\",\"Pacific Heights\",\"San Francisco, CA 94115\"],\"geo_accuracy\":8,\"neighborhoods\":[\"Pacific Heights\",\"Lower Pac Heights\"],\"postal_code\":\"94115\",\"country_code\":\"US\",\"address\":[\"1777 Steiner St\"],\"coordinate\":{\"latitude\":37.785535199999998,\"longitude\":-122.4349758},\"state_code\":\"CA\"}},{\"rating_img_url_small\":\"http://media2.px.yelpcdn.com/static/201012161127761206/i/ico/stars/stars_small_4_half.png\",\"mobile_url\":\"http://mobile.yelp.com/biz/6iR0zBfiup79DErYKAXY0Q\",\"rating_img_url\":\"http://media4.px.yelpcdn.com/static/201012163106483837/i/ico/stars/stars_4_half.png\",\"review_count\":206,\"name\":\"Cafe International\",\"url\":\"http://www.yelp.com/biz/cafe-international-san-francisco\",\"phone\":\"4155527390\",\"snippet_text\":\"The iced coffee is amazing!!!! Coffee ice cubes in the shape of a gun??? Loved it.. I got the falafel sandwich it had hummus cucumber and tomatoes in it...\",\"image_url\":\"http://media3.px.yelpcdn.com/bphoto/62JkuSlLFZ8csatJYFmB7Q/ms\",\"snippet_image_url\":\"http://media3.ct.yelpcdn.com/photo/Jw6G92aaLRuD81eyjcYQVg/ms\",\"display_phone\":\"+1-415-552-7390\",\"id\":\"cafe-international-san-francisco\",\"categories\":[[\"Coffee & Tea\",\"coffee\"],[\"Sandwiches\",\"sandwiches\"],[\"Desserts\",\"desserts\"]],\"location\":{\"cross_streets\":\"Fillmore St & Steiner St\",\"city\":\"San Francisco\",\"display_address\":[\"508 Haight St\",\"(b/t Fillmore St & Steiner St)\",\"Lower Haight\",\"San Francisco, CA 94117\"],\"geo_accuracy\":8,\"neighborhoods\":[\"Lower Haight\"],\"postal_code\":\"94117\",\"country_code\":\"US\",\"address\":[\"508 Haight St\"],\"coordinate\":{\"latitude\":37.772080000000003,\"longitude\":-122.430864},\"state_code\":\"CA\"}},{\"rating_img_url_small\":\"http://media3.px.yelpcdn.com/static/20101216418129184/i/ico/stars/stars_small_4.png\",\"mobile_url\":\"http://mobile.yelp.com/biz/feyoNcj3XJ93JseDXEIc5g\",\"rating_img_url\":\"http://media1.ct.yelpcdn.com/static/201012164084228337/i/ico/stars/stars_4.png\",\"review_count\":86,\"name\":\"H Cafe\",\"url\":\"http://www.yelp.com/biz/h-cafe-san-francisco\",\"phone\":\"4154871661\",\"snippet_text\":\"The iced coffee here was good, but I'm giving H Cafe 5 stars because of the nice owner who took care of my when I fell outside. I was headed to Dolores park...\",\"image_url\":\"http://media4.px.yelpcdn.com/bphoto/6mxETqOCJ64lsr3xlWNTLQ/ms\",\"snippet_image_url\":\"http://media4.px.yelpcdn.com/photo/9bB7CdFa0tNY-X1BGWfQ5Q/ms\",\"display_phone\":\"+1-415-487-1661\",\"id\":\"h-cafe-san-francisco\",\"categories\":[[\"Coffee & Tea\",\"coffee\"]],\"location\":{\"cross_streets\":\"Prosper St & Sanchez St\",\"city\":\"San Francisco\",\"display_address\":[\"3801 17th St\",\"(b/t Prosper St & Sanchez St)\",\"Castro\",\"San Francisco, CA 94114\"],\"geo_accuracy\":8,\"neighborhoods\":[\"Castro\"],\"postal_code\":\"94114\",\"country_code\":\"US\",\"address\":[\"3801 17th St\"],\"coordinate\":{\"latitude\":37.762763,\"longitude\":-122.43074799999999},\"state_code\":\"CA\"}},{\"rating_img_url_small\":\"http://media3.px.yelpcdn.com/static/20101216418129184/i/ico/stars/stars_small_4.png\",\"mobile_url\":\"http://mobile.yelp.com/biz/aB_jimByFRPpde3LC13ucw\",\"rating_img_url\":\"http://media1.ct.yelpcdn.com/static/201012164084228337/i/ico/stars/stars_4.png\",\"review_count\":180,\"name\":\"Bazaar Cafe\",\"url\":\"http://www.yelp.com/biz/bazaar-cafe-san-francisco\",\"phone\":\"4158315620\",\"snippet_text\":\"Cozy, and casual, smalltown feel... yes, all true.  \\nBut I love this place the most because it gives a home to songwriters.\\nThurs night open mic= a sense of...\",\"image_url\":\"http://media4.ct.yelpcdn.com/bphoto/qFETZCFqmdLZvRpcKS-8ag/ms\",\"snippet_image_url\":\"http://media3.px.yelpcdn.com/photo/OjhofRpAFedBP4-jJlnz_Q/ms\",\"display_phone\":\"+1-415-831-5620\",\"id\":\"bazaar-cafe-san-francisco\",\"categories\":[[\"Coffee & Tea\",\"coffee\"],[\"American (New)\",\"newamerican\"]],\"location\":{\"cross_streets\":\"21st Ave & 22nd Ave\",\"city\":\"San Francisco\",\"display_address\":[\"5927 California St\",\"(b/t 21st Ave & 22nd Ave)\",\"Outer Richmond\",\"San Francisco, CA 94121\"],\"geo_accuracy\":8,\"neighborhoods\":[\"Outer Richmond\"],\"postal_code\":\"94121\",\"country_code\":\"US\",\"address\":[\"5927 California St\"],\"coordinate\":{\"latitude\":37.783917299999999,\"longitude\":-122.4812215},\"state_code\":\"CA\"}},{\"rating_img_url_small\":\"http://media3.px.yelpcdn.com/static/20101216418129184/i/ico/stars/stars_small_4.png\",\"mobile_url\":\"http://mobile.yelp.com/biz/R3YMmqmPIjJh8V80VpTD1w\",\"rating_img_url\":\"http://media1.ct.yelpcdn.com/static/201012164084228337/i/ico/stars/stars_4.png\",\"review_count\":460,\"name\":\"Cafe du Soleil\",\"url\":\"http://www.yelp.com/biz/cafe-du-soleil-san-francisco\",\"phone\":\"4159348637\",\"snippet_text\":\"Picture a perfect late afternoon in the city.  Now, imagine you are holding a delicious glass of wine.  Somehow the picture magically becomes more...\",\"image_url\":\"http://media4.ct.yelpcdn.com/bphoto/xliIAj6PvyRsmAOiMrt0vA/ms\",\"snippet_image_url\":\"http://media3.ct.yelpcdn.com/photo/DY91uZube5Q8RYZQdA0-DA/ms\",\"display_phone\":\"+1-415-934-8637\",\"id\":\"cafe-du-soleil-san-francisco\",\"categories\":[[\"Coffee & Tea\",\"coffee\"],[\"Sandwiches\",\"sandwiches\"]],\"location\":{\"city\":\"San Francisco\",\"display_address\":[\"200 Fillmore St\",\"Lower Haight\",\"San Francisco, CA 94102\"],\"geo_accuracy\":8,\"neighborhoods\":[\"Lower Haight\",\"Hayes Valley\"],\"postal_code\":\"94102\",\"country_code\":\"US\",\"address\":[\"200 Fillmore St\"],\"coordinate\":{\"latitude\":37.771408000000001,\"longitude\":-122.430125},\"state_code\":\"CA\"}},{\"rating_img_url_small\":\"http://media2.px.yelpcdn.com/static/201012161127761206/i/ico/stars/stars_small_4_half.png\",\"mobile_url\":\"http://mobile.yelp.com/biz/hwrQ5txvtK_S7Uhs5kkPNg\",\"rating_img_url\":\"http://media4.px.yelpcdn.com/static/201012163106483837/i/ico/stars/stars_4_half.png\",\"review_count\":54,\"name\":\"YakiniQ Cafe\",\"url\":\"http://www.yelp.com/biz/yakiniq-cafe-san-francisco\",\"phone\":\"4154419291\",\"snippet_text\":\"I started coming to this cafe literally the week it opened. I was on a stroll through Japantown, saw a chalkboard sign, and ventured inside. The lady at the...\",\"image_url\":\"http://media4.ct.yelpcdn.com/bphoto/S8jlSbg6y_zL4GmDXOqwvg/ms\",\"snippet_image_url\":\"http://media2.ct.yelpcdn.com/photo/EIBBsGY_k7q2z3ymwbOy6w/ms\",\"display_phone\":\"+1-415-441-9291\",\"id\":\"yakiniq-cafe-san-francisco\",\"categories\":[[\"Coffee & Tea\",\"coffee\"]],\"location\":{\"cross_streets\":\"Laguna St & Buchanan St\",\"city\":\"San Francisco\",\"display_address\":[\"1640 Post St\",\"(b/t Laguna St & Buchanan St)\",\"Pacific Heights\",\"San Francisco, CA 94115\"],\"geo_accuracy\":8,\"neighborhoods\":[\"Pacific Heights\",\"Lower Pac Heights\",\"Japantown\"],\"postal_code\":\"94115\",\"country_code\":\"US\",\"address\":[\"1640 Post St\"],\"coordinate\":{\"latitude\":37.785930999999998,\"longitude\":-122.428867},\"state_code\":\"CA\"}},{\"rating_img_url_small\":\"http://media3.px.yelpcdn.com/static/20101216418129184/i/ico/stars/stars_small_4.png\",\"mobile_url\":\"http://mobile.yelp.com/biz/EAJii57EZJZPtaH-EtlG4w\",\"rating_img_url\":\"http://media1.ct.yelpcdn.com/static/201012164084228337/i/ico/stars/stars_4.png\",\"review_count\":13,\"name\":\"Readers Cafe\",\"url\":\"http://www.yelp.com/biz/readers-cafe-san-francisco\",\"phone\":\"4157711011\",\"snippet_text\":\"Blue Bottle Coffee AND Red Blossom Tea? \\n\\nJACKPOT\\n\\nThis unassuming cafe is the extension of the local Fort Mason library.  I never would've known this place...\",\"image_url\":\"http://media3.px.yelpcdn.com/bphoto/LXt5VMcibRE3LUi05DA18A/ms\",\"snippet_image_url\":\"http://media2.px.yelpcdn.com/photo/cDVIoik1Wqf5togbxUgZ4Q/ms\",\"display_phone\":\"+1-415-771-1011\",\"id\":\"readers-cafe-san-francisco\",\"categories\":[[\"Coffee & Tea\",\"coffee\"]],\"location\":{\"city\":\"San Francisco\",\"display_address\":[\"Fort Mason Ctr\",\"Bldg C\",\"Marina/Cow Hollow\",\"San Francisco, CA 94123\"],\"geo_accuracy\":9,\"neighborhoods\":[\"Marina/Cow Hollow\"],\"postal_code\":\"94123\",\"country_code\":\"US\",\"address\":[\"Fort Mason Ctr\",\"Bldg C\"],\"coordinate\":{\"latitude\":37.806715461209699,\"longitude\":-122.431318759918},\"state_code\":\"CA\"}},{\"rating_img_url_small\":\"http://media4.ct.yelpcdn.com/static/201012161949604803/i/ico/stars/stars_small_5.png\",\"mobile_url\":\"http://mobile.yelp.com/biz/JxNi3ZZJA5A_MexAWXYFFA\",\"rating_img_url\":\"http://media2.px.yelpcdn.com/static/201012162578611207/i/ico/stars/stars_5.png\",\"review_count\":16,\"name\":\"Rock Nation Cafe\",\"url\":\"http://www.yelp.com/biz/rock-nation-cafe-san-francisco\",\"phone\":\"4153411067\",\"snippet_text\":\"While there are tons of cafes in the Mission - finding one that I really like to work/study out of is eluding me. Rock Nation is great - enough energy that...\",\"image_url\":\"http://media3.ct.yelpcdn.com/bphoto/X1EdswxCIHhIWrmXT7Me3Q/ms\",\"snippet_image_url\":\"http://media4.ct.yelpcdn.com/photo/BO5p5vnoCUkqyxR_Sgh1JQ/ms\",\"display_phone\":\"+1-415-341-1067\",\"id\":\"rock-nation-cafe-san-francisco\",\"categories\":[[\"Coffee & Tea\",\"coffee\"]],\"location\":{\"cross_streets\":\"Alabama St & Harrison St\",\"city\":\"San Francisco\",\"display_address\":[\"2850 21st St\",\"(b/t Alabama St & Harrison St)\",\"Mission\",\"San Francisco, CA 94110\"],\"geo_accuracy\":8,\"neighborhoods\":[\"Mission\"],\"postal_code\":\"94110\",\"country_code\":\"US\",\"address\":[\"2850 21st St\"],\"coordinate\":{\"latitude\":37.757489499999998,\"longitude\":-122.4116075},\"state_code\":\"CA\"}},{\"rating_img_url_small\":\"http://media3.px.yelpcdn.com/static/20101216418129184/i/ico/stars/stars_small_4.png\",\"mobile_url\":\"http://mobile.yelp.com/biz/rYr97NUzseMV53WY1YB6Sw\",\"rating_img_url\":\"http://media1.ct.yelpcdn.com/static/201012164084228337/i/ico/stars/stars_4.png\",\"review_count\":74,\"name\":\"Cafe Mereb\",\"url\":\"http://www.yelp.com/biz/cafe-mereb-san-francisco\",\"phone\":\"4156682988\",\"snippet_text\":\"It's about time I write a review for this place. I come here a good bit because it's got just about eveything I need/want in a cafe. \\n\\nIt's got fast wifi,...\",\"image_url\":\"http://media1.ct.yelpcdn.com/bphoto/-CeKSXxLSTVxLo5Wtmez6A/ms\",\"snippet_image_url\":\"http://media1.ct.yelpcdn.com/photo/jDufQEHQqaPal39fK51xlg/ms\",\"display_phone\":\"+1-415-668-2988\",\"id\":\"cafe-mereb-san-francisco\",\"categories\":[[\"Coffee & Tea\",\"coffee\"],[\"Mediterranean\",\"mediterranean\"]],\"location\":{\"cross_streets\":\"16th Ave & 17th Ave\",\"city\":\"San Francisco\",\"display_address\":[\"1541 Clement St\",\"(b/t 16th Ave & 17th Ave)\",\"Outer Richmond\",\"San Francisco, CA 94118\"],\"geo_accuracy\":8,\"neighborhoods\":[\"Outer Richmond\"],\"postal_code\":\"94118\",\"country_code\":\"US\",\"address\":[\"1541 Clement St\"],\"coordinate\":{\"latitude\":37.782339999999998,\"longitude\":-122.47593999999999},\"state_code\":\"CA\"}},{\"rating_img_url_small\":\"http://media2.px.yelpcdn.com/static/201012161127761206/i/ico/stars/stars_small_4_half.png\",\"mobile_url\":\"http://mobile.yelp.com/biz/JzqPVrG1ap6XmEqxbXQSLg\",\"rating_img_url\":\"http://media4.px.yelpcdn.com/static/201012163106483837/i/ico/stars/stars_4_half.png\",\"review_count\":33,\"name\":\"The Marsh Cafe And Gallery\",\"url\":\"http://www.yelp.com/biz/the-marsh-cafe-and-gallery-san-francisco\",\"phone\":\"4158265750\",\"snippet_text\":\"Easy place to work and the best selection of caffeinated and noncaffeinated teas I've ever seen. Of course, I'm referring to life in the cafe. I think the...\",\"image_url\":\"http://media2.px.yelpcdn.com/bphoto/CN_wFfeJjwdG0xR9ZyMwDg/ms\",\"snippet_image_url\":\"http://media2.ct.yelpcdn.com/photo/DG9F4TQf9cWYM_HyxKK9tg/ms\",\"display_phone\":\"+1-415-826-5750\",\"id\":\"the-marsh-cafe-and-gallery-san-francisco\",\"categories\":[[\"Coffee & Tea\",\"coffee\"]],\"location\":{\"cross_streets\":\"Hill St & 22nd St\",\"city\":\"San Francisco\",\"display_address\":[\"1070 Valencia St\",\"(b/t Hill St & 22nd St)\",\"Mission\",\"San Francisco, CA 94110\"],\"geo_accuracy\":8,\"neighborhoods\":[\"Mission\"],\"postal_code\":\"94110\",\"country_code\":\"US\",\"address\":[\"1070 Valencia St\"],\"coordinate\":{\"latitude\":37.7557489,\"longitude\":-122.4210166},\"state_code\":\"CA\"}},{\"rating_img_url_small\":\"http://media2.px.yelpcdn.com/static/201012161127761206/i/ico/stars/stars_small_4_half.png\",\"mobile_url\":\"http://mobile.yelp.com/biz/__RnSySB3Z1rESyxOLilyw\",\"rating_img_url\":\"http://media4.px.yelpcdn.com/static/201012163106483837/i/ico/stars/stars_4_half.png\",\"review_count\":142,\"name\":\"Cafe Capriccio\",\"url\":\"http://www.yelp.com/biz/cafe-capriccio-san-francisco\",\"phone\":\"4157720937\",\"snippet_text\":\"My favorite cafe in the city, and I think I have been to quite a few.\\n\\nIt is not easy to find good cappuccino in the States -- ask anyone from Continental...\",\"image_url\":\"http://media2.px.yelpcdn.com/bphoto/RSrcHbPcVMFDZj8Eqg1Kyg/ms\",\"snippet_image_url\":\"http://media1.ct.yelpcdn.com/photo/X-dmejhc1lvFlabVFeoJ4A/ms\",\"display_phone\":\"+1-415-772-0937\",\"id\":\"cafe-capriccio-san-francisco\",\"categories\":[[\"Sandwiches\",\"sandwiches\"],[\"Coffee & Tea\",\"coffee\"]],\"location\":{\"cross_streets\":\"Chestnut St & Water St\",\"city\":\"San Francisco\",\"display_address\":[\"2200 Mason St\",\"(b/t Chestnut St & Water St)\",\"North Beach/Telegraph Hill\",\"San Francisco, CA 94133\"],\"geo_accuracy\":8,\"neighborhoods\":[\"North Beach/Telegraph Hill\"],\"postal_code\":\"94133\",\"country_code\":\"US\",\"address\":[\"2200 Mason St\"],\"coordinate\":{\"latitude\":37.803786299999999,\"longitude\":-122.4132116},\"state_code\":\"CA\"}},{\"rating_img_url_small\":\"http://media3.px.yelpcdn.com/static/20101216418129184/i/ico/stars/stars_small_4.png\",\"mobile_url\":\"http://mobile.yelp.com/biz/MNE2e4UoORx_JqJzKTkRlQ\",\"rating_img_url\":\"http://media1.ct.yelpcdn.com/static/201012164084228337/i/ico/stars/stars_4.png\",\"review_count\":69,\"name\":\"Cafe Enchante\",\"url\":\"http://www.yelp.com/biz/cafe-enchante-san-francisco\",\"phone\":\"4152519136\",\"snippet_text\":\"Well...\\n\\nThis spot has a long history, it was cafe Mono at some point, then the name changed to something else, now it is a Parisian cafe Enchante, in any...\",\"image_url\":\"http://media4.px.yelpcdn.com/bphoto/w7PLtmA1Y8m5ylEuuxeNWA/ms\",\"snippet_image_url\":\"http://media3.ct.yelpcdn.com/photo/w2EwrI0IH8bmMw2gVJZ45Q/ms\",\"display_phone\":\"+1-415-251-9136\",\"id\":\"cafe-enchante-san-francisco\",\"categories\":[[\"Coffee & Tea\",\"coffee\"]],\"location\":{\"cross_streets\":\"25th Ave & 26th Ave\",\"city\":\"San Francisco\",\"display_address\":[\"6157 Geary Blvd\",\"(b/t 25th Ave & 26th Ave)\",\"Outer Richmond\",\"San Francisco, CA 94121\"],\"geo_accuracy\":8,\"neighborhoods\":[\"Outer Richmond\"],\"postal_code\":\"94121\",\"country_code\":\"US\",\"address\":[\"6157 Geary Blvd\"],\"coordinate\":{\"latitude\":37.779980899999998,\"longitude\":-122.485698},\"state_code\":\"CA\"}},{\"rating_img_url_small\":\"http://media2.px.yelpcdn.com/static/201012161127761206/i/ico/stars/stars_small_4_half.png\",\"mobile_url\":\"http://mobile.yelp.com/biz/gtxm227hO6ASXkdpCL3bQQ\",\"rating_img_url\":\"http://media4.px.yelpcdn.com/static/201012163106483837/i/ico/stars/stars_4_half.png\",\"review_count\":76,\"name\":\"Old Jerusalem Cafe & Hookah Bar\",\"url\":\"http://www.yelp.com/biz/old-jerusalem-cafe-and-hookah-bar-san-francisco\",\"phone\":\"4156811910\",\"snippet_text\":\"This place is pretty cool. I found it on Scoutmob when I was looking for a place to work that was close to my house, had free wifi, tea, and -surprise!...\",\"image_url\":\"http://media1.px.yelpcdn.com/bphoto/uZFX0Q4OBnlySjP5qC-tPg/ms\",\"snippet_image_url\":\"http://media1.ct.yelpcdn.com/photo/5sqSOCn0yDFNNptX5LJQgA/ms\",\"display_phone\":\"+1-415-681-1910\",\"id\":\"old-jerusalem-cafe-and-hookah-bar-san-francisco\",\"categories\":[[\"Coffee & Tea\",\"coffee\"],[\"Hookah Bars\",\"hookah_bars\"]],\"location\":{\"cross_streets\":\"14th Ave & 15th Ave\",\"city\":\"San Francisco\",\"display_address\":[\"1340 Irving St\",\"(b/t 14th Ave & 15th Ave)\",\"Inner Sunset\",\"San Francisco, CA 94122\"],\"geo_accuracy\":8,\"neighborhoods\":[\"Inner Sunset\"],\"postal_code\":\"94122\",\"country_code\":\"US\",\"address\":[\"1340 Irving St\"],\"coordinate\":{\"latitude\":37.763869800000002,\"longitude\":-122.4723635},\"state_code\":\"CA\"}},{\"rating_img_url_small\":\"http://media3.px.yelpcdn.com/static/20101216418129184/i/ico/stars/stars_small_4.png\",\"mobile_url\":\"http://mobile.yelp.com/biz/0MZHlH2mD2F4GnC6g8JBQQ\",\"rating_img_url\":\"http://media1.ct.yelpcdn.com/static/201012164084228337/i/ico/stars/stars_4.png\",\"review_count\":87,\"name\":\"Cafe La Flore\",\"url\":\"http://www.yelp.com/biz/cafe-la-flore-san-francisco\",\"phone\":\"4153862814\",\"snippet_text\":\"Dear annoying and loud douchebag http://media3.ct.yelpcdn.com/bphoto/W42XSwpqGijj0XgcMw9kpQ/l at one of my favorite cafes,\\n\\nDo you want to buy a time...\",\"image_url\":\"http://media2.px.yelpcdn.com/bphoto/3dJUjoTWv-N85MKai_1dTA/ms\",\"snippet_image_url\":\"http://media1.px.yelpcdn.com/photo/7RxnmbIL2iYbon8ppWRqpw/ms\",\"display_phone\":\"+1-415-386-2814\",\"id\":\"cafe-la-flore-san-francisco\",\"categories\":[[\"Coffee & Tea\",\"coffee\"],[\"Sandwiches\",\"sandwiches\"]],\"location\":{\"cross_streets\":\"11th Ave & 12th Ave\",\"city\":\"San Francisco\",\"display_address\":[\"1032 Clement St\",\"(b/t 11th Ave & 12th Ave)\",\"Inner Richmond\",\"San Francisco, CA 94118\"],\"geo_accuracy\":8,\"neighborhoods\":[\"Inner Richmond\"],\"postal_code\":\"94118\",\"country_code\":\"US\",\"address\":[\"1032 Clement St\"],\"coordinate\":{\"latitude\":37.782671399999998,\"longitude\":-122.47055229999999},\"state_code\":\"CA\"}},{\"rating_img_url_small\":\"http://media3.px.yelpcdn.com/static/20101216418129184/i/ico/stars/stars_small_4.png\",\"mobile_url\":\"http://mobile.yelp.com/biz/AJUBHUHPbneSaAYR9hEZ3g\",\"rating_img_url\":\"http://media1.ct.yelpcdn.com/static/201012164084228337/i/ico/stars/stars_4.png\",\"review_count\":102,\"name\":\"Gallery Cafe\",\"url\":\"http://www.yelp.com/biz/gallery-cafe-san-francisco\",\"phone\":\"4152969932\",\"snippet_text\":\"This is my neighborhood go-to breakfast spot. It's a bit overpriced and cash only, so come prepared. They've got good quiche and overall a cool atmosphere....\",\"image_url\":\"http://media4.ct.yelpcdn.com/bphoto/bvdYkEqQaZjjpMdq8gAkuA/ms\",\"snippet_image_url\":\"http://media3.ct.yelpcdn.com/photo/hDVyyoCeOZx5k_DV7de-8A/ms\",\"display_phone\":\"+1-415-296-9932\",\"id\":\"gallery-cafe-san-francisco\",\"categories\":[[\"Coffee & Tea\",\"coffee\"],[\"Sandwiches\",\"sandwiches\"]],\"location\":{\"cross_streets\":\"Washington St\",\"city\":\"San Francisco\",\"display_address\":[\"1200 Mason St\",\"(b/t Washington St)\",\"San Francisco, CA 94108\"],\"geo_accuracy\":8,\"postal_code\":\"94108\",\"country_code\":\"US\",\"address\":[\"1200 Mason St\"],\"coordinate\":{\"latitude\":37.794569000000003,\"longitude\":-122.411372},\"state_code\":\"CA\"}},{\"rating_img_url_small\":\"http://media1.ct.yelpcdn.com/static/201012163952475669/i/ico/stars/stars_small_3_half.png\",\"mobile_url\":\"http://mobile.yelp.com/biz/w-F9xOVAQaiLINR5VWhOfQ\",\"rating_img_url\":\"http://media3.px.yelpcdn.com/static/201012161235323114/i/ico/stars/stars_3_half.png\",\"review_count\":201,\"name\":\"Duboce Park Cafe\",\"url\":\"http://www.yelp.com/biz/duboce-park-cafe-san-francisco\",\"phone\":\"4156211108\",\"snippet_text\":\"A lovely little place to hang.\\n\\nThe food was great here.  We sat - very relaxed - as the staff and other customers buzzed around us.  We had sandwiches,...\",\"image_url\":\"http://media3.ct.yelpcdn.com/bphoto/kTxMbjD6V2FpSsuIRD3nDA/ms\",\"snippet_image_url\":\"http://media1.ct.yelpcdn.com/photo/pd05ySTICnQePDuVGKancg/ms\",\"display_phone\":\"+1-415-621-1108\",\"id\":\"duboce-park-cafe-san-francisco\",\"categories\":[[\"Coffee & Tea\",\"coffee\"],[\"Sandwiches\",\"sandwiches\"],[\"Breakfast & Brunch\",\"breakfast_brunch\"]],\"location\":{\"city\":\"San Francisco\",\"display_address\":[\"2 Sanchez St\",\"Castro\",\"San Francisco, CA 94110\"],\"geo_accuracy\":8,\"neighborhoods\":[\"Castro\"],\"postal_code\":\"94110\",\"country_code\":\"US\",\"address\":[\"2 Sanchez St\"],\"coordinate\":{\"latitude\":37.769240199999999,\"longitude\":-122.431541},\"state_code\":\"CA\"}},{\"rating_img_url_small\":\"http://media3.px.yelpcdn.com/static/20101216418129184/i/ico/stars/stars_small_4.png\",\"mobile_url\":\"http://mobile.yelp.com/biz/HjKRwtL3gZ2RL3KQULXKsA\",\"rating_img_url\":\"http://media1.ct.yelpcdn.com/static/201012164084228337/i/ico/stars/stars_4.png\",\"review_count\":289,\"name\":\"Velo Rouge Caf\\u00e9\",\"url\":\"http://www.yelp.com/biz/velo-rouge-cafe-san-francisco\",\"phone\":\"4157527799\",\"snippet_text\":\"Breakfast, Lunch, Dinner, Coffee, Beer, and Wine.  All in one spot and everything tasty!  That's as simple as I can get about this place.\\n\\nyou can also come...\",\"image_url\":\"http://media1.ct.yelpcdn.com/bphoto/W_5RWWTMX5T-X96qfYVbXg/ms\",\"snippet_image_url\":\"http://media1.px.yelpcdn.com/photo/8F6e_DbQ5FW1GYC7jxe6iA/ms\",\"display_phone\":\"+1-415-752-7799\",\"id\":\"velo-rouge-cafe-san-francisco\",\"categories\":[[\"Coffee & Tea\",\"coffee\"],[\"Breakfast & Brunch\",\"breakfast_brunch\"],[\"Sandwiches\",\"sandwiches\"]],\"location\":{\"cross_streets\":\"Cabrillo St & Golden Gate Ave\",\"city\":\"San Francisco\",\"display_address\":[\"798 Arguello Blvd\",\"(b/t Cabrillo St & Golden Gate Ave)\",\"Inner Richmond\",\"San Francisco, CA 94118\"],\"geo_accuracy\":8,\"neighborhoods\":[\"Inner Richmond\"],\"postal_code\":\"94118\",\"country_code\":\"US\",\"address\":[\"798 Arguello Blvd\"],\"coordinate\":{\"latitude\":37.775699615478501,\"longitude\":-122.458000183105},\"state_code\":\"CA\"}},{\"rating_img_url_small\":\"http://media3.px.yelpcdn.com/static/20101216418129184/i/ico/stars/stars_small_4.png\",\"mobile_url\":\"http://mobile.yelp.com/biz/cOdvS3Y3utG6qze-quO_4A\",\"rating_img_url\":\"http://media1.ct.yelpcdn.com/static/201012164084228337/i/ico/stars/stars_4.png\",\"review_count\":70,\"name\":\"Borderlands Caf\\u00e9\",\"url\":\"http://www.yelp.com/biz/borderlands-cafe-san-francisco\",\"phone\":\"4159706998\",\"snippet_text\":\"best place ever to have a cup of coffee or such and sit and read. they also have lots and lots of magazines you can brows and read while you hang out.\\nthe...\",\"image_url\":\"http://media3.ct.yelpcdn.com/bphoto/x73Mdcl_HG-oUzLD7aAyVA/ms\",\"snippet_image_url\":\"http://media2.px.yelpcdn.com/photo/N8vi_OpfSd57rezCONUNqQ/ms\",\"display_phone\":\"+1-415-970-6998\",\"id\":\"borderlands-cafe-san-francisco\",\"categories\":[[\"Coffee & Tea\",\"coffee\"]],\"location\":{\"cross_streets\":\"Cunningham Pl & 20th St\",\"city\":\"San Francisco\",\"display_address\":[\"870 Valencia St\",\"(b/t Cunningham Pl & 20th St)\",\"Mission\",\"San Francisco, CA 94110\"],\"geo_accuracy\":8,\"neighborhoods\":[\"Mission\"],\"postal_code\":\"94110\",\"country_code\":\"US\",\"address\":[\"870 Valencia St\"],\"coordinate\":{\"latitude\":37.758982000000003,\"longitude\":-122.42163499999999},\"state_code\":\"CA\"}},{\"rating_img_url_small\":\"http://media3.px.yelpcdn.com/static/20101216418129184/i/ico/stars/stars_small_4.png\",\"mobile_url\":\"http://mobile.yelp.com/biz/0XpZ4HUAkogn7kktGOZQvA\",\"rating_img_url\":\"http://media1.ct.yelpcdn.com/static/201012164084228337/i/ico/stars/stars_4.png\",\"review_count\":88,\"name\":\"Macha Cafe\",\"url\":\"http://www.yelp.com/biz/macha-cafe-san-francisco\",\"phone\":\"4155638079\",\"snippet_text\":\"Found this little cafe while on my adventures of exploring the city.  It is a small cafe that serves GREAT paninis, coffees, and drinks.  The cashier/panini...\",\"image_url\":\"http://media4.px.yelpcdn.com/bphoto/EpfTUv9lUT3iIu9EY_JfbA/ms\",\"snippet_image_url\":\"http://media3.px.yelpcdn.com/photo/ffqzv8WJB2t3f0Z8Bt4qXw/ms\",\"display_phone\":\"+1-415-563-8079\",\"id\":\"macha-cafe-san-francisco\",\"categories\":[[\"Coffee & Tea\",\"coffee\"],[\"Japanese\",\"japanese\"],[\"Sandwiches\",\"sandwiches\"]],\"location\":{\"cross_streets\":\"Franklin St & United States Highway 101\",\"city\":\"San Francisco\",\"display_address\":[\"1355 Sutter St\",\"(b/t Franklin St & United States Highway 101)\",\"Pacific Heights\",\"San Francisco, CA 94109\"],\"geo_accuracy\":8,\"neighborhoods\":[\"Pacific Heights\"],\"postal_code\":\"94109\",\"country_code\":\"US\",\"address\":[\"1355 Sutter St\"],\"coordinate\":{\"latitude\":37.787444000000001,\"longitude\":-122.422719},\"state_code\":\"CA\"}},{\"rating_img_url_small\":\"http://media1.ct.yelpcdn.com/static/201012163952475669/i/ico/stars/stars_small_3_half.png\",\"mobile_url\":\"http://mobile.yelp.com/biz/A1eB91Uz6RrCaQ2YTx3KUg\",\"rating_img_url\":\"http://media3.px.yelpcdn.com/static/201012161235323114/i/ico/stars/stars_3_half.png\",\"review_count\":543,\"name\":\"Sugar Cafe\",\"url\":\"http://www.yelp.com/biz/sugar-cafe-san-francisco\",\"phone\":\"4154415678\",\"snippet_text\":\"The place is gorgeous, very tall ceilings, the staff is very friendly and the brunchy offerings are not bad if you're in the mood. \\n\\nWe had \\\"bottomless\\\"...\",\"image_url\":\"http://media1.px.yelpcdn.com/bphoto/1ZiY1viXRCu4eqGXmf-jgw/ms\",\"snippet_image_url\":\"http://media1.ct.yelpcdn.com/photo/E5CIGfTT6E0PABbkepXb3w/ms\",\"display_phone\":\"+1-415-441-5678\",\"id\":\"sugar-cafe-san-francisco\",\"categories\":[[\"Lounges\",\"lounges\"],[\"Desserts\",\"desserts\"],[\"Coffee & Tea\",\"coffee\"]],\"location\":{\"cross_streets\":\"Taylor St\",\"city\":\"San Francisco\",\"display_address\":[\"679 Sutter St\",\"(b/t Taylor St)\",\"Union Square\",\"San Francisco, CA 94102\"],\"geo_accuracy\":8,\"neighborhoods\":[\"Union Square\"],\"postal_code\":\"94102\",\"country_code\":\"US\",\"address\":[\"679 Sutter St\"],\"coordinate\":{\"latitude\":37.788899999999998,\"longitude\":-122.411597},\"state_code\":\"CA\"}}]}"]
  end

end