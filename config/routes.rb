Peekeweled::Application.routes.draw do
  
  get "/user" => "user#show"
  
  get "/dual" => 'games#new_dual'
  post "/dual" => 'games#create_dual', as: :create_dual
  
  resources :games do
    member { post :end }
    get ":game_two_id" => 'games#dual', as: :dual
  end

  root 'static_pages#home'
  
  get "/about" => 'static_pages#about'
  
  match 'auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  match 'auth/failure', to: redirect('/'), via: [:get, :post]
  match 'signout', to: 'sessions#destroy', as: 'signout', via: [:get, :post]
  
end
