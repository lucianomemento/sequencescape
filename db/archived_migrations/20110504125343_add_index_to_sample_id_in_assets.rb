#This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
# Please refer to the LICENSE and README files for information on licensing and
# authorship of this file.
# Copyright (C) 2011 Genome Research Ltd.
class AddIndexToSampleIdInAssets < ActiveRecord::Migration
  def self.up
    add_index :assets, :sample_id
  end

  def self.down
    remove_index :assets, :sample_id
  end
end
