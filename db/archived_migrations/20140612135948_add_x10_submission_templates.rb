#This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
# Please refer to the LICENSE and README files for information on licensing and
# authorship of this file.
# Copyright (C) 2014 Genome Research Ltd.
class AddX10SubmissionTemplates < ActiveRecord::Migration
  require 'hiseq_2500_helper'

  def self.up
    ActiveRecord::Base.transaction do
      outlines do |template|
        SubmissionTemplate.create!(template)
      end
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      outlines do |template|
        submission_template = SubmissionTemplate.find(:last, :conditions=>["name = ?",template[:name]], :order => 'ID ASC')
        unless submission_template.nil?
          submission_template.destroy
        end
      end
    end
  end

  def self.outlines
    [
    # {:pipeline=>'Illumina-A', :name => 'Pippin WGS',      :infos=>'full',  :request_types=>['illumina_a_shared', 'illumina_a_pippin'],   :role=>'ILA WGS'},

    # {:pipeline=>'Illumina-B', :name => 'Pooled HWGS',     :infos=>'full', :request_types=>['illumina_b_shared', 'illumina_b_pool'],   :role=>'HWGS' },
    # {:pipeline=>'Illumina-B', :name => 'Pippin HWGS',     :infos=>'full', :request_types=>['illumina_b_shared', 'illumina_b_pippin'], :role=>'HWGS' }
    {:pipeline=>'Illumina-C', :name => 'General PCR',     :infos=>'wgs', :request_types=>['illumina_c_pcr'], :role=>'HSqX' }
    ].each do |outline|
      paras = {
          :request_type_ids_list => outline[:request_types].map {|rt| [RequestType.find_by_key!(rt).id] } << seq_x10_for(outline[:pipeline]),
          :workflow_id => 1
        }
      paras.merge!({:order_role_id => Order::OrderRole.find_or_create_by(role:outline[:role]).id}) if outline[:role].present?
      template = {
        :name => "#{outline[:pipeline]} - #{outline[:name]} - HiSeq-X sequencing",
        :submission_class_name => 'LinearSubmission',
        :submission_parameters => paras,
        :product_line_id => ProductLine.find_by_name!(outline[:pipeline]).id
      }
      yield(template)
    end
  end

  def self.infos(type)
    Hiseq2500Helper.input_fields(['150'],{
      'wgs'  => ["Standard"],
      'isc'  => ["Agilent Pulldown"],
      'full' => ["NlaIII gene expression","Standard","Long range","Small RNA","DpnII gene expression","qPCR only",
                "High complexity and double size selected","Illumina cDNA protocol","Custom","High complexity",
                "Double size selected","No PCR","Agilent Pulldown","ChiP-seq","Pre-quality controlled"]
      }[type])
  end

  def self.seq_x10_for(pipeline)
    @hash ||= Hash.new {|h,i| h[i]= [RequestType.find_by_key!("illumina_b_hiseq_x_paired_end_sequencing").id]}
    @hash[pipeline]
  end
end
