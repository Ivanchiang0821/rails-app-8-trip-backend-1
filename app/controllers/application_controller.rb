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
    if option == "景點"
      google_textsearch_url = "https://maps.googleapis.com/maps/api/place/textsearch/json?language=zh-TW&"
      search_option = "景點"
      search_keyword = keyword + " " + search_option
      query_string = "query=#{search_keyword}&"      
      api_key = "key=#{ENV["google_api_key"]}"
      url = google_textsearch_url + query_string + api_key
      encoded_url = URI.encode(url)
      uri = URI.parse(encoded_url)
      result1 = JSON.parse(Net::HTTP.get(uri))

      search_option = "attractions"      
      search_keyword = keyword + " " + search_option
      query_string = "query=#{search_keyword}&"      
      api_key = "key=#{ENV["google_api_key"]}"
      url = google_textsearch_url + query_string + api_key
      encoded_url = URI.encode(url)
      uri = URI.parse(encoded_url)
      result2 = JSON.parse(Net::HTTP.get(uri))

      if result1["results"].count >= result2["results"].count
        result1
      else
        result2
      end

    else
      google_textsearch_url = "https://maps.googleapis.com/maps/api/place/textsearch/json?language=zh-TW&"
      search_option = option == "餐廳" ? "餐廳|美食|小吃|食物|Food" : option == "購物" ? "便利商店|超市|百貨公司|Shopping" : ""
      search_keyword = keyword + " " + search_option
      query_string = "query=#{search_keyword}&"      
      api_key = "key=#{ENV["google_api_key"]}"
      url = google_textsearch_url + query_string + api_key
      encoded_url = URI.encode(url)
      uri = URI.parse(encoded_url)
      JSON.parse(Net::HTTP.get(uri))
    end
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
    keyword = option == "景點" ? "attractions" : option == "餐廳" ? "餐廳|美食|小吃|食物|Food" : option == "購物" ? "便利商店|超市|百貨公司|Shopping" : ""
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

  def get_tripadvisor_info(str)
    require 'open-uri'
    google_link = "https://www.google.com.tw/search?q=" "tripadvisor" + "+" + str + "+" + "10大最佳旅遊景點"  
    encoded_url = URI.encode(google_link)
    uri = URI.parse(encoded_url)    
    doc1 = Nokogiri::HTML(open(uri), nil, "big5")      

    tripadvisor_judge = "/url?q=https://www.tripadvisor.com.tw/Attractions"
    check = doc1.css("a").select{|a| [str,"大最佳旅遊景點"].all?{|s| a.children.text.include?(s)}}

    if check.count > 0
      tripadvisor_link = check[0].attributes["href"].value[7..-1]   
      doc2 = Nokogiri::HTML(open(tripadvisor_link))      

      trip_arr = []
      doc2.css("div.attraction_element").each_with_index do |a, i|
        tmp = Hash.new
        tmp["order"] = (i + 1).to_s
        tmp["title"] = a.css("div.property_title a")[0].text
        tmp["link"] = "https://www.tripadvisor.com.tw" + a.css("div.property_title a")[0]["href"]
        tmp["rate"] = a.css("span.rate img")[0]["alt"].gsub("分","") if a.css("span.rate img")
        tmp["review"] = a.css("span.more a")[0].text.gsub("\n","").gsub("則評論","") if a.css("span.more a")[0]
        trip_arr << tmp
      end
      trip_arr    
    else
      []
    end

  end

end
