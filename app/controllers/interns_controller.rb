class InternsController < ApplicationController
  before_action :must_login

  def index
    @interns = Intern.all
  end

  def new
    @intern = Intern.new
    @intern.build_dependents
  end

  def import
      @date = Date.today
      @file_name = params[:file].original_filename
      @interns = Intern.import(params[:file])
      render 'interns/bulkImportResult'
  end

  def csv
      @date = Date.today
      @interns = Intern.csv(params[:csv_data][:data])
      render 'interns/bulkImportResult'
  end

  def show
    @intern = Intern.find(params[:id])
  end

  def edit
    @intern = Intern.find(params[:id])
  end

  def update
    @intern = Intern.find(params[:id])

    if @intern.update(intern_params)
      redirect_to intern_path
    else
      render 'edit'
    end
  end

  def create
    @intern = Intern.new(intern_params)
    if @intern.save
      redirect_to intern_path(@intern)
    else
      render 'new'
    end
  end

  def destroy
    @intern = Intern.find(params[:id])
    @intern.destroy

    redirect_to interns_path
  end

  def search
    @interns = Intern.search(params[:q])

    filtering_params(params).each do |key, value|
      @interns = @interns.public_send(key, value) if value.present?
    end
    @interns = @interns.uniq

    render json: @interns, include: [:github, :emails, :dropbox, :slack] if params[:api]

  end
end

private

  def intern_params
    params.require(:intern).permit(:id, :emp_id, :display_name, :first_name, :last_name, :batch, :gender, :dob, :phone_number,
                                   github_attributes: [:id, :username], slack_attributes: [:id, :username],
                                   dropbox_attributes: [:id, :username],
                                   emails_attributes: [:id, :category, :address])
  end

  def filtering_params(params)
    params.slice(:emp_id, :display_name, :first_name, :last_name, :email, :batch, :dob, :phone_number, :gender,
                 :github_username, :slack_username, :dropbox_username)
  end

  def csv_params
    params.require(:intern).permit(:csv_data)
  end