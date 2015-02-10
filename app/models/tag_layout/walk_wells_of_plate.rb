#This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2012 Genome Research Ltd.
module TagLayout::WalkWellsOfPlate
  def self.walking_by
    'wells of plate'
  end

  def walking_by
    TagLayout::WalkWellsOfPlate.walking_by
  end

  def walk_wells(&block)
    wells_in_walking_order.each_with_index do |well, index|
      yield(well, index) unless well.nil?
    end
  end
  private :walk_wells
end
