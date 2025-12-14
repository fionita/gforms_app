require 'rails_helper'
RSpec.describe Answer, type: :model do
  describe 'validations' do
    it 'validates presence of value' do
      answer = Answer.new
      expect(answer).not_to be_valid
      expect(answer.errors[:value]).to include("can't be blank")
    end

    let(:form) { Form.create!(title: 'Test Form') }
    let(:response) { Response.create!(form: form) }

    context 'when field is a number field' do
      let(:number_field) { Field.create!(form: form, field_type: 'number', label: 'Age', position: 0) }

      it 'validates numeric value for number fields' do
        answer = Answer.new(response: response, field: number_field, value: 'not a number')
        expect(answer).not_to be_valid
        expect(answer.errors[:value]).to include('must be a number')
      end

      it 'accepts valid numeric values' do
        answer = Answer.new(response: response, field: number_field, value: '42')
        expect(answer).to be_valid
      end

      it 'accepts decimal values' do
        answer = Answer.new(response: response, field: number_field, value: '3.14')
        expect(answer).to be_valid
      end

      it 'accepts negative numbers' do
        answer = Answer.new(response: response, field: number_field, value: '-10')
        expect(answer).to be_valid
      end
    end

    context 'when field is a text field' do
      let(:input_field) { Field.create!(form: form, field_type: 'input', label: 'Name', position: 0) }

      it 'accepts any string value' do
        answer = Answer.new(response: response, field: input_field, value: 'John Doe')
        expect(answer).to be_valid
      end
    end

    context 'when field is a select field' do
      let(:select_field) do
        Field.create!(
          form: form,
          field_type: 'select',
          label: 'Country',
          position: 0,
          options: [ { 'label' => 'Romania', 'value' => 'ro' }, { 'label' => 'Japonia', 'value' => 'jp' } ]
        )
      end

      it 'accepts any value' do
        answer = Answer.new(response: response, field: select_field, value: 'ro')
        expect(answer).to be_valid
      end
    end
  end
end
