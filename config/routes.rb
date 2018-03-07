Rails.application.routes.draw do

  get 'interns/bulkImport'
  get '', to: redirect('/interns')

  resources :interns do
    get 'search', :on => :collection
  end

end
