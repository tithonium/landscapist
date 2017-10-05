landscape do
  
  namespace :WebServices do
    
    payload :PaginationOptions do
      offset :integer
      limit :integer
    end
  
  
    payload :PaginationDetails do
      offset :integer
      limit :integer
      page :integer
    end
  
    type :ExternalId do
      param :identifier
    end
    
  end
  
end
