require 'rails_helper'

RSpec.describe InternsController, type: :controller do

  before :each do
    allow(controller).to receive(:logged_in?).and_return(true)
  end

  describe 'GET index' do
    it 'should render index template' do
      get :index
      expect(response).to render_template('interns/index')
    end

    it 'should give the list of interns' do
      interns = [double('Intern')]
      expect(Intern).to receive(:all).and_return(interns)
      get :index
      expect(assigns(:interns)).to eq(interns)
    end
  end

  describe 'GET new' do
    it 'should render new template' do
      get :new
      expect(response).to render_template('interns/new')
    end

    it 'should build the new empty intern' do
      get :new
      expect(assigns(:intern)).to be_a_new(Intern)
    end
  end

  describe 'GET show' do

    before(:each) do
      @actual_intern = double('Intern', display_name: 'Intern 1')
      expect(Intern).to receive(:find).with('1').and_return(@actual_intern)
    end

    it 'should render show template' do
      get :show, params: {id: 1}
      expect(response).to render_template('interns/show')
    end

    it 'should find the intern by given id' do
      get :show, params: {id: 1}
      expect(assigns(:intern)).to eq(@actual_intern)
    end
  end

  describe 'GET edit' do

    before(:each) do
      @actual_intern = double('Intern', display_name: 'Intern 1')
      expect(Intern).to receive(:find).with('1').and_return(@actual_intern)
    end

    it 'should render edit template' do
      get :edit, params: {id: 1}
      expect(response).to render_template('interns/edit')
    end

    it 'should find the intern by given id' do
      get :edit, params: {id: 1}
      expect(assigns(:intern)).to eq(@actual_intern)
    end
  end

  describe 'PUT update' do
    before(:each) do
      @intern = double('Intern', id: 'id')
      @intern_attributes = {display_name: 'Intern 1'}

      expect(Intern).to receive(:find).and_return(@intern)
      allow_any_instance_of(InternsController).to receive(:intern_params).and_return(@intern_attributes)
    end

    it 'should redirect to the created intern' do
      expect(@intern).to receive(:update).with(@intern_attributes).and_return(true)

      post :update, params: {id: 'id', display_name: 'Intern 1'}
      expect(response).to redirect_to(intern_path)
    end

    it 'should render edit view when updation fails' do
      expect(@intern).to receive(:update).with(@intern_attributes).and_return(false)

      post :update, params: {id: 'id', display_name: 'Intern 1'}
      expect(response).to render_template('interns/edit')
    end
  end

  # describe 'POST create' do
  #   it 'should redirect to the all interns page after creation of an intern' do
  #     intern = double('Intern', id: 'id')
  #     intern_attributes = {display_name: 'Intern 1'}
  #
  #     allow_any_instance_of(InternsController).to receive(:intern_params).and_return(intern_attributes)
  #     expect(Intern).to receive(:new).with(intern_attributes).and_return(intern)
  #     expect(intern).to receive(:save).and_return(true)
  #
  #     post :create, params: {id: 'id', display_name: 'Intern 1'}
  #
  #     expect(response).to redirect_to(intern_path(intern))
  #   end
  #
  #   it 'should render new when intern is not saved properly' do
  #     intern = double('Intern', id: 'id')
  #     intern_attributes = {display_name: 'Intern 1'}
  #
  #     allow_any_instance_of(InternsController).to receive(:intern_params).and_return(intern_attributes)
  #     expect(Intern).to receive(:new).with(intern_attributes).and_return(intern)
  #     expect(intern).to receive(:save).and_return(false)
  #
  #     post :create, params: {id: 'id', display_name: 'Intern 1'}
  #
  #     expect(response).to render_template('interns/new')
  #   end
  # end

  describe 'DELETE destroy' do
    it 'should delete' do
      intern = double('Intern', id: 'id')

      expect(Intern).to receive(:find).with('id').and_return(intern)
      expect(intern).to receive(:destroy)

      delete :destroy, params: {id: 'id', display_name: 'Intern 1'}

      expect(response).to redirect_to(interns_path)
    end
  end

  describe 'GET search' do
    it 'should return search results as json when api key is set' do
      query = 'QUERY'
      intern = double('Intern', id: 'id')

      expect(Intern).to receive(:search).with(query).and_return([intern])

      get :search, params: {q: query, api: true}

      expect(JSON.parse(response.body)[0]['name']).to eq('Intern')
    end

    it 'should filter the search results based on parameters' do
      query = 'QUERY'
      intern = double('Intern', id: 'id')
      params = { q: query, api: true, emp_id: 'emp_id', display_name: 'display_name', first_name: 'first_name', email: 'email',
                 last_name: 'last_name', batch: 'batch', dob: 'dob', phone_number: 'phone_number', gender: 'gender',
                 github_username: 'github_username', slack_username: 'slack_username', dropbox_username: 'dropbox_username'}

      expect(Intern).to receive(:search).with(query).and_return(intern)

      intern.stub_chain(:emp_id, :display_name, :first_name, :last_name, :email, :batch, :dob, :phone_number, :gender,
                        :github_username, :slack_username, :dropbox_username).and_return([intern])

      get :search, params: params

      expect(JSON.parse(response.body)[0]['name']).to eq('Intern')
    end
  end

  describe 'CSV' do
    describe 'Import CSV' do
      before :each do
        @file = fixture_file_upload('files/data.csv', 'text/csv')
      end
      it 'should import file' do
        post :import, params: {file: @file}
        response.should be_success
      end
    end
    describe 'Text area data' do
      it 'should take csv data' do
        data = "emp_id,display_name,first_name,last_name,batch,dob,gender,thoughtworks_email,personal_email,phone_number,github_username,slack_username,dropbox_username\r\n11,test,,,2,10-03-2001,male,sanjitd@thoughtworks.com,sanjit@gmail.com,9338117863,github42,slack42,dropbox42"
        post :csv, params: {csv_data: {data: data}}
        response.should be_success
      end
    end
  end
end
