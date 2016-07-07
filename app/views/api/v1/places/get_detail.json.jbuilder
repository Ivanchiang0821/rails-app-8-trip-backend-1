json.ori_name           @place["ori_name"]
json.name               @place["name"]
json.address            @place["formatted_address"] if @place["formatted_address"]
json.phone              @place["formatted_phone_number"] if @place["formatted_phone_number"]
json.website            @place["website"] if @place["website"]        
json.rating             @place["rating"] if @place["rating"]
json.pid                @place["place_id"]
json.lat                @place["geometry"]["location"]["lat"]
json.lng                @place["geometry"]["location"]["lng"]
json.user_ratings_total @place["user_ratings_total"]
json.google_map_url     @place["url"]
json.open_now           @place["opening_hours"]["open_now"] if @place["opening_hours"]
json.opening_hours      @place["opening_hours"]["weekday_text"] if @place["opening_hours"]
json.types              @place["types"]    

json.photos do |json|
	json.array!(@place["photos"]) do |p|
		json.width  p["width"]
		json.height p["height"]
		json.photo_url_pre "https://maps.googleapis.com/maps/api/place/photo?maxwidth=#{p["width"]}&photoreference="
		json.photo_ref     p["photo_reference"] + "&key=#{ENV["google_api_key"]}"
	end
end

json.reviews do |json|
	json.array!(@place["reviews"]) do |r|
		json.profile_photo_url r["profile_photo_url"] ? "https:" + r["profile_photo_url"].to_s : nil
		json.rating            r["rating"]      
		json.text              r["text"]      
	end
end
