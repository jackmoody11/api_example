Rails.application.routes.draw do
  resources :listings do
    collection do
      get :lookup
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
