require 'rails_helper'

feature 'Labwhere reception', js: true do
  let(:user) { create :user, email: 'login@example.com' }

  scenario 'user can pool from different tubes to stock and standard mx tubes' do
    login_user user
    visit labwhere_receptions_path
    expect(page).to have_content 'Labwhere Reception'
    select('Library creation freezer', from: 'Sequencescape location')
    fill_in('User barcode or swipecard', with: 12345)
    click_on 'Update locations'
    expect(page).to have_content "Asset barcodes can't be blank"
    fill_in('asset_scan', with: '111')
    within('.barcode_list') do
      expect(page).to have_content '111'
    end
    expect(page).to have_content 'Scanned: 1'
    fill_in('asset_scan', with: 222)
    fill_in('asset_scan', with: 333)
    fill_in('asset_scan', with: 222)
    expect(page).to have_content(222, count: 1)
    expect(page).to have_content 'Scanned: 3'
    first('a', text: 'Remove from list').click
    first('a', text: 'Remove from list').click
    expect(page).to have_content 'Scanned: 1'
  end
end
