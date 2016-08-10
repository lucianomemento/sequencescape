#This file is part of SEQUENCESCAPE; it is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2007-2011,2015 Genome Research Ltd.

class Projects::Workflows::ItemsController < ApplicationController
#WARNING! This filter bypasses security mechanisms in rails 4 and mimics rails 2 behviour.
#It should be removed wherever possible and the correct Strong  Parameter options applied in its place.
  before_action :evil_parameter_hack!

  def index
    @workflow = Submission::Workflow.find(params[:workflow_id])
    @project  = Project.find(params[:project_id])

    submissions = @project.submissions.select { |s| s.workflow == @workflow }
    @items = submissions.map { |s| s.items }.flatten.uniq

    respond_to do |format|
      format.html
      format.xml { render :xml => @items.to_xml }
    end
  end

  def print
    @workflow = Submission::Workflow.find(params[:workflow_id])
    @project  = Project.find(params[:project_id])
    printables = []
    params[:printable].each do |key, value|
     item = Item.find(key)
     request = item.requests.detect{ |r| r.request_type.key == "receive_sample" }
     unless request.nil?
       printables.push PrintBarcode::Label.new({ :number => request.id, :project => "#{item.id}_#{item.name.gsub("_"," ")}", :suffix => "" })
     end
    end
    if !printables.empty?
      BarcodePrinter.print(printables, params[:printer])
    end
    flash[:notice] = "Your labels have been sent to printer #{params[:printer]}."
    redirect_to project_workflow_items_path(@project, @workflow)
  rescue SOAP::FaultError
    flash[:warning] = "There is a problem with the selected printer. Please report it to Systems."
    redirect_to project_workflow_items_path(@project, @workflow)
  end
end
