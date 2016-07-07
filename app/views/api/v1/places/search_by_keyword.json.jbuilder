json.results_count @response["results"].count

if @response["results"].count > 0
	json.search_str params[:str]
	json.next_page_token @response["next_page_token"] if @response["next_page_token"]    

	json.results do |json|
		json.array!(@response["results"]) do |r|
			json.ori_name r["ori_name"]
			json.name     r["name"]
			json.address  r["formatted_address"]
			json.lat      r["geometry"]["location"]["lat"]
			json.lng      r["geometry"]["location"]["lng"]
			json.pid      r["place_id"]
			json.rating   r["rating"]				
			
			if r["photos"]
			  json.photo_url_pre  "https://maps.googleapis.com/maps/api/place/photo?maxwidth=#{r["photos"][0]["width"]}&photoreference="
			  json.photo_ref      r["photos"][0]["photo_reference"] + "&key=#{ENV["google_api_key"]}"
			  json.photo_width    r["photos"][0]["width"]
			  json.photo_height   r["photos"][0]["height"]       
	    end
			
			json.types    r["types"]
		end
	end

else	
	json.search_str params[:str]
	json.results do |json|
		json.array!(@response["results"]) do |r|
		end
	end
end

if @response["tripadvisor"].count > 0
	json.tripadvisor do |json|
		json.array!(@response["tripadvisor"]) do |t|
			json.order    t["order"]
			json.title    t["title"]
			json.link     t["link"]
			json.rate     t["rate"]
			json.review   t["review"]
		end
	end
end