require 'rails_helper'

RSpec.describe "Responses", type: :request do
  let(:form) { Form.create!(title: "Test Form") }
  let!(:text_field) { form.fields.create!(field_type: "input", label: "Name", position: 0) }
  let!(:number_field) { form.fields.create!(field_type: "number", label: "Age", position: 1) }
  let!(:select_field) do
    form.fields.create!(
      field_type: "select",
      label: "Country",
      position: 2,
      options: [ { label: "United States", value: "US" }, { label: "Canada", value: "CA" } ]
    )
  end

  describe "GET /forms/:form_id/responses" do
    it "returns http success" do
      get form_responses_path(form)
      expect(response).to have_http_status(:success)
    end

    it "displays all responses for the form" do
      response1 = form.responses.create!
      response1.answers.create!(field: text_field, value: "John")

      response2 = form.responses.create!
      response2.answers.create!(field: text_field, value: "Jane")

      get form_responses_path(form)

      expect(response.body).to include("2 responses received")
    end

    it "shows empty state when no responses exist" do
      get form_responses_path(form)

      expect(response.body).to include("No responses yet")
    end

    it "orders responses by created_at descending" do
      old_response = form.responses.create!(created_at: 2.days.ago)
      new_response = form.responses.create!(created_at: 1.day.ago)

      get form_responses_path(form)

      # Response #2 should appear first (newest)
      expect(response.body).to match(/Response #2.*Response #1/m)
    end
  end

  describe "GET /forms/:form_id/responses/:id" do
    let(:form_response) { form.responses.create! }

    before do
      form_response.answers.create!([
        { field: text_field, value: "John Doe" },
        { field: number_field, value: "30" },
        { field: select_field, value: "US" }
      ])
    end

    it "returns http success" do
      get form_response_path(form, form_response)
      expect(response).to have_http_status(:success)
    end

    it "displays the form title" do
      get form_response_path(form, form_response)

      expect(response.body).to include("Test Form")
    end

    it "displays all answers" do
      get form_response_path(form, form_response)

      expect(response.body).to include("Name")
      expect(response.body).to include("John Doe")
      expect(response.body).to include("Age")
      expect(response.body).to include("30")
      expect(response.body).to include("Country")
      expect(response.body).to include("US")
    end

    it "shows submission timestamp" do
      get form_response_path(form, form_response)

      expect(response.body).to match(/Submitted.*ago/)
    end
  end

  describe "GET /forms/:form_id/responses/new" do
    it "returns http success" do
      get new_form_response_path(form)
      expect(response).to have_http_status(:success)
    end

    it "displays the form title" do
      get new_form_response_path(form)

      expect(response.body).to include("Test Form")
    end

    it "displays all form fields" do
      get new_form_response_path(form)

      expect(response.body).to include("Name")
      expect(response.body).to include("Age")
      expect(response.body).to include("Country")
    end

    it "prepares form for all fields" do
      get new_form_response_path(form)

      # Verify the page includes input elements for all fields
      expect(response.body.scan(/name="response\[answers_attributes\]/).size).to be >= 3
    end

    it "renders correct input types" do
      get new_form_response_path(form)

      expect(response.body).to include('type="text"')
      expect(response.body).to include('type="number"')
      expect(response.body).to include("<select")
    end

    it "displays select options correctly" do
      get new_form_response_path(form)

      expect(response.body).to include("United States")
      expect(response.body).to include("Canada")
    end
  end

  describe "POST /forms/:form_id/responses" do
    let(:valid_params) do
      {
        response: {
          answers_attributes: {
            "0" => { field_id: text_field.id, value: "John Smith" },
            "1" => { field_id: number_field.id, value: "25" },
            "2" => { field_id: select_field.id, value: "US" }
          }
        }
      }
    end

    it "creates a new response" do
      expect {
        post form_responses_path(form), params: valid_params
      }.to change(Response, :count).by(1)

      expect(response).to have_http_status(:redirect)
    end

    it "creates answers for all fields" do
      expect {
        post form_responses_path(form), params: valid_params
      }.to change(Answer, :count).by(3)

      created_response = Response.last
      expect(created_response.answers.count).to eq(3)
    end

    it "stores correct values for answers" do
      post form_responses_path(form), params: valid_params

      created_response = Response.last
      name_answer = created_response.answers.find_by(field: text_field)
      age_answer = created_response.answers.find_by(field: number_field)
      country_answer = created_response.answers.find_by(field: select_field)

      expect(name_answer.value).to eq("John Smith")
      expect(age_answer.value).to eq("25")
      expect(country_answer.value).to eq("US")
    end

    it "redirects to responses index after successful submission" do
      post form_responses_path(form), params: valid_params

      expect(response).to redirect_to(form_responses_path(form))
    end

    it "displays success message after submission" do
      post form_responses_path(form), params: valid_params

      follow_redirect!
      expect(response.body).to include("Response submitted successfully!")
    end

    it "fails with invalid number field" do
      invalid_params = valid_params.deep_dup
      invalid_params[:response][:answers_attributes]["1"][:value] = "not a number"

      expect {
        post form_responses_path(form), params: invalid_params
      }.not_to change(Response, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "fails with missing required fields" do
      invalid_params = {
        response: {
          answers_attributes: {
            "0" => { field_id: text_field.id, value: "" }
          }
        }
      }

      expect {
        post form_responses_path(form), params: invalid_params
      }.not_to change(Response, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "associates response with correct form" do
      post form_responses_path(form), params: valid_params

      created_response = Response.last
      expect(created_response.form).to eq(form)
    end

    it "handles select field with label|value pairs" do
      post form_responses_path(form), params: valid_params

      created_response = Response.last
      country_answer = created_response.answers.find_by(field: select_field)

      # Should store the value, not the label
      expect(country_answer.value).to eq("US")
    end

    it "allows multiple responses for the same form" do
      post form_responses_path(form), params: valid_params

      second_params = valid_params.deep_dup
      second_params[:response][:answers_attributes]["0"][:value] = "Jane Doe"

      expect {
        post form_responses_path(form), params: second_params
      }.to change { form.responses.count }.by(1)

      expect(form.responses.count).to eq(2)
    end
  end

  describe "Response counts and associations" do
    it "increments response count when response is created" do
      expect {
        response = form.responses.create!
        response.answers.create!(field: text_field, value: "Test")
      }.to change { form.responses.count }.by(1)
    end

    it "decrements response count when form is destroyed" do
      form.responses.create!

      expect {
        form.destroy
      }.to change(Response, :count).by(-1)
    end

    it "destroys answers when response is destroyed" do
      response = form.responses.create!
      response.answers.create!(field: text_field, value: "Test")

      expect {
        response.destroy
      }.to change(Answer, :count).by(-1)
    end
  end

  describe "Navigation and links" do
    it "includes back link to form in response new page" do
      get new_form_response_path(form)

      expect(response.body).to include("Back to Form")
    end

    it "includes back link to responses in response show page" do
      form_response = form.responses.create!
      form_response.answers.create!(field: text_field, value: "Test")

      get form_response_path(form, form_response)

      expect(response.body).to include("Back to Responses")
    end

    it "includes link to fill form from responses index" do
      get form_responses_path(form)

      expect(response.body).to include("Fill Form")
    end
  end
end
