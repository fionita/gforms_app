class Response < ApplicationRecord
  belongs_to :form
  has_many :answers, dependent: :destroy

  accepts_nested_attributes_for :answers
end
