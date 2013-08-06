require 'addressable/uri'
require 'rest-client'
require 'json'
require 'nokogiri'
require 'colorize'
class GeoCode

  # print "Please enter your address: Street, City, State:"
  # address = gets.chomp.downcase

  def self.lat_lng(address)
    geo_address = Addressable::URI.new(
    :scheme => "http",
    :host => "maps.googleapis.com",
    :path => "maps/api/geocode/json",
    :query_values => {:address => address, :sensor => false}
    ).to_s

    lat_lng_response = RestClient.get(geo_address)
    lat_lng_JSON = JSON.parse(lat_lng_response)
    lat_lng = lat_lng_JSON["results"].first["geometry"]["location"]
    lat = lat_lng["lat"].to_s
    lng = lat_lng["lng"].to_s
    "#{lat},#{lng}"
  end
end

GeoCode.lat_lng("1061 Market St, San Francisco, CA")

#  address = "1061 Market St, San Francisco, CA"

class Places
  NEW_KEY = "AIzaSyB53uQVbh2_6dNpi6XTtsLb2pCeK31gFEc"

  def self.find_nearby_places(address, keyword, radius = 50)

   places_address = Addressable::URI.new(
     :scheme => "https",
     :host => "maps.googleapis.com",
     :path => "maps/api/place/nearbysearch/json",
     :query_values => {
       :key => NEW_KEY,
       :location => GeoCode.lat_lng(address),
       :radius => radius,
       :sensor => false,
       :keyword => keyword
      }
    ).to_s
    places_response = RestClient.get(places_address)
    places_JSON = JSON.parse(places_response)

 end

 def self.find_nearby_places_lat_lng(address, keyword, radius = 50)
   places_JSON = Places.find_nearby_places(address, keyword, radius)
   places_JSON["results"].map do |result|
     lat_long_hash = result["geometry"]["location"]
     "#{lat_long_hash["lat"]},#{lat_long_hash["lng"]}"
   end
 end

 def self.find_nearby_places_by_name(address, keyword, radius = 50)
   places_JSON = Places.find_nearby_places(address, keyword, radius)
   places_JSON["results"].map { |result| result["name"] }
 end
end

class Directions

  def self.route (origin, destination)
   direction_address = Addressable::URI.new(
     :scheme => "https",
     :host => "maps.googleapis.com",
     :path => "maps/api/directions/json",
     :query_values => {
       :origin => origin,
       :destination => destination,
       :mode => "walking",
       :sensor => false
      }
    ).to_s

    direction_response = RestClient.get(direction_address)
    direction_JSON = JSON.parse(direction_response)
    direction_JSON["routes"][0]["legs"][0]["steps"].each do |step|
      puts Nokogiri::HTML(step["html_instructions"]).text
    end
    print "\n\n"
  end
 end

 class IceCreamFinder
   def self.ice_cream_directions(start_add)
    lat_longs = Places.find_nearby_places_lat_lng(start_add, "ice cream", 300)
    names = Places.find_nearby_places_by_name(start_add, "ice cream", 300)
    lat_longs.length.times do |i|
      destination = lat_longs[i]
      name = names[i]
      puts name.blue
      Directions.route(start_add, destination)
    end
  end
end

