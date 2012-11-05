module EasyAuth::Oauth2
  class Engine < ::Rails::Engine
    isolate_namespace EasyAuth::Oauth2

    config.generators do |g|
      g.test_framework :rspec, :view_specs => false
    end
  end
end
