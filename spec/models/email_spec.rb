require 'rails_helper'

RSpec.describe Email, type: :model do
  describe 'associations' do
    it 'should belongs to intern' do
      t = Email.reflect_on_association(:intern)
      expect(t.macro).to eq(:belongs_to)
    end
  end

  describe 'validations' do
    it 'should have category presence validation' do
      email = Email.create
      email.valid?
      email.errors.should have_key(:category)
      expect(email.errors[:category]).to include("can't be blank")
    end

    skip 'should not allow empty address' do
      email = Email.create(:category => 'tw')
      email.valid?
      email.errors.should have_key(:address)
      expect(email.errors[:address]).to include("for category `tw` is invalid")
    end

    it 'should not allow invalid address' do
      email = Email.create(:category => 'personal', :address => "some@some")
      email.valid?
      email.errors.should have_key(:address)
      expect(email.errors[:address]).to include("for category `personal` is invalid")
    end

    it 'should allow valid address' do
      email = Email.create(:category => 'personal', :address => "some@some.com")
      email.valid?
      email.errors.should_not have_key(:address)
    end

  end
end
