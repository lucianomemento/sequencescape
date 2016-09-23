require "test_helper"

class UploadTest < ActiveSupport::TestCase

  attr_reader :column_list

  def setup
    @column_list = build(:column_list_with_sanger_sample_id)
  end

  test "should be valid if all of the headings relate to a column" do
    heading_names = column_list.headings.reverse
    heading_names.pop
    upload = SampleManifestExcel::Upload.new(heading_names, column_list)
    assert_equal heading_names.length, upload.columns.count
    assert upload.valid?
  end

  test "should be invalid if any of the headings do not relate to a column" do
    dodgy_column = build(:column)
    heading_names = column_list.headings << dodgy_column.heading
    upload = SampleManifestExcel::Upload.new(heading_names, column_list)
    refute upload.valid?
    assert_match dodgy_column.heading, upload.errors.full_messages.to_s
  end

  test "should be invalid if there is no sanger sample id column" do
    column_list = build(:column_list)
    upload = SampleManifestExcel::Upload.new(column_list.headings, column_list)
    refute upload.valid?
  end

  context "Row" do

    attr_reader :row, :sample, :valid_values

    setup do
      @sample = create(:sample_with_well)
      @valid_values = column_list.column_values
      valid_values[column_list.find_by(:name, :sanger_sample_id).number-1] = sample.id
    end

    should "not be valid without a valid row number" do
      assert SampleManifestExcel::Upload::Row.new(1, valid_values, column_list).valid?
      refute SampleManifestExcel::Upload::Row.new(nil, valid_values, column_list).valid?
      refute SampleManifestExcel::Upload::Row.new("nil", valid_values, column_list).valid?
    end

    should "not be valid without some data" do
      refute SampleManifestExcel::Upload::Row.new(1, nil, column_list).valid?
    end

    should "not be valid without some columns" do
      refute SampleManifestExcel::Upload::Row.new(1, valid_values, nil).valid?
    end

    should "not be valid without an associated sample" do
      refute SampleManifestExcel::Upload::Row.new(1, column_list.column_values, column_list).valid?
    end

    should "not be valid unless the sample has a primary receptacle" do
      valid_values[column_list.find_by(:name, :sanger_sample_id).number-1] = create(:sample).id
      refute SampleManifestExcel::Upload::Row.new(1, valid_values, column_list).valid?
    end

    context "sample container" do

      context "for plate should only be valid if barcode and location match" do
        
      end

      context "for tube should only be valid if barcodes match" do
      end

    end

  end
    
end