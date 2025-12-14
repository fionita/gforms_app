require 'rails_helper'

RSpec.feature "Form Creation", type: :feature do
  scenario "User creates a new form with multiple field types", js: true do
    visit root_path

    # Click on New Form button
    click_link "New Form"

    # Fill in form title
    fill_in "Title", with: "Customer Survey"

    # Add fields - select boxes are available without scoping
    click_button "Add Field"
    all("select[name*='field_type']").first.select("Text Input")
    all("input[name*='[label]']").first.set("Your Name")

    click_button "Add Field"
    all("select[name*='field_type']").last.select("Number")
    all("input[name*='[label]']").last.set("Age")

    click_button "Add Field"
    all("select[name*='field_type']").last.select("Select")
    all("input[name*='[label]']").last.set("Favorite Color")
    all("textarea[name*='[options]']").last.set("Red Color|red\nGreen Color|green\nBlue Color|blue")

    # Submit the form
    click_button "Create Form"

    # Verify form was created
    expect(page).to have_content("Form was successfully created")
    expect(page).to have_content("Customer Survey")
    expect(page).to have_content("Your Name")
    expect(page).to have_content("Age")
    expect(page).to have_content("Favorite Color")
    expect(page).to have_content("3 questions")
  end

  scenario "User creates a form with select field using simple options", js: true do
    visit new_form_path

    fill_in "Title", with: "Registration Form"

    click_button "Add Field"
    all("select[name*='field_type']").first.select("Select")
    all("input[name*='[label]']").first.set("T-Shirt Size")
    all("textarea[name*='[options]']").first.set("Small\nMedium\nLarge")

    click_button "Create Form"

    expect(page).to have_content("Form was successfully created")
    expect(page).to have_content("Registration Form")
    expect(page).to have_content("T-Shirt Size")
  end

  scenario "User cannot create a form without title" do
    visit new_form_path

    click_button "Create Form"

    expect(page).to have_content("prohibited this form from being saved")
    expect(page).to have_content("Title can't be blank")
  end

  scenario "User edits an existing form", js: true do
    form = Form.create!(title: "Old Title")
    form.fields.create!(field_type: "input", label: "Question 1", position: 0)

    visit edit_form_path(form)

    fill_in "Title", with: "New Title"

    # Add another field
    click_button "Add Field"
    all("select[name*='field_type']").last.select("Number")
    all("input[name*='[label]']").last.set("Question 2")

    click_button "Update Form"

    expect(page).to have_content("Form was successfully updated")
    expect(page).to have_content("New Title")
    expect(page).to have_content("Question 2")
  end

  scenario "User deletes a form" do
    form = Form.create!(title: "Form to Delete")

    visit forms_path

    expect(page).to have_content("Form to Delete")

    within(".bg-white.border", text: "Form to Delete") do
      click_button "Delete"
    end

    expect(page).to have_content("Form was successfully destroyed")
    expect(page).not_to have_content("Form to Delete")
  end
end
