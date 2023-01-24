# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Search", type: :feature do
  scenario "Search" do
    Capybara.enable_aria_label = true

    visit "/"

    fill_in "Query", with: "hackernews"
    click_button "Search"
    expect(page).to have_text("Showing 30 results")

    fill_in "Query", with: "hn limit:10"
    click_button "Search"
    expect(page).to have_text("Showing 10 results")

    fill_in "Query", with: "reddit programming netsec"
    click_button "Search"
    expect(page).to have_text("Showing 25 results")

    fill_in "Query", with: "wikipedia current events"
    click_button "Search"
    expect(page).to have_text("Showing 3 results")
  end
end
