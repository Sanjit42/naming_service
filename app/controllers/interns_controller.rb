class InternsController < ApplicationController

  def index
    @interns = Intern.all
  end

  def new
    @intern = Intern.new
    @intern.build_dependents
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
      redirect_to @intern
    else
      render 'edit'
    end
  end

  def create
    @intern = Intern.new(intern_params)
    @intern.save
    redirect_to @intern
  end

  def search
    @interns = Intern.search(params[:q]) unless params[:q] == nil
  end

  def destroy
    @intern = Intern.find(params[:id])
    @intern.destroy

    redirect_to interns_path
  end
end


private

  def intern_params
    params.require(:intern).permit(:id, :display_name, :first_name, :last_name, :batch,
                                   github_attributes: [:id, :username],
                                   slack_attributes: [:id, :username],
                                   dropbox_attributes: [:id, :username])
  end