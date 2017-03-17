# frozen_string_literal: true
require 'rails_helper'

feature 'SampleManifest controller' do
  def load_manifest_spec
    SampleManifestExcel.configure do |config|
      config.folder = File.join('test', 'data', 'sample_manifest_excel')
      config.load!
    end
  end

  let(:user) { create :user }
  let!(:printer) { create :barcode_printer }
  let!(:supplier) { create :supplier }
  let!(:study) { create :study }
  let(:barcode) { 1000 }
  let(:created_plate) { Plate.find_by(barcode: barcode) }

  shared_examples 'a plate manifest' do
    scenario 'creating manifests' do
      click_link('Create manifest for plates')
      expect(PlateBarcode).to receive(:create).and_return(build(:plate_barcode, barcode: barcode))
      select(study.name, from: 'Study')
      select(supplier.name, from: 'Supplier')
      select('Default Plate', from: 'Template')
      select(printer.name, from: 'Barcode printer')
      select(selected_purpose.name, from: 'Plate purpose') if selected_purpose
      click_button('Create manifest and print labels')
      expect(page).to have_text('Upload a sample manifest')
      expect(created_plate.purpose).to eq(created_purpose)
    end
  end

  background do
    login_user user
    load_manifest_spec
    visit(study_path(study))
    click_link('Sample Manifests')
  end

  context 'with no default' do
    let(:selected_purpose) { false }
    let(:created_purpose) { PlatePurpose.stock_plate_purpose }
    it_behaves_like 'a plate manifest'
  end

  context 'with a selected purpose' do
    let(:selected_purpose) { created_purpose }
    let!(:created_purpose) { create :plate_purpose, stock_plate: true }
    it_behaves_like 'a plate manifest'
  end

  context 'without a type specified' do
    let!(:created_purpose) { create :plate_purpose, stock_plate: true }

    scenario 'indicate the purpose field is used for plates only' do
      visit(new_sample_manifest_path)
      select(created_purpose.name, from: 'Plate purpose')
      expect(page).to have_text('Used for plate manifests only')
    end
  end
end
