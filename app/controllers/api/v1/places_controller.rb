module Api
	module V1
		class PlacesController < ApplicationController
			respond_to :json

		  def get_api_count
		  	@api_count = ApiCount.first
		  end

		  def search_by_keyword
		  	ApiCount.first.update(cnt0: ApiCount.first.cnt0 + 1)  
		  	# 先使用使用者關鍵字對比Google Auto Complete產生新的關鍵字
		  	# 在使用Google關鍵字得到座標
		  	# 最後搜尋該座標附近的景點
		    @place = auto_complete_by_keyword(params[:str])
		    @coordinate = get_geocode_by_pid(@place["place_id"])
		    @search_area_condition = !@place["types"] | @place["types"].include?("geocode")
		    if @search_area_condition
		    	@response = nearby_search_by_coordinate(@coordinate["lat"], @coordinate["lng"], params[:opt])
		    else
		    	@response = Array.new << get_place_detail(@place["place_id"])
		    end
		  end

		  def get_next_page
		  	ApiCount.first.update(cnt4: ApiCount.first.cnt4 + 1)  
		  	@response = nearby_search_token(params[:token])
		  end

		  def search_by_pid
		  	ApiCount.first.update(cnt1: ApiCount.first.cnt1+1)  
		  	# 使用place ID得到座標
		  	# 搜尋該座標附近的景點
		  	# 利用Distance Matrix API得到離搜尋座標的距離
		    @coordinate = get_geocode_by_pid(params[:pid])
		    @response = nearby_search_by_coordinate(@coordinate["lat"], @coordinate["lng"], params[:opt])

		    origins = "#{@coordinate["lat"]}, #{@coordinate["lng"]}"
		    destinations = @response["results"].map{|r| "#{r["geometry"]["location"]["lat"]},#{r["geometry"]["location"]["lng"]}"}.join("|")
		    @distance = get_distance_matrix(origins, destinations)

		    @response["results"].each_with_index do |r, i|
		    	r["distance"] = @distance[i]["distance"]["text"]
		    	r["duration"] = @distance[i]["duration"]["text"]
		    end

		  end

		  def get_pid
			ApiCount.first.update(cnt2: ApiCount.first.cnt2+1)  		    		  	
		    @place = auto_complete_by_keyword(params[:str])    
		  end

		  def get_detail
		    ApiCount.first.update(cnt3: ApiCount.first.cnt3+1)  		  	
		    @place = get_place_detail(params[:pid])    
		  end			
		end
	end
end