require 'rails_helper'

RSpec.feature "Complete Workflow", type: :feature do
  scenario "End-to-end: Create form, fill it, and view responses", js: true do
    # Step 1: User visits the homepage
    visit root_path
    expect(page).to have_content("Forms")

    # Step 2: User creates a new form
    click_link "New Form"
    expect(page).to have_content("Create New Form")

    fill_in "Title", with: "Event Registration"

    # Add text field
    click_button "Add Field"
    all("select[name*='field_type']").first.select("Text Input")
    all("input[name*='[label]']").first.set("Attendee Name")

    # Add number field
    click_button "Add Field"
    all("select[name*='field_type']").last.select("Number")
    all("input[name*='[label]']").last.set("Number of Guests")

    # Add select field with label|value
    click_button "Add Field"
    all("select[name*='field_type']").last.select("Select")
    all("input[name*='[label]']").last.set("Meal Preference")
    all("textarea[name*='[options]']").last.set("Vegetarian Meal|vegetarian\nMeat Meal|meat\nVegan Meal|vegan")

    click_button "Create Form"

    # Step 3: Verify form was created
    expect(page).to have_content("Form was successfully created")
    expect(page).to have_content("Event Registration")
    expect(page).to have_content("3 questions")

    # Step 4: Fill out the form
    click_link "Fill This Form"
    expect(page).to have_content("Event Registration")

    fill_in "Attendee Name", with: "John Smith"
    fill_in "Number of Guests", with: "3"
    select "Vegetarian Meal", from: "Meal Preference"

    click_button "Submit Response"

    # Step 5: Verify response was submitted
    expect(page).to have_content("Response submitted successfully!")
    expect(page).to have_content("1 response received")

    # Step 6: View response details
    click_link "View Details"

    expect(page).to have_content("Event Registration")
    expect(page).to have_content("Attendee Name")
    expect(page).to have_content("John Smith")
    expect(page).to have_content("Number of Guests")
    expect(page).to have_content("3")
    expect(page).to have_content("Meal Preference")
    expect(page).to have_content("vegetarian") # Value is stored

    # Step 7: Go back and submit another response
    click_link "Back to Responses"
    click_link "Fill Form"

    fill_in "Attendee Name", with: "Jane Doe"
    fill_in "Number of Guests", with: "2"
    select "Vegan Meal", from: "Meal Preference"

    click_button "Submit Response"

    # Step 8: Verify both responses are listed
    expect(page).to have_content("2 responses received")

    # Step 9: Navigate back to forms list
    click_link "Back to Form"
    click_link "← Back to Forms"

    expect(page).to have_content("Event Registration")

    # Step 10: Edit the form
    within(".bg-white.border", text: "Event Registration") do
      click_link "Edit"
    end

    fill_in "Title", with: "Event Registration 2024"

    click_button "Update Form"

    expect(page).to have_content("Form was successfully updated")
    expect(page).to have_content("Event Registration 2024")

    # Verify responses are still there
    click_link "View Responses (2)"
    expect(page).to have_content("2 responses received")
  end

  scenario "Form listing shows correct counts and actions" do
    # Create multiple forms with responses
    form1 = Form.create!(title: "Survey 1")
    form1.fields.create!(field_type: "input", label: "Name", position: 0)
    response1 = form1.responses.create!
    response1.answers.create!(field: form1.fields.first, value: "Alice")

    form2 = Form.create!(title: "Survey 2")
    form2.fields.create!([
      { field_type: "input", label: "Email", position: 0 },
      { field_type: "number", label: "Age", position: 1 }
    ])

    visit root_path

    expect(page).to have_content("Survey 1")
    expect(page).to have_content("Survey 2")

    # Check Survey 1 stats
    within(".bg-white.border", text: "Survey 1") do
      expect(page).to have_content("1 question")
      expect(page).to have_link("View")
      expect(page).to have_link("Edit")
      expect(page).to have_button("Delete")
      expect(page).to have_link("Fill Form")
      expect(page).to have_link("View Responses (1)")
    end

    # Check Survey 2 stats
    within(".bg-white.border", text: "Survey 2") do
      expect(page).to have_content("2 questions")
    end
  end

  scenario "User removes a field from form during editing", js: true do
    form = Form.create!(title: "Test Form")
    form.fields.create!([
      { field_type: "input", label: "Keep This", position: 0 },
      { field_type: "input", label: "Remove This", position: 1 }
    ])

    visit edit_form_path(form)

    expect(page).to have_field("Field Label", with: "Keep This")
    expect(page).to have_field("Field Label", with: "Remove This")

    # Remove the second field
    within all(".field-group").last do
      click_button "Remove Field"
    end

    click_button "Update Form"

    expect(page).to have_content("Form was successfully updated")
    expect(page).to have_content("Keep This")
    expect(page).not_to have_content("Remove This")
    expect(page).to have_content("1 question")
  end

  scenario "Navigation links work correctly" do
    form = Form.create!(title: "Navigation Test")
    form.fields.create!(field_type: "input", label: "Question", position: 0)

    # From homepage
    visit root_path
    expect(page).to have_link("Forms App")
    expect(page).to have_link("All Forms")

    # Click on form
    within(".bg-white.border", text: "Navigation Test") do
      click_link "View"
    end

    expect(page).to have_link("← Back to Forms")
    click_link "← Back to Forms"
    expect(page).to have_current_path(forms_path)

    # Navigate to fill form
    visit form_path(form)
    click_link "Fill This Form"
    expect(page).to have_link("← Back to Form")
    click_link "← Back to Form"
    expect(page).to have_current_path(form_path(form))

    # Navigate to responses
    click_link "View Responses (0)"
    expect(page).to have_link("← Back to Form")
    click_link "← Back to Form"
    expect(page).to have_current_path(form_path(form))
  end
end
