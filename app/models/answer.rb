class Answer < ApplicationRecord
  belongs_to :response
  belongs_to :field

  validates :value, presence: true
  validate :numeric_value_for_number_fields

  private

  def numeric_value_for_number_fields
    if field&.field_type_number? && value.present? && !numeric?(value)
      errors.add(:value, "must be a number")
    end
  end

  def numeric?(string)
    Float(string) rescue false
  end
end
