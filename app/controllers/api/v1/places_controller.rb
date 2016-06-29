module Api
	module V1
		class PlacesController < ApplicationController
			respond_to :json

		  def get_statistics
		  	@api_count = ApiCount.first
		  	@keyword_count = KeywordCount.all
		  	@pid_count = PidCount.all
		  	@detail_count = DetailCount.all
		  end

		  def search_by_keyword
		  	ApiCount.first.update(cnt_search_by_keyword: ApiCount.first.cnt_search_by_keyword + 1)  
		    #@place = auto_complete_by_keyword(params[:str])

		  	k = KeywordCount.find_by(keyword: params[:str], option: params[:opt])
		  	if k
		  		k.update(count: k.count + 1)  
		  	else
		  		KeywordCount.create(keyword: params[:str], option: params[:opt], count: 1, autocomplete: @place ? true : false)
		  	end

		  	@response = text_search(params[:str], params[:opt]) 

		    if @response["results"].count > 0 and @response["results"].count < 5
		    	@place1 = auto_complete_by_keyword(@response["results"].first["name"]) if @response["results"].count == 1
		    	@place2 = auto_complete_by_keyword(params[:str])
		    	@coordinate1 = get_geocode_by_pid(@place1["place_id"]) if @place1
		    	@coordinate2 = get_geocode_by_pid(@place2["place_id"]) if @place2
		    	@search_area_condition1 = @place1["types"].any? { |s| s.include?('administrative_area') || 
		    																		 				  					s.include?('locality') ||
		    																											  s.include?('postal_code')	|| 
		    																		 									  s.include?('country') || 
		    																											  s.include?('geocode')} if @place1
		    	@search_area_condition2 = @place2["types"].any? { |s| s.include?('administrative_area') || 
		    																											  s.include?('locality') ||
		    																											  s.include?('postal_code')	|| 
		    																											  s.include?('country') || 
		    																											  s.include?('geocode')} if @place2
																									
		    	if @search_area_condition1
		    		@response = nearby_search(@coordinate1["lat"], @coordinate1["lng"], params[:opt])		    
		    	elsif @search_area_condition2
		    		@response = nearby_search(@coordinate2["lat"], @coordinate2["lng"], params[:opt])				    				
		    	elsif @response["results"].count == 1
		    		@response = Hash.new
		    		@response["results"] = Array.new << get_place_detail(@place1["place_id"])
		    	end   
		    elsif @response["results"].count == 0

		    	@response = text_search(params[:str], "") 
			    if @response["results"].count == 1
			    	@place = auto_complete_by_keyword(@response["results"].first["name"])
			    	@coordinate = get_geocode_by_pid(@place["place_id"]) 
			    	@search_area_condition = @place["types"].any? { |s| s.include?('administrative_area') || 
			    																		 				  				s.include?('locality') ||
			    																										  s.include?('postal_code')	|| 
			    																		 								  s.include?('country') || 
			    																										  s.include?('geocode')}	    																											
			    	if @search_area_condition
			    		@response = nearby_search(@coordinate["lat"], @coordinate["lng"], params[:opt])		    		    				
			    	elsif @response["results"].count == 1
			    		@response = Hash.new
			    		@response["results"] = Array.new << get_place_detail(@place["place_id"])
			    	end  
			    end
		    end
				@response["results"] = @response["results"].sort { |a,b| a["rating"] && b["rating"] ? b["rating"] <=> a["rating"] : a["rating"] ? -1 : 1}

		  	# 先使用使用者關鍵字對比Google Auto Complete產生新的關鍵字
		  	# 在使用Google關鍵字搜尋該關鍵字


		    # if @place     	
		    # 	@coordinate = get_geocode_by_pid(@place["place_id"])
		    # 	@search_area_condition = @place["types"].any? { |s| s.include?('administrative_area') || 
		    # 																											s.include?('locality') ||
		    # 																											s.include?('postal_code')	|| 
		    # 																											s.include?('country')}

		    # 	if @search_area_condition

		    # 		@response = text_search(@place["description"], params[:opt])
		    # 		@response["results"] = @response["results"].sort { |a,b| a["rating"] && b["rating"] ? b["rating"] <=> a["rating"] : a["rating"] ? -1 : 1}
		    # 	else
		    # 		@response = Hash.new
		    # 		@response["results"] = Array.new << get_place_detail(@place["place_id"])
		    # 	end

		    # else
		    # 	@response = text_search(params[:str], "") #如果無法match關鍵字, 直接搜尋該字串
		    # end

		  end


		  def search_by_pid
		  	ApiCount.first.update(cnt_search_by_pid: ApiCount.first.cnt_search_by_pid+1)  

		  	p = PidCount.find_by(pid: params[:pid], option: params[:opt])
		  	if p
		  		p.update(count: p.count + 1)  
		  	else
		  		PidCount.create(pid: params[:pid], option: params[:opt], count: 1)
		  	end

		  	# 使用place ID得到座標
		  	# 搜尋該座標附近的景點
		  	# 利用Distance Matrix API得到離搜尋座標的距離
		    @coordinate = get_geocode_by_pid(params[:pid])
		    @response = nearby_search(@coordinate["lat"], @coordinate["lng"], params[:opt])

		    origins = "#{@coordinate["lat"]}, #{@coordinate["lng"]}"
		    destinations = @response["results"].map{|r| "#{r["geometry"]["location"]["lat"]},#{r["geometry"]["location"]["lng"]}"}.join("|")
		    @distance = get_distance_matrix(origins, destinations)

		    @response["results"].each_with_index do |r, i|
		    	if @distance[i]["distance"]
		    		r["distance"] = @distance[i]["distance"]["text"]
		    		r["duration"] = @distance[i]["duration"]["text"]
		    	end
		    end
		  end

		  def search_by_coordinate
		  	ApiCount.first.update(cnt_search_by_coordinate: ApiCount.first.cnt_search_by_coordinate+1)  
		    @response = nearby_search(params["lat"], params["lng"], params[:opt])

		    origins = "#{params["lat"]}, #{params["lng"]}"
		    destinations = @response["results"].map{|r| "#{r["geometry"]["location"]["lat"]},#{r["geometry"]["location"]["lng"]}"}.join("|")
		    @distance = get_distance_matrix(origins, destinations)

		    @response["results"].each_with_index do |r, i|
		    	if @distance[i]["distance"]
		    		r["distance"] = @distance[i]["distance"]["text"]
		    		r["duration"] = @distance[i]["duration"]["text"]
		    	end
		    end		  	
		  end

		  def get_next_page_keyword
		  	ApiCount.first.update(cnt_get_next_page_keyword: ApiCount.first.cnt_get_next_page_keyword + 1)  
		  	@response = text_search_token(params[:token])
		  	@response["results"] = @response["results"].sort { |a,b| a["rating"] && b["rating"] ? b["rating"] <=> a["rating"] : a["rating"] ? -1 : 1}
		  end

		  def get_next_page_pid
		  	ApiCount.first.update(cnt_get_next_page_pid: ApiCount.first.cnt_get_next_page_pid + 1)  
		  	@coordinate = get_geocode_by_pid(params[:pid])
		  	@response = nearby_search_token(params[:token])

		    origins = "#{@coordinate["lat"]}, #{@coordinate["lng"]}"
		    destinations = @response["results"].map{|r| "#{r["geometry"]["location"]["lat"]},#{r["geometry"]["location"]["lng"]}"}.join("|")
		    @distance = get_distance_matrix(origins, destinations)

		    @response["results"].each_with_index do |r, i|
		    	if @distance[i]["distance"]
		    		r["distance"] = @distance[i]["distance"]["text"]
		    		r["duration"] = @distance[i]["duration"]["text"]
		    	end
		    end
		 
		  end

		  def get_pid
			ApiCount.first.update(cnt_get_pid: ApiCount.first.cnt_get_pid+1)  		    		  	
		    @place = auto_complete_by_keyword(params[:str])    
		  end

		  def get_detail
		    ApiCount.first.update(cnt_get_detail: ApiCount.first.cnt_get_detail+1)  		  	
		    @place = get_place_detail(params[:pid])    

		  	d = DetailCount.find_by(pid: params[:pid])
		  	if d
		  		d.update(count: d.count + 1)  
		  	else
		  		DetailCount.create(pid: params[:pid], name: @place["name"], count: 1)
		  	end		    
		  end			
		  
		end
	end
end