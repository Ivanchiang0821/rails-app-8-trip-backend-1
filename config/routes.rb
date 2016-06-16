Rails.application.routes.draw do
  namespace :api, defaults: {format: 'json'} do 
    namespace :v1 do
      get   'search_by_keyword',     to: 'places#search_by_keyword'  
      get   'search_by_pid',         to: 'places#search_by_pid'    
      get   'search_by_coordinate',  to: 'places#search_by_coordinate'      
      get   'get_pid',               to: 'places#get_pid'      
      get   'get_detail',            to: 'places#get_detail'   
      get   'get_statistics',        to: 'places#get_statistics'   
      get   'get_next_page_keyword', to: 'places#get_next_page_keyword'          
      get   'get_next_page_pid',     to: 'places#get_next_page_pid'
    end
  end  
end
