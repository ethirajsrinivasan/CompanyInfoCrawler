require 'sidekiq/web'
Rails.application.routes.draw do
mount Sidekiq::Web => '/sidekiq'
  resources :companies do
  	member do
  		put :scrap_content
  	end
  end

  resources :contents do
  	collection do
  		get :search
  		get :download
  	end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
