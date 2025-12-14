require 'rails_helper'

RSpec.describe Field, type: :model do
  let(:form) { Form.create!(title: 'Test Form') }

  it 'is valid' do
    field = Field.new(form: form, field_type: 'input', label: 'Name', position: 0)
    expect(field).to be_valid
  end

  describe 'validations' do
    context 'without a form' do
      it 'is invalid' do
        field = Field.new(field_type: 'input', label: 'Name', position: 0)
        expect(field).not_to be_valid
        expect(field.errors[:form]).to include("must exist")
      end
    end

    context 'wihtout a label' do
      it 'is invalid' do
        field = Field.new(form: form, field_type: 'input', position: 0)
        expect(field).not_to be_valid
        expect(field.errors[:label]).to include("can't be blank")
      end
    end

    context 'without a field_type' do
      it 'is invalid' do
        field = Field.new(form: form, label: 'Name', position: 0)
        expect(field).not_to be_valid
        expect(field.errors[:field_type]).to include("can't be blank")
      end
    end

    describe '#position' do
      context 'with a negative value' do
        it 'is invalid' do
          field = Field.new(form: form, field_type: 'input', label: 'Name', position: -1)
          expect(field).not_to be_valid
          expect(field.errors[:position]).to include('must be greater than or equal to 0')
        end
      end

      context 'with a non-integer value' do
        it 'is invalid' do
          field = Field.new(form: form, field_type: 'input', label: 'Name', position: 1.5)
          expect(field).not_to be_valid
          expect(field.errors[:position]).to include('must be an integer')
        end
      end
    end
  end

  describe 'select field validations' do
    it 'is invalid when select field has no options' do
      field = Field.new(form: form, field_type: 'select', label: 'Country', position: 0)
      expect(field).not_to be_valid
      expect(field.errors[:options]).to include('must be present for select fields')
    end

    it 'is invalid when select field has empty options' do
      field = Field.new(form: form, field_type: 'select', label: 'Country', position: 0, options: [])
      expect(field).not_to be_valid
      expect(field.errors[:options]).to include('must be present for select fields')
    end

    it 'is valid when select field has options array' do
      field = Field.new(form: form, field_type: 'select', label: 'Country', position: 0, options: [ { 'label' => 'USA', 'value' => 'us' } ])
      expect(field).to be_valid
    end

    it 'does not require options for input fields' do
      field = Field.new(form: form, field_type: 'input', label: 'Name', position: 0)
      expect(field).to be_valid
    end

    it 'does not require options for number fields' do
      field = Field.new(form: form, field_type: 'number', label: 'Age', position: 0)
      expect(field).to be_valid
    end
  end

  describe 'default_scope' do
    it 'orders fields by position ascending' do
      field3 = Field.create!(form: form, field_type: 'input', label: 'Field 3', position: 2)
      field1 = Field.create!(form: form, field_type: 'input', label: 'Field 1', position: 0)
      field2 = Field.create!(form: form, field_type: 'input', label: 'Field 2', position: 1)

      fields = Field.all
      expect(fields.first).to eq(field1)
      expect(fields.second).to eq(field2)
      expect(fields.third).to eq(field3)
    end
  end
end
