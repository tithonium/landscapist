require_relative 'common_types'

# /web_services/v1/contacts(.:format)                 web_services/v1/contacts#index
# /web_services/v2/contacts(.:format)                 web_services/v2/contacts#index
# /web_services/v2/accounts(.:format)                 web_services/v2/accounts#index
# /web_services/v2/account/:id/positions(.:format)    web_services/v2/accounts#positions
# /web_services/v2/account/:id/transactions(.:format) web_services/v2/accounts#transactions
# /web_services/v2/account/:id/commissions(.:format)  web_services/v2/accounts#commissions
# /web_services/v2/sessions/token/refresh(.:format)   web_services/v2/sessions#refresh_token

landscape do
  
  namespace :WebServices do
    path '/web_services/{{version}}'
    namespace :V1 do
      version :v1
    
      namespace :Contacts do
    
        payload :Contact do
          param :contact
          name :string
          contact_identifier :string
        end
      
        endpoint :List do
          path '/contacts.json'
          expects :PaginationOptions
          returns pagination: :PaginationDetails, contacts: [:Contact]
        end
    
      end
    
      namespace :Accounts do
    
        payload :AccountSummary do
          param :account
        end
        payload :AccountPosition do
          param :position
        end
        payload :AccountTransaction do
          param :transaction
        end
        
    
        endpoint :List do
          path '/accounts.json'
          expects :PaginationOptions
          returns pagination: :PaginationDetails, accounts: [:AccountSummary]
        end
    
        namespace :AccountDetails do
          path '/{account_identifier}'
        
          endpoint :Positions do
            path '/positions.json'
            expects :PaginationOptions
            returns pagination: :PaginationDetails, positions: [:AccountPosition]
          end
        
          endpoint :Transactions do
            path '/transactions.json'
            expects :PaginationOptions
            returns pagination: :PaginationDetails, transactions: [:AccountTransaction]
          end
        
        end
    
      end
  
    end
    
    namespace :V2 do
      extends :V1
      version :v2
      namespace :Accounts do
        payload :AccountCommission do
          param :commission
        end
        
        namespace :AccountDetails do
          path '/{account_identifier}'
          
          endpoint :Commissions do
            path '/commissions.json'
            expects :PaginationOptions
            returns pagination: :PaginationDetails, commissions: [:AccountCommission]
          end
        end
      end
    end
    
  end
  
end
