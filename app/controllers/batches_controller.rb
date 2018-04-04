class BatchesController < ApplicationController
  before_action :must_login

  def new
    @batch = Batch.new
  end

  def index
    @batches = Batch.all
  end

  def create
   @batch = Batch.new(batch_params)
    if@batch.save
      redirect_to batches_path
    else
      render 'new'
    end
  end

  def show
    @batch = Batch.find(params[:id])
  end

  def edit
    @batch = Batch.find(params[:id])
  end

  def update
    @batch = Batch.find(params[:id])
    if @batch.update(batch_params)
      redirect_to batches_path
    else
      render 'edit'
    end
  end

  def destroy
    batch = Batch.find(params[:id])
    batch.destroy
    redirect_to batches_path
  end

  private
    def batch_params
      params.require(:batch).permit(:batch_name, :start_date, :end_date)
    end
end
