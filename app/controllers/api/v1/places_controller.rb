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

				@response = text_search(params[:str], "") 

	    	@place = auto_complete_by_keyword(params[:str])
	    	@search_area_condition = @place["types"].any? { |s| s.include?('administrative_area') || 
	    																		 				  				s.include?('locality') ||
	    																										  s.include?('postal_code')	|| 
	    																		 								  s.include?('country')} if @place 
@debug = 888

		  	if @response["results"].count == 1 && (@place.nil? || (@place && !@search_area_condition))
	    		@debug = 21
		  	else 
		  		@response = text_search(params[:str], params[:opt]) 

			    if @response["results"].count > 0 and @response["results"].count < 5 
			    	@coordinate = get_geocode_by_pid(@place["place_id"]) if @place
			    	@search_area_condition = @place["types"].any? { |s| s.include?('administrative_area') || 
			    																		 				  					s.include?('locality') ||
			    																											  s.include?('postal_code')	|| 
			    																		 									  s.include?('country')} if @place																								
	    																											  
			    	if @search_area_condition 
			    		@response_new = nearby_search(@coordinate["lat"], @coordinate["lng"], params[:opt])		    
			    		if @response_new["results"].count > @response["results"].count
			    			@response = @response_new
			    			@debug = 12
			    		end
			    	end   
			    elsif @response["results"].count == 0
			    	if @place
			    		@coordinate = get_geocode_by_pid(@place["place_id"]) 
				    	@search_area_condition = @place["types"].any? { |s| s.include?('administrative_area') || 
				    																		 			  					s.include?('locality') ||
				    																										  s.include?('postal_code')	|| 
				    																		 								  s.include?('country')} 
				    	if @search_area_condition																	 								      		
			    			@response = nearby_search(@coordinate["lat"], @coordinate["lng"], params[:opt])		
			    			@debug = 13
			    		else
				    		@response = Hash.new
				    		@response["results"] = Array.new << get_place_detail(@place["place_id"])
				    		@debug = 22
			    		end    
			    	else
					  	if params[:str].empty?
					  		english_name = [params[:str]]
					  	else
					  		chinese_name, english_name = google_translate([params[:str]])
					  	end
					  	english_name = english_name.first	
					  	@response = text_search(english_name, params[:opt]) 	
					  	@debug = 31
				    end
				  else
				    @debug = 11
			    end
			  end

				@response["results"] = @response["results"].sort { |a,b| a["rating"] && b["rating"] ? b["rating"] <=> a["rating"] : a["rating"] ? -1 : 1}
		  	chinese_results, english_results = google_translate(@response["results"].map{|r| r["name"]}) if @response["results"].count > 0
		  	@response["results"].each_with_index do |r, i|
		  		r["ori_name"] = r["name"]
		  		r["name"] = chinese_results[i]
		  		r["eng_name"] = english_results[i]
		  	end

		  	tripadvisor_result = get_tripadvisor_info(params[:str])
		  	@response["tripadvisor"] = tripadvisor_result


		  	k = KeywordCount.find_by(keyword: params[:str], option: params[:opt])
		  	if k
		  		k.update(count: k.count + 1)  
		  	else
		  		KeywordCount.create(keyword: params[:str], option: params[:opt], 
		  			                  count: 1, debug: @debug, 
		  			                  r_count: @response["results"].count, 
		  			                  ta_count: @response["tripadvisor"].count, 
		  			                  autocomplete: @place ? true : false)
		  	end		  	
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

		  	chinese_results, english_results = google_translate(@response["results"].map{|r| r["name"]})
		  	@response["results"].each_with_index do |r, i|
		  		r["ori_name"] = r["name"]
		  		r["name"] = chinese_results[i]
		  		r["eng_name"] = english_results[i]
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

		  	chinese_results, english_results = google_translate(@response["results"].map{|r| r["name"]})
		  	@response["results"].each_with_index do |r, i|
		  		r["ori_name"] = r["name"]
		  		r["name"] = chinese_results[i]
		  		r["eng_name"] = english_results[i]
		  	end	      	
		  end

		  def get_next_page_keyword
		  	ApiCount.first.update(cnt_get_next_page_keyword: ApiCount.first.cnt_get_next_page_keyword + 1)  
		  	@response = text_search_token(params[:token])
		  	@response["results"] = @response["results"].sort { |a,b| a["rating"] && b["rating"] ? b["rating"] <=> a["rating"] : a["rating"] ? -1 : 1}

		  	chinese_results, english_results = google_translate(@response["results"].map{|r| r["name"]})
		  	@response["results"].each_with_index do |r, i|
		  		r["ori_name"] = r["name"]
		  		r["name"] = chinese_results[i]
		  		r["eng_name"] = english_results[i]
		  	end	  	
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

		  	chinese_results, english_results = google_translate(@response["results"].map{|r| r["name"]})
		  	@response["results"].each_with_index do |r, i|
		  		r["ori_name"] = r["name"]
		  		r["name"] = chinese_results[i]
		  		r["eng_name"] = english_results[i]
		  	end    
		 
		  end

		  def get_pid
				ApiCount.first.update(cnt_get_pid: ApiCount.first.cnt_get_pid+1)  		    		  	
		    @place = auto_complete_by_keyword(params[:str])    
		  end

		  def get_detail
		    ApiCount.first.update(cnt_get_detail: ApiCount.first.cnt_get_detail+1)  		  	
		    @place = get_place_detail(params[:pid])    

		  	chinese_result, english_result = google_translate([@place["name"]])
		  	@place["ori_name"] = @place["name"] 
		  	@place["name"] = chinese_result.first
		  	@place["eng_name"] = english_result.first

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