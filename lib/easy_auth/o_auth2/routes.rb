module EasyAuth::OAuth2::Routes
  def easy_auth_o_auth2_routes
    get  '/sign_in/o_auth2/:provider'          => 'sessions#new',    :as => :o_auth2_sign_in,  :defaults => { :identity => :o_auth2 }
    get  '/sign_in/o_auth2/:provider/callback' => 'sessions#create', :as => :o_auth2_callback, :defaults => { :identity => :o_auth2 }
  end
end
