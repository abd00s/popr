class Event < ActiveRecord::Base
  has_one :movie
  belongs_to :host, class_name: "User", foreign_key: "host_id"
  has_many :comments
  has_many :commitments
end