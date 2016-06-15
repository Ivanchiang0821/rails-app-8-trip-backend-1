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
		  	# 在使用Google關鍵字搜尋該關鍵字
		    @place = auto_complete_by_keyword(params[:str])
		    @coordinate = get_geocode_by_pid(@place["place_id"])
		    @search_area_condition = !@place["types"] | @place["types"].include?("geocode")

		    if @search_area_condition
		    	@response = text_search(@place["description"], params[:opt])
		    	@response["results"] = @response["results"].sort { |a,b| a["rating"] && b["rating"] ? b["rating"] <=> a["rating"] : a["rating"] ? -1 : 1}
		    	@origin_name, @destination_name, @origin_cor, @destination_cor, @distance = get_max_distance(@response["results"])
		    else
		    	@response = Array.new << get_place_detail(@place["place_id"])
		    end
		  end


		  def search_by_pid
		  	ApiCount.first.update(cnt1: ApiCount.first.cnt1+1)  
		  	# 使用place ID得到座標
		  	# 搜尋該座標附近的景點
		  	# 利用Distance Matrix API得到離搜尋座標的距離
		    @coordinate = get_geocode_by_pid(params[:pid])
		    @response = nearby_search(@coordinate["lat"], @coordinate["lng"], params[:opt])

		    origins = "#{@coordinate["lat"]}, #{@coordinate["lng"]}"
		    destinations = @response["results"].map{|r| "#{r["geometry"]["location"]["lat"]},#{r["geometry"]["location"]["lng"]}"}.join("|")
		    @distance = get_distance_matrix(origins, destinations)

		    @response["results"].each_with_index do |r, i|
		    	r["distance"] = @distance[i]["distance"]["text"]
		    	r["duration"] = @distance[i]["duration"]["text"]
		    end
				@response["results"] = @response["results"].sort { |a,b| a["rating"] && b["rating"] ? b["rating"] <=> a["rating"] : a["rating"] ? -1 : 1}
				@origin_name, @destination_name, @origin_cor, @destination_cor, @distance = get_max_distance(@response["results"])
		  end

		  def get_next_page_keyword
		  	ApiCount.first.update(cnt4: ApiCount.first.cnt4 + 1)  
		  	@response = text_search_token(params[:token])
		  	@response["results"] = @response["results"].sort { |a,b| a["rating"] && b["rating"] ? b["rating"] <=> a["rating"] : a["rating"] ? -1 : 1}
		  	@origin_name, @destination_name, @origin_cor, @destination_cor, @distance = get_max_distance(@response["results"])
		  end

		  def get_next_page_pid
		  	ApiCount.first.update(cnt4: ApiCount.first.cnt4 + 1)  
		  	@response = nearby_search_token(params[:token])
		  	@response["results"] = @response["results"].sort { |a,b| a["rating"] && b["rating"] ? b["rating"] <=> a["rating"] : a["rating"] ? -1 : 1}
		  	@origin_name, @destination_name, @origin_cor, @destination_cor, @distance = get_max_distance(@response["results"])
		  end

		  def get_pid
			ApiCount.first.update(cnt2: ApiCount.first.cnt2+1)  		    		  	
		    @place = auto_complete_by_keyword(params[:str])    
		  end

		  def get_detail
		    ApiCount.first.update(cnt3: ApiCount.first.cnt3+1)  		  	
		    @place = get_place_detail(params[:pid])    
		  end			

		  def get_max_distance(result)

		    cor = result.map{|r| [r["geometry"]["location"]["lat"], r["geometry"]["location"]["lng"]]}
		  	max_distance = 0
		  	max_i = 0
		  	max_j = 0
		  	cor.each_with_index do |cor0, i|
		  		cor.each_with_index do |cor1, j|
		  			unless i==j 
		  				distance = (cor0[0] - cor1[0])**2 + (cor0[1] - cor1[1])**2
		  				if distance > max_distance
		  					max_distance = distance
		  					max_i = i
		  					max_j = j
		  				end
		  			end
		  		end
		  	end		  	
		    ori_name = result[max_i]["name"]
		    des_name  = result[max_j]["name"]
		    ori_cor = [result[max_i]["geometry"]["location"]["lat"], result[max_i]["geometry"]["location"]["lng"]]
		    des_cor = [result[max_j]["geometry"]["location"]["lat"], result[max_j]["geometry"]["location"]["lng"]]
				distance = get_distance_matrix(cor[max_i] * ",", cor[max_j] * ",")[0]["distance"]["value"]

		  	[ori_name, des_name, ori_cor, des_cor, distance]
		  end
		end
	end
end