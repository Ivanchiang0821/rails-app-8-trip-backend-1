Rails.application.routes.draw do
  namespace :api, defaults: {format: 'json'} do 
    namespace :v1 do
      get   'search_by_keyword', to: 'places#search_by_keyword'  
      get   'search_by_pid',     to: 'places#search_by_pid'    
      get   'get_pid',           to: 'places#get_pid'      
      get   'get_detail',        to: 'places#get_detail'   
      get   'get_api_count',     to: 'places#get_api_count'   
    end
  end  
end
