require 'rails_helper'

RSpec.describe Form, type: :model do
  it 'is valid' do
    expect(Form.new(title: "test")).to be_valid
  end

  context 'without title' do
    it 'is not valid' do
      expect(Form.new).not_to be_valid
    end

    it "returns proper message" do
      form = Form.new
      form.save

      expect(form.errors.messages).to eq({ title: [ "can't be blank" ] })
    end
  end
end
