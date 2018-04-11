Rails.application.routes.draw do
  get 'login', to: 'sessions#new'
  delete 'logout', to: 'sessions#destroy'
  post 'login', to: 'sessions#create'

  resources :interns do
    get 'search', :on => :collection
    get 'bulk_import', :on => :collection
    get 'csv', :on => :collection
    collection {post :import}
    member do
      post 'not_in_TW', 'present_in_TW'
    end
  end
  get '', to: redirect('/interns')
  root 'interns#index'

  resources :batches
  root 'batches#index'
end
