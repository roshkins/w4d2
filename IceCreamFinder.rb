require 'nokogiri'
require 'rest-client'
require 'addressable/uri'
require 'json'

class IceCreamFinder

  API_KEY = "AIzaSyAdBt5KlWpIVOpPW5NrKvYOSVz-Myw1NDw"
  def initialize
    get_current_location
    get_local_ice_cream_shops
    get_directions(@shop_array[pick_shop])
  end

  def get_current_location
    puts "What is your address?"
    address = gets.chomp
    loc_url = Addressable::URI.new(
    :scheme => "http",
    :host => "maps.googleapis.com",
    :path => "maps/api/geocode/json",
    :query_values => {:address => address, :sensor => "false" }
    )
    return_hash = JSON.parse(RestClient.get(loc_url.to_s))
    @current_location = return_hash['results'][0]['geometry']['location']
  end

  def get_local_ice_cream_shops
    loc_url = Addressable::URI.new(
    :scheme => "https",
    :host => "maps.googleapis.com",
    :path => "maps/api/place/nearbysearch/json",
    :query_values => {:key => API_KEY, :radius => 1610, :rankby => "prominence",
      :sensor => "false", :location => @current_location['lat'].to_s + "," \
      + @current_location['lng'].to_s, :keyword => "ice cream shop"}
    )
    @shop_array = []
    return_hash = JSON.parse(RestClient.get(loc_url.to_s))
    return_hash['results'].each do |result|
      @shop_array << {:location => result['geometry']['location'],
        :name => result['name'],
        :address => result['vicinity']}
    end
  end

  def pick_shop
    @shop_array.each_with_index do |shop, idx|
      puts
      puts shop[:name]
      puts shop[:address]
      puts "Option #{idx + 1}"
      puts
    end
    print "What option do you want? Enter a number: "
    Integer(gets.chomp) - 1

  end

  def get_directions(shop_hash)
    loc_url = Addressable::URI.new(
    :scheme => "http",
    :host => "maps.googleapis.com",
    :path => "maps/api/directions/json",
    :query_values => {:mode => "walking", :origin => @current_location['lat'].to_s + "," \
      + @current_location['lng'].to_s,
      :destination => shop_hash[:location]['lat'].to_s + "," \
      + shop_hash[:location]['lng'].to_s,
      :sensor => "false" }
    )
    return_hash = JSON.parse(RestClient.get(loc_url.to_s))
    return_hash['routes'][0]['legs'].each do |leg|
      leg['steps'].each do |step|
        puts Nokogiri::HTML(step['html_instructions']).text
      end
    end
  end
end