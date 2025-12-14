class Field < ApplicationRecord
  belongs_to :form
  has_many :answers, dependent: :destroy

  enum :field_type, { input: "input", number: "number", select: "select" }, prefix: true

  validates :label, presence: true
  validates :field_type, presence: true, inclusion: { in: field_types.keys }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :options_present_for_select_field

  default_scope { order(position: :asc) }

  def options_for_select
    return [] unless options.is_a?(Array)

    options.map do |opt|
      if opt.is_a?(Hash)
        label = opt["label"] || opt[:label]
        value = opt["value"] || opt[:value]

        [ label, value || label ]
      else
        [ opt, opt ]
      end
    end
  end

  private

  def options_present_for_select_field
    if field_type_select? && (options.blank? || !options.is_a?(Array))
      errors.add(:options, "must be present for select fields")
    end
  end
end
