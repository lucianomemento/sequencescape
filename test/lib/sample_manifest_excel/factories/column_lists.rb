FactoryGirl.define do

  factory :column_list, class: SampleManifestExcel::ColumnList do

    initialize_with { new(build_list(:column, 5)) }

    factory :column_list_with_sanger_sample_id do

      initialize_with { new(build_list(:column, 5).push(build(:sanger_sample_id_column))) }

    end

    factory :column_list_for_plates do

      initialize_with { new(build_list(:column, 5)
                          .push(build(:sanger_sample_id_column))
                          .push(build(:sanger_plate_id_column))
                          .push(build(:well_column))
                            ) 
                      }

    end

    factory :column_list_for_tubes do

      initialize_with { new(build_list(:column, 5)
                          .push(build(:sanger_sample_id_column))
                          .push(build(:sanger_tube_id_column))
                            ) 
                      }
    end

  end

end