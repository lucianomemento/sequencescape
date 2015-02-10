#This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2007-2011,2011 Genome Research Ltd.
class AttachInfiniumBarcodeTask < Task

  class AttachInfiniumBarcodeData < Task::RenderElement
    def initialize(request)
      super(request)
    end
  end

  def create_render_element(request)
    request.asset && AssignTagsData.new(request)
  end

  def partial
    "attach_infinium_barcode_batches"
  end

  def render_task(workflow, params)
    super
    workflow.render_attach_infinium_barcode_task(self, params)
  end

  def do_task(workflow, params)
    workflow.do_attach_infinium_barcode_task(self, params)
  end

end
