require 'rails_helper'

RSpec.describe Response, type: :model do
  describe 'validations' do
    it 'is valid with a form' do
      form = Form.create!(title: 'Test Form')
      response = Response.new(form: form)
      expect(response).to be_valid
    end

    it 'is invalid without a form' do
      response = Response.new
      expect(response).not_to be_valid
      expect(response.errors[:form]).to include("must exist")
    end
  end

  describe 'nested attributes' do
    it 'accepts nested attributes for answers' do
      form = Form.create!(title: 'Test Form')
      field_input  = Field.create!(form: form, field_type: 'input', label: 'Name', position: 0)
      field_select = Field.create!(
        form: form,
        label: 'Country',
        field_type: 'select',
        options: [ { label: "Romania", value: nil }, { label: "Italia", value: "it" } ],
        position: 1
      )


      response = Response.create!(
        form: form,
        answers_attributes: [
          { field_id: field_input.id, value: 'John Doe' },
          { field_id: field_select.id, value: 'Romania' }
        ]
      )

      expect(response.answers.count).to eq(2)
      expect(response.answers.first.value).to eq('John Doe')
      expect(response.answers.second.value).to eq('Romania')
    end
  end
end
