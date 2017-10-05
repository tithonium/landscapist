landscape do
  
  namespace :Login do
    type :UsernameAndPassword do
    end
    type :OTPDemand do
    end
    type :OTPSwitch do
    end
    type :OTPResponse do
    end
    type :ClassicDemand do
    end
    type :ClassicResponse do
    end
    type :LoginComplete do
    end
    
    path '/login.json'
    
    endpoint :Start do
      expects :UsernameAndPassword
      returns [:OTPDemand, :ClassicDemand, :LoginComplete]
    end
    
    endpoint :SwitchOTP do
      expects :OTPSwitch
      returns :OTPDemand
    end
    
    endpoint :CompleteOTP do
      expects :OTPResponse
      returns [:OTPDemand, :LoginComplete]
    end
    
    endpoint :CompleteClassic do
      expects :ClassicResponse
      returns [:ClassicDemand, :LoginComplete]
    end
    
  end
  
end
