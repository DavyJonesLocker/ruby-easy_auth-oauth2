module EasyAuth::Oauth2::Routes
  def easy_auth_oauth2_routes
    get  '/sign_in/oauth2/:provider'          => 'sessions#new',    :as => :oauth2_sign_in,  :defaults => { :identity => :oauth2 }
    get  '/sign_in/oauth2/:provider/callback' => 'sessions#create', :as => :oauth2_callback, :defaults => { :identity => :oauth2 }
  end
end
