Rails.application.routes.draw do
  get 'interns/bulkImport'
  post 'interns/csv'
  get '', to: redirect('/interns')

  resources :interns do
    get 'search', :on => :collection
    collection {post :import}
  end
  root 'interns#index'

end
