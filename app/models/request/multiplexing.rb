#This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2014 Genome Research Ltd.
class Request::Multiplexing < Request

  after_create :register_transfer_callback

  def register_transfer_callback
    # We go via order as we need to get a particular instance of submission
    order.submission.register_callback(:once) do
      Transfer::FromPlateToTubeByMultiplex.create!(
        :source => self.asset.plate,
        :user   => self.order.user
      )
    end
  end


  aasm :column => :state do
      state :pending, :initial => true
      state :started
      state :passed
      state :failed
      state :cancelled

      event :start  do transitions :to => :started,     :from => [:pending]                    end
      event :pass   do transitions :to => :passed,      :from => [:pending, :started] end
      event :fail   do transitions :to => :failed,      :from => [:pending, :started] end
      event :cancel do transitions :to => :cancelled,   :from => [:started, :passed]           end
    end

end
