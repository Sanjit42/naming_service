require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  describe "Login" do
    before do
      FactoryBot.create(:user)
    end
    it 'should login when username and password are correct' do
      post :create, params: FactoryBot.attributes_for(:user)
      expect(response).to redirect_to (root_path)
    end
    it 'should not login when username and password are correct' do
      user = FactoryBot.attributes_for(:user)
      user[:email] = 0
      post :create, params: user

      expect(flash[:danger]).to match("Your email or password does not match")
      expect(response).to render_template ('new')
    end
  end
  describe "Logout" do
    it 'should log out' do
      delete :destroy
      expect(response).to redirect_to(login_path)
    end
  end
end
