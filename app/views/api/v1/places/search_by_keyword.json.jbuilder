json.next_page_token @response["next_page_token"] if @response["next_page_token"]    
json.search_str params[:str]
json.auto_complete_str @place["description"]
json.auto_complete_lat @coordinate["lat"]
json.auto_complete_lng @coordinate["lng"]

json.results do |json|
	json.array!(@response["results"]) do |r|
		json.name     r["name"]
		json.address  r["vicinity"]
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