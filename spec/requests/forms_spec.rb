require 'rails_helper'

RSpec.describe "Forms", type: :request do
  describe "GET /forms" do
    it "returns http success" do
      get forms_path
      expect(response).to have_http_status(:success)
    end

    it "displays all forms" do
      Form.create!(title: "Form 1")
      Form.create!(title: "Form 2")

      get forms_path

      expect(response.body).to include("Form 1")
      expect(response.body).to include("Form 2")
    end

    it "shows empty state when no forms exist" do
      get forms_path

      expect(response.body).to include("No forms yet")
    end
  end

  describe "GET /forms/:id" do
    it "returns http success" do
      form = Form.create!(title: "Test Form")
      get form_path(form)
      expect(response).to have_http_status(:success)
    end

    it "displays form details" do
      form = Form.create!(title: "Survey Form")
      form.fields.create!(field_type: "input", label: "Name", position: 0)

      get form_path(form)

      expect(response.body).to include("Survey Form")
      expect(response.body).to include("Name")
    end

    it "shows field count" do
      form = Form.create!(title: "Test Form")
      form.fields.create!([
        { field_type: "input", label: "Q1", position: 0 },
        { field_type: "number", label: "Q2", position: 1 }
      ])

      get form_path(form)

      expect(response.body).to include("2 questions")
    end
  end

  describe "GET /forms/new" do
    it "returns http success" do
      get new_form_path
      expect(response).to have_http_status(:success)
    end

    it "displays form builder" do
      get new_form_path

      expect(response.body).to include("Create New Form")
      expect(response.body).to include("Add Field")
    end
  end

  describe "POST /forms" do
    it "creates a new form with title only" do
      expect {
        post forms_path, params: { form: { title: "New Form" } }
      }.to change(Form, :count).by(1)

      expect(response).to have_http_status(:redirect)
      expect(Form.last.title).to eq("New Form")
    end

    it "creates a form with fields" do
      form_params = {
        form: {
          title: "Survey",
          fields_attributes: {
            "0" => { field_type: "input", label: "Name", position: 0 },
            "1" => { field_type: "number", label: "Age", position: 1 }
          }
        }
      }

      expect {
        post forms_path, params: form_params
      }.to change(Form, :count).by(1).and change(Field, :count).by(2)

      form = Form.last
      expect(form.fields.count).to eq(2)
      expect(form.fields.first.label).to eq("Name")
    end

    it "creates a form with select field using label|value format" do
      form_params = {
        form: {
          title: "Registration",
          fields_attributes: {
            "0" => {
              field_type: "select",
              label: "Size",
              position: 0,
              options: "Small|s\nMedium|m\nLarge|l"
            }
          }
        }
      }

      post forms_path, params: form_params

      field = Form.last.fields.first
      expect(field.options).to be_an(Array)
      expect(field.options.first).to include("label" => "Small", "value" => "s")
    end

    it "creates a form with select field using simple format" do
      form_params = {
        form: {
          title: "Simple",
          fields_attributes: {
            "0" => {
              field_type: "select",
              label: "Color",
              position: 0,
              options: "Red\nGreen\nBlue"
            }
          }
        }
      }

      post forms_path, params: form_params

      field = Form.last.fields.first
      expect(field.options.first).to include("label" => "Red", "value" => nil)
    end

    it "fails without title" do
      expect {
        post forms_path, params: { form: { title: "" } }
      }.not_to change(Form, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "redirects to form show page after creation" do
      post forms_path, params: { form: { title: "New Form" } }

      expect(response).to redirect_to(form_path(Form.last))
    end
  end

  describe "GET /forms/:id/edit" do
    it "returns http success" do
      form = Form.create!(title: "Test Form")
      get edit_form_path(form)
      expect(response).to have_http_status(:success)
    end

    it "displays existing form data" do
      form = Form.create!(title: "Old Form")
      form.fields.create!(field_type: "input", label: "Question", position: 0)

      get edit_form_path(form)

      expect(response.body).to include("Old Form")
      expect(response.body).to include("Question")
    end
  end

  describe "PATCH /forms/:id" do
    it "updates the form title" do
      form = Form.create!(title: "Old Title")

      patch form_path(form), params: { form: { title: "New Title" } }

      expect(response).to have_http_status(:redirect)
      expect(form.reload.title).to eq("New Title")
    end

    it "updates form fields" do
      form = Form.create!(title: "Test")
      field = form.fields.create!(field_type: "input", label: "Old Label", position: 0)

      patch form_path(form), params: {
        form: {
          title: "Test",
          fields_attributes: {
            "0" => { id: field.id, label: "New Label", field_type: "input", position: 0 }
          }
        }
      }

      expect(field.reload.label).to eq("New Label")
    end

    it "adds new fields to existing form" do
      form = Form.create!(title: "Test")
      form.fields.create!(field_type: "input", label: "Q1", position: 0)

      expect {
        patch form_path(form), params: {
          form: {
            title: "Test",
            fields_attributes: {
              "0" => { field_type: "number", label: "Q2", position: 1 }
            }
          }
        }
      }.to change { form.fields.count }.by(1)
    end

    it "removes fields marked for destruction" do
      form = Form.create!(title: "Test")
      field = form.fields.create!(field_type: "input", label: "Remove Me", position: 0)

      expect {
        patch form_path(form), params: {
          form: {
            title: "Test",
            fields_attributes: {
              "0" => { id: field.id, _destroy: "1" }
            }
          }
        }
      }.to change { form.fields.count }.by(-1)
    end

    it "fails with invalid data" do
      form = Form.create!(title: "Test")

      patch form_path(form), params: { form: { title: "" } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(form.reload.title).to eq("Test")
    end
  end

  describe "DELETE /forms/:id" do
    it "destroys the form" do
      form = Form.create!(title: "Test Form")

      expect {
        delete form_path(form)
      }.to change(Form, :count).by(-1)

      expect(response).to have_http_status(:redirect)
    end

    it "destroys associated fields" do
      form = Form.create!(title: "Test")
      form.fields.create!(field_type: "input", label: "Q1", position: 0)

      expect {
        delete form_path(form)
      }.to change(Field, :count).by(-1)
    end

    it "destroys associated responses" do
      form = Form.create!(title: "Test")
      form.responses.create!

      expect {
        delete form_path(form)
      }.to change(Response, :count).by(-1)
    end

    it "redirects to forms index" do
      form = Form.create!(title: "Test")

      delete form_path(form)

      expect(response).to redirect_to(forms_path)
    end
  end
end
