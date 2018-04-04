require 'rails_helper'

RSpec.describe BatchesController, type: :controller do
  before :each do
    allow(controller).to receive(:logged_in?).and_return(true)
  end

  describe 'GET index' do
    it 'should render index template' do
      get :index
      expect(response).to render_template('batches/index')
    end

    it 'should give the list of batches' do
      batches = [double('Batch')]
      expect(Batch).to receive(:all).and_return(batches)
      get :index
      expect(assigns(:batches)).to eq(batches)
    end
  end

  describe 'GET new' do
    it 'should render new template' do
      get :new
      expect(response).to render_template('batches/new')
    end

    it 'should build the new empty batch' do
      get :new
      expect(assigns(:batch)).to be_a_new(Batch)
    end
  end

  describe 'GET show' do

    before(:each) do
      @batch = double('Batch', batch_name: 'Batch 1')
      expect(Batch).to receive(:find).with('1').and_return(@batch)
    end

    it 'should render show template' do
      get :show, params: {id: 1}
      expect(response).to render_template('batches/show')
    end

    it 'should find the batch by given id' do
      get :show, params: {id: 1}
      expect(assigns(:batch)).to eq(@batch)
    end
  end

  describe 'GET edit' do

    before(:each) do
      @batch = double('Batch', batch_name: 'Batch 1')
      expect(Batch).to receive(:find).with('1').and_return(@batch)
    end

    it 'should render edit template' do
      get :edit, params: {id: 1}
      expect(response).to render_template('batches/edit')
    end

    it 'should find the batch by given id' do
      get :edit, params: {id: 1}
      expect(assigns(:batch)).to eq(@batch)
    end
  end

  describe 'PUT update' do
    before(:each) do
      @batch = double('Batch', id: 'id')
      @batch_attributes = {batch_name: 'Batch 1'}

      expect(Batch).to receive(:find).and_return(@batch)
      allow_any_instance_of(BatchesController).to receive(:batch_params).and_return(@batch_attributes)
    end

    it 'should redirect to the created batch' do
      expect(@batch).to receive(:update).with(@batch_attributes).and_return(true)

      post :update, params: {id: 'id', batch_name: 'Batch 1'}
      expect(response).to redirect_to(batches_path)
    end

    it 'should render edit view when updation fails' do
      expect(@batch).to receive(:update).with(@batch_attributes).and_return(false)

      post :update, params: {id: 'id', batch_name: 'Batch 1'}
      expect(response).to render_template('batches/edit')
    end
  end

  describe 'POST create' do
    it 'should redirect to the all batches page after creation of an batch' do
      batch = double('Batch', id: 'id')
      batch_attributes = {batch_name: 'Batch 1'}

      allow_any_instance_of(BatchesController).to receive(:batch_params).and_return(batch_attributes)
      expect(Batch).to receive(:new).with(batch_attributes).and_return(batch)
      expect(batch).to receive(:save).and_return(true)

      post :create, params: {id: 'id', batch_name: 'Batch 1'}

      expect(response).to redirect_to(batches_path)
    end

    it 'should render new when batch is not saved properly' do
      batch = double('Batch', id: 'id')
      batch_attributes = {batch_name: 'Batch 1'}

      allow_any_instance_of(BatchesController).to receive(:batch_params).and_return(batch_attributes)
      expect(Batch).to receive(:new).with(batch_attributes).and_return(batch)
      expect(batch).to receive(:save).and_return(false)

      post :create, params: {id: 'id', batch_name: 'Batch 1'}

      expect(response).to render_template('batches/new')
    end
  end

  describe 'DELETE destroy' do
    it 'should delete' do
      batch = double('Batch', id: 'id')

      expect(Batch).to receive(:find).with('id').and_return(batch)
      expect(batch).to receive(:destroy)

      delete :destroy, params: {id: 'id', batch_name: 'Intern 1'}

      expect(response).to redirect_to(batches_path)
    end
  end

end
