#This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
# Please refer to the LICENSE and README files for information on licensing and
# authorship of this file.
# Copyright (C) 2013 Genome Research Ltd.
class MoveCohortUuidsToDonorId < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      count = 0
      Sample::Metadata.find_each(:conditions=>"cohort REGEXP '^[0-9a-f]{8}\-[0-9a-f]{4}\-[0-9a-f]{4}\-[0-9a-f]{4}\-[0-9a-f]{12}$'") do |sm|
        unless sm.donor_id.present?
          sm.update_attributes!(:donor_id => sm.cohort)
          count += 1
        end
      end
      say "#{count} samples updated"
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      count = 0
      Sample::Metadata.find_each(:conditions=>"donor_id REGEXP '^[0-9a-f]{8}\-[0-9a-f]{4}\-[0-9a-f]{4}\-[0-9a-f]{4}\-[0-9a-f]{12}$'") do |sm|
        if sm.donor_id == sm.cohort
          sm.update_attributes!(:donor_id => nil)
          count += 1
        end
      end
      say "#{count} samples reverted"
    end
  end
end
