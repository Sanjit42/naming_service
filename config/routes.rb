Rails.application.routes.draw do
  get 'sessions/new'

  get 'sessions/login'

  get 'login', to: 'sessions#new'
  delete 'logout', to: 'sessions#destroy'
  post 'login', to: 'sessions#create'

  get 'interns/bulkImport'
  post 'interns/csv'
  get '', to: redirect('/interns')

  resources :interns do
    get 'search', :on => :collection
    collection {post :import}
  end
  root 'interns#index'

end
