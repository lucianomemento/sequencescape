#This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2007-2011,2013,2014,2015 Genome Research Ltd.
class UnrepeatableSequencingPipeline < SequencingPipeline

  def request_actions
    [:fail]
  end


end