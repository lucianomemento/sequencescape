# This file is part of SEQUENCESCAPE; it is distributed under the terms of
# GNU General Public License version 1 or later;
# Please refer to the LICENSE and README files for information on licensing and
# authorship of this file.
# Copyright (C) 2015,2016 Genome Research Ltd.

class MigratePlateParentRestrictions < ActiveRecord::Migration


  class PurposeRelationship < ActiveRecord::Base
    self.table_name=('plate_creator_purposes')
  end

  class NewPurposeRelationship < ActiveRecord::Base
    self.table_name=('plate_creator_parent_purposes')
  end


  def self.up
    ActiveRecord::Base.transaction do
      PurposeRelationship.find(:all,
        :select => 'DISTINCT plate_creator_id, parent_purpose_id',
        :conditions => 'parent_purpose_id IS NOT NULL'
      ).each do |pr|
        NewPurposeRelationship.create!(:plate_creator_id=>pr.plate_creator_id,:plate_purpose_id=>pr.parent_purpose_id)
      end
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      NewPurposeRelationship.all.each do |npr|
        PurposeRelationship.where(plate_creator_id: npr.plate_creator_id).each do |p|
          p.update_attributes!(:parent_purpose_id=>npr.plate_purpose_id)
        end
      end
    end
  end
end
