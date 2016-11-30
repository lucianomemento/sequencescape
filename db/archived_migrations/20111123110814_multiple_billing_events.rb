#This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
# Please refer to the LICENSE and README files for information on licensing and
# authorship of this file.
# Copyright (C) 2011 Genome Research Ltd.
class MultipleBillingEvents < ActiveRecord::Migration
  def self.up
    change_column :billing_events, :quantity, :float
  end

  def self.down
    change_column :billing_events, :quantity, :integer
  end
end