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
  validates :phone_number, format: {with: /\A^[0-9\s]*$+/, message: " must be numbers"}
  validates :emp_id, numericality: true, length: { maximum: 10 }, if: :emp_id_present?
  validates :batch, numericality: true, if: :batch_present?
  validates :gender, inclusion: { in: %w(male female others) }
  validate :validate_dob
  validate :validate_gender
  validates :first_name, format: {with: /\A^[a-zA-Z\s]*$+/, message: " must be character, not special char or number"}
  validates :last_name, format: {with: /\A^[a-zA-Z\s]*$+/, message: " must be character, not special char or number"}

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

  @allowed_attributes = ["emp_id", "display_name", "first_name", "last_name", "batch", "dob", "gender", "thoughtworks_email", "personal_email", "phone_number", "github_username", "slack_username", "dropbox_username"]

  def build_dependents
    build_github
    build_dropbox
    build_slack

    ['ThoughtWorks', 'Personal'].each {|category|
      self.emails.build({category: category})
    }
  end

  def self.search search_term
    joins(:emails).joins(:github).joins(:slack).joins(:dropbox).where(search_query, {:search_term => "%#{search_term}%"})
  end

  def self.import(file)
    interns = {}
    headers = CSV.open(file.path, 'r') {|csv| csv.first}
    invalid_header = is_valid_header headers, @allowed_attributes
    interns[:invalid_header] = invalid_header

    if invalid_header.empty?
      invalid_data = []
      rows = 0
      CSV.foreach(file.path, headers: true) do |row|
        rows += 1
        invalid_data = get_invalid_data invalid_data, row, rows
      end
      return result_formatter interns, invalid_data, rows
    else
      return interns
    end
  end

  def self.csv (file)
    interns = {}
    text_area_data = file.split("\r\n")
    headers = text_area_data[0].split(",")

    invalid_header = is_valid_header headers, @allowed_attributes
    interns[:invalid_header] = invalid_header

    if invalid_header.empty?
      data = text_area_data.drop(1)
      interns_records = get_value_to_csv_format data, headers

      invalid_data = []
      rows = 0
      interns_records.each do |row|
        rows += 1
        invalid_data = get_invalid_data invalid_data, row, rows
      end
      return result_formatter interns, invalid_data, rows
    else
      return interns
    end
  end

  private
  def self.get_invalid_data invalid_data, row, rows
    invalid_data = invalid_data || []
    intern = validate_intern row
    intern[:present_in_TW] = true
    if !intern.save
      invalid_data.push({
        row_number: rows,
        invalid_intern_details: row,
        errors: intern.errors.full_messages
      })
    end
    return invalid_data
  end

  def self.search_query
    (searchable_fields.map {|field|
      "#{field} LIKE :search_term"
    }).join(' OR ')
  end

  def self.searchable_fields
    %w(emp_id display_name first_name last_name emails.address github_info.username slack_info.username dropbox_info.username )
  end

  def self.is_valid_header headers, allowed_attributes
    invalid_header = []
    headers.each do |attr|
      if !allowed_attributes.include?(attr)
        invalid_header.push(attr)
      end
    end
    return invalid_header
  end

  def self.get_value_to_csv_format data, headers
    interns_records = []
    data.each do |row|
      row_object = {}
      row.split(",").each_with_index {|attr, index|
        row_object[headers[index]] = attr}
      interns_records.push(row_object)
    end
    return interns_records
  end

  def self.validate_intern row
    thoughtworks_email = Email.create(category: 'ThoughtWorks', address: row ['thoughtworks_email'])
    personal_email = Email.create(category: 'Personal', address: row['personal_email'])
    github = Github.create(username: row['github_username'])
    slack = Slack.create(username: row['slack_username'])
    dropbox = Dropbox.create(username: row['dropbox_username'])
    intern = Intern.new(
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
    return intern
  end

  def self.result_formatter interns, invalid_data, rows
    interns[:total_rows] = rows
    interns[:failed_rows_number] = invalid_data.count
    interns[:success_rows_number] = rows - invalid_data.count
    interns[:interns_records] = invalid_data
    return interns
  end

  def validate_dob
    if dob != nil && dob >= Date.current
      errors.add('Date of birth', 'must be past')
    end
  end

  def validate_gender
    if gender.blank? || gender.downcase == 'male' || gender.downcase == 'female' || gender.downcase == 'other'
    else
      errors.add('Gender must be', 'Male, Female or Other')
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
