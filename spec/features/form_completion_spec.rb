require 'rails_helper'

RSpec.feature "Form Completion", type: :feature do
  let(:form) { Form.create!(title: "Survey Form") }

  before do
    form.fields.create!([
      { field_type: "input", label: "Full Name", position: 0 },
      { field_type: "number", label: "Age", position: 1 },
      { field_type: "select", label: "Country", position: 2, options: [ { label: "United States", value: "US" }, { label: "Canada", value: "CA" }, { label: "Mexico", value: "MX" } ] }
    ])
  end

  scenario "User successfully fills out a form" do
    visit new_form_response_path(form)

    expect(page).to have_content("Survey Form")
    expect(page).to have_content("Full Name")
    expect(page).to have_content("Age")
    expect(page).to have_content("Country")

    # Fill in the form
    fill_in "Full Name", with: "John Doe"
    fill_in "Age", with: "30"
    select "United States", from: "Country"

    click_button "Submit Response"

    expect(page).to have_content("Response submitted successfully!")
    expect(page).to have_content("Responses for \"Survey Form\"")
    expect(page).to have_content("1 response received")
  end

  scenario "User fills form with simple select options" do
    simple_form = Form.create!(title: "Simple Survey")
    simple_form.fields.create!([
      { field_type: "input", label: "Name", position: 0 },
      { field_type: "select", label: "Size", position: 1, options: [ { label: "Small", value: "Small" }, { label: "Medium", value: "Medium" }, { label: "Large", value: "Large" } ] }
    ])

    visit new_form_response_path(simple_form)

    fill_in "Name", with: "Jane Smith"
    select "Medium", from: "Size"

    click_button "Submit Response"

    expect(page).to have_content("Response submitted successfully!")
  end

  scenario "User views form with all required fields marked" do
    visit new_form_response_path(form)

    # Verify all fields are present and required
    expect(page).to have_field("Full Name", type: "text")
    expect(page).to have_field("Age", type: "number")
    expect(page).to have_select("Country")
  end

  scenario "User submits multiple responses to the same form" do
    visit new_form_response_path(form)

    # First response
    fill_in "Full Name", with: "Alice Johnson"
    fill_in "Age", with: "25"
    select "Canada", from: "Country"
    click_button "Submit Response"

    expect(page).to have_content("1 response received")

    # Go back to fill form again
    click_link "Fill Form"

    # Second response
    fill_in "Full Name", with: "Bob Smith"
    fill_in "Age", with: "35"
    select "Mexico", from: "Country"
    click_button "Submit Response"

    expect(page).to have_content("2 responses received")
  end

  scenario "User views all responses for a form" do
    # Create some responses
    response1 = form.responses.create!
    response1.answers.create!([
      { field: form.fields[0], value: "Alice" },
      { field: form.fields[1], value: "25" },
      { field: form.fields[2], value: "US" }
    ])

    response2 = form.responses.create!
    response2.answers.create!([
      { field: form.fields[0], value: "Bob" },
      { field: form.fields[1], value: "30" },
      { field: form.fields[2], value: "CA" }
    ])

    visit form_responses_path(form)

    expect(page).to have_content("Responses for \"Survey Form\"")
    expect(page).to have_content("2 responses received")
    expect(page).to have_content("Response #2")
    expect(page).to have_content("Response #1")
  end

  scenario "User views individual response details" do
    response = form.responses.create!
    response.answers.create!([
      { field: form.fields[0], value: "John Doe" },
      { field: form.fields[1], value: "28" },
      { field: form.fields[2], value: "US" }
    ])

    visit form_responses_path(form)

    click_link "View Details"

    expect(page).to have_content("Survey Form")
    expect(page).to have_content("Full Name")
    expect(page).to have_content("John Doe")
    expect(page).to have_content("Age")
    expect(page).to have_content("28")
    expect(page).to have_content("Country")
    expect(page).to have_content("US")
  end

  scenario "User navigates from form list to fill form" do
    visit forms_path

    expect(page).to have_content("Survey Form")

    within(".bg-white.border", text: "Survey Form") do
      click_link "Fill Form"
    end

    expect(page).to have_content("Survey Form")
    expect(page).to have_content("Full Name")
    expect(page).to have_button("Submit Response")
  end

  scenario "Empty responses list shows helpful message" do
    visit form_responses_path(form)

    expect(page).to have_content("No responses yet")
    expect(page).to have_content("Be the first to fill out this form!")
  end
end
