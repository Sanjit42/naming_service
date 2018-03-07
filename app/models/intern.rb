class Intern < ApplicationRecord
  require 'csv'

  has_many :emails, dependent: :delete_all
  has_one :github, dependent: :destroy
  has_one :slack, dependent: :destroy
  has_one :dropbox, dependent: :destroy

  accepts_nested_attributes_for :github
  accepts_nested_attributes_for :slack
  accepts_nested_attributes_for :dropbox
  accepts_nested_attributes_for :emails

  validates :emp_id, :display_name, :first_name, :dob, :batch, :gender, presence: true
  validates :phone_number, numericality: true, length: { is: 10 }, if: :phone_number_present?
  validates :emp_id, numericality: true, length: { maximum: 10 }, if: :emp_id_present?
  validates :batch, numericality: true, if: :batch_present?
  validates :gender, inclusion: { in: %w(male female others) }
  validate :validate_dob

  scope :emp_id, -> (emp_id) { where emp_id: emp_id }
  scope :display_name, -> (display_name) { where display_name: display_name }
  scope :first_name, -> (first_name) { where first_name: first_name }
  scope :last_name, -> (last_name) { where last_name: last_name }
  scope :batch, -> (batch) { where batch: batch }
  scope :dob, -> (dob) { where dob: dob }
  scope :phone_number, -> (phone_number) { where phone_number: phone_number }
  scope :gender, -> (gender) { where gender: gender }
  scope :email, -> (address) { joins(:emails).merge(Email.address(address)) }
  scope :github_username, -> (username) { joins(:github).merge(Github.username(username)) }
  scope :dropbox_username, -> (username) { joins(:dropbox).merge(Dropbox.username(username)) }
  scope :slack_username, -> (username) { joins(:slack).merge(Slack.username(username)) }

  def build_dependents
    build_github
    build_dropbox
    build_slack

    ['ThoughtWorks', 'Personal'].each { |category|
      self.emails.build({category: category})
    }
  end

  def self.search search_term
    joins(:emails).joins(:github).joins(:slack).joins(:dropbox).where(search_query, {:search_term => "%#{search_term}%"})
  end

  def self.import(file)
    CSV.foreach(file.path, headers:true) do |row|
      thoughtworks_email = Email.create(category: 'ThoughtWorks', address: row['thoughtworks_email'])
      personal_email = Email.create(category: 'Personal', address: row['personal_email'])
      github = Github.create(row['username'])
      slack = Slack.create(row['username'])
      dropbox = Dropbox.create(row['username'])
      imported_intern = Intern.new(
          emp_id: row['emp_id'],
          display_name: row['display_name'],
          first_name: row['first_name'],
          last_name: row['last_name'],
          batch: row['batch'],
          dob: row['dob'],
          gender: row['gender'],
          phone_number: row['phone_number'],
          emails: [thoughtworks_email, personal_email],
          github: github,
          slack: slack,
          dropbox: dropbox
      )
      imported_intern.save
    end
  end

  private
  def self.search_query
    (searchable_fields.map { |field|
      "#{field} LIKE :search_term"
    }).join(' OR ')
  end

  def self.searchable_fields
    %w(emp_id display_name first_name last_name emails.address github_info.username slack_info.username dropbox_info.username )
  end


  def validate_dob
    if dob != nil && dob >= Date.current
      errors.add('Date of birth', 'must be past')
    end
  end

  def phone_number_present?
    !phone_number.blank?
  end

  def emp_id_present?
    !emp_id.blank?
  end

  def batch_present?
    !batch.blank?
  end
end
