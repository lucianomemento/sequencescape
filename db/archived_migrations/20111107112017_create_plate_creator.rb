#This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
# Please refer to the LICENSE and README files for information on licensing and
# authorship of this file.
# Copyright (C) 2011 Genome Research Ltd.
class CreatePlateCreator < ActiveRecord::Migration
  def self.up
    create_table :plate_creators do |t|
      t.string :name, :null => false
      t.references :plate_purpose, :null => false
      t.timestamps
    end
    add_index :plate_creators, :name, :unique => true

    create_table :plate_creator_purposes do |t|
      t.references :plate_creator, :null => false
      t.references :plate_purpose, :null => false
      t.timestamps
    end
    add_index :plate_creator_purposes, [ :plate_creator_id, :plate_purpose_id ], :unique => true
  end

  def self.down
    drop_table :plate_creator_purposes
    drop_table :plate_creators
  end
end
