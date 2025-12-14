class Form < ApplicationRecord
  has_many :fields, dependent: :destroy
  has_many :responses, dependent: :destroy

  validates :title, presence: true

  accepts_nested_attributes_for :fields, allow_destroy: true
end
