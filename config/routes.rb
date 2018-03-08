Rails.application.routes.draw do
  get 'interns/bulkImport'
  get '', to: redirect('/interns')

  resources :interns do
    get 'search', :on => :collection
    collection {post :import}
  end
  root 'interns#index'

end
