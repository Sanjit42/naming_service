Rails.application.routes.draw do
  get 'login', to: 'sessions#new'
  delete 'logout', to: 'sessions#destroy'
  post 'login', to: 'sessions#create'

  get 'interns/bulkImport'
  post 'interns/csv'
  get '', to: redirect('/interns')

  resources :interns do
    get 'search', :on => :collection
    collection {post :import}
    member do
      post 'not_in_TW', 'present_in_TW'
    end
  end
  root 'interns#index'

end
