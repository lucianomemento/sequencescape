# This file is part of SEQUENCESCAPE; it is distributed under the terms of
# GNU General Public License version 1 or later;
# Please refer to the LICENSE and README files for information on licensing and
# authorship of this file.
# Copyright (C) 2007-2011,2012,2015 Genome Research Ltd.

class CreateAssetRequest < SystemRequest
  def initialize_aliquots
    # set study on aliquot
    asset.try(:aliquots).try(:each) do |aliquot|
      return if aliquot.study_id || aliquot.project_id
      aliquot.update_attributes!(study_id: initial_study_id, project_id: initial_project_id)
    end
  end
  private :initialize_aliquots
  before_save :initialize_aliquots
end
