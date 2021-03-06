# This file is part of SEQUENCESCAPE; it is distributed under the terms of
# GNU General Public License version 1 or later;
# Please refer to the LICENSE and README files for information on licensing and
# authorship of this file.
# Copyright (C) 2015 Genome Research Ltd.
class CreateCreateStripTubesRequest < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      RequestType.create!(
        :name => 'Illumina-HTP Strip Tube Creation',
        :key  => 'illumina_htp_strip_tube_creation',
        :workflow => Submission::Workflow.find_by_key!("short_read_sequencing"),
        :asset_type => "Well",
        :order => 2,
        :initial_state => "pending",
        :multiples_allowed => true,
        :request_class_name => "StripCreationRequest",
        :for_multiplexing => false,
        :billable => false,
        :product_line => ProductLine.find_by_name!("Illumina-B")
      )
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      RequestType.find_by_key!('strip_tube_creation').destroy
    end
  end
end
