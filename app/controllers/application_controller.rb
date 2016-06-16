class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


  require 'net/http'
  require 'json'

  def auto_complete_by_keyword(keyword)
    google_autocomplete_url = "https://maps.googleapis.com/maps/api/place/autocomplete/json?language=zh-TW&"
    query_string = "input=#{keyword}&"
    api_key = "key=#{ENV["google_api_key"]}"
    url = google_autocomplete_url + query_string + api_key
    encoded_url = URI.encode(url)
    uri = URI.parse(encoded_url)
    JSON.parse(Net::HTTP.get(uri))["predictions"].first    
  end

  def get_geocode_by_pid(pid)
    google_geocode_url = "https://maps.googleapis.com/maps/api/geocode/json?"
    query_string = "place_id=#{pid}&"
    api_key = "key=#{ENV["google_api_key"]}"
    url = google_geocode_url + query_string + api_key
    encoded_url = URI.encode(url)
    uri = URI.parse(encoded_url)
    JSON.parse(Net::HTTP.get(uri))["results"].first["geometry"]["location"]    
  end

  def text_search(keyword, option)
    google_textsearch_url = "https://maps.googleapis.com/maps/api/place/textsearch/json?language=zh-TW&"
    search_option = option == "景點" ? "景點" : option == "餐廳" ? "餐廳|美食|小吃|食物" : option == "購物" ? "便利商店|超市|百貨公司" : ""
    search_keyword = keyword + " " + search_option
    query_string = "query=#{search_keyword}&"      
    api_key = "key=#{ENV["google_api_key"]}"
    url = google_textsearch_url + query_string + api_key
    encoded_url = URI.encode(url)
    uri = URI.parse(encoded_url)
    JSON.parse(Net::HTTP.get(uri))
  end

  def text_search_token(token)
    google_textsearch_url = "https://maps.googleapis.com/maps/api/place/textsearch/json?"
    pagetoken = "pagetoken=#{token}&"      
    api_key = "key=#{ENV["google_api_key"]}"
    url = google_textsearch_url + pagetoken + api_key
    encoded_url = URI.encode(url)
    uri = URI.parse(encoded_url)
    JSON.parse(Net::HTTP.get(uri))
  end

  def nearby_search(lat, lng, option)
    google_nearbysearch_url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?language=zh-TW&"
    keyword = option == "景點" ? "景點" : option == "餐廳" ? "餐廳|美食|小吃|食物" : option == "購物" ? "便利商店|超市|百貨公司" : ""
    query_string = "location=#{lat},#{lng}&rankby=distance&keyword=#{keyword}&"      
    api_key = "key=#{ENV["google_api_key"]}"
    url = google_nearbysearch_url + query_string + api_key
    encoded_url = URI.encode(url)
    uri = URI.parse(encoded_url)
    JSON.parse(Net::HTTP.get(uri))
  end

  def nearby_search_token(token)
    google_nearbysearch_url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
    pagetoken = "pagetoken=#{token}&"      
    api_key = "key=#{ENV["google_api_key"]}"
    url = google_nearbysearch_url + pagetoken + api_key
    encoded_url = URI.encode(url)
    uri = URI.parse(encoded_url)
    JSON.parse(Net::HTTP.get(uri))
  end

  def get_place_detail(pid)
    google_detail_url = "https://maps.googleapis.com/maps/api/place/details/json?language=zh-TW&"
    query_string = "placeid=#{pid}&"
    api_key = "key=#{ENV["google_api_key"]}"
    url = google_detail_url + query_string + api_key
    encoded_url = URI.encode(url)
    uri = URI.parse(encoded_url)
    JSON.parse(Net::HTTP.get(uri))["result"]    
  end

  def get_distance_matrix(origins, destinations)
    google_distance_url = "https://maps.googleapis.com/maps/api/distancematrix/json?language=zh-TW&mode=walking&"
    origins = "origins=#{origins}&"
    destinations = "destinations=#{destinations}&"
    api_key = "key=#{ENV["google_api_key"]}"
    url = google_distance_url + origins + destinations + api_key
    encoded_url = URI.encode(url)
    uri = URI.parse(encoded_url)
    JSON.parse(Net::HTTP.get(uri))["rows"][0]["elements"]
  end 

end
