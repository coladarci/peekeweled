Peekeweled::Application.routes.draw do
  
  get "/user" => "user#show"
  
  resources :games do
    member { post :end }
  end

  root 'static_pages#home'
  
  get "/play" => "static_pages#play"
  get "/signin" => 'static_pages#signin'
  
  match 'auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  match 'auth/failure', to: redirect('/'), via: [:get, :post]
  match 'signout', to: 'sessions#destroy', as: 'signout', via: [:get, :post]
  
end
