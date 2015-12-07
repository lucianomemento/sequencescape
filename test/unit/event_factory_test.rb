#This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2007-2011,2011,2012,2013,2015 Genome Research Ltd.
require "test_helper"


class EventFactoryTest < ActiveSupport::TestCase
  context "An EventFactory" do
    setup do
      @user = create :user, :login => "south", :email => "south@example.com"
      @bad_user = create :user, :login => "south", :email => ""
      @project = create :project, :name => "hello world"
      #@project = create :project, :name => "hello world", :user => @user
      role = create :owner_role, :authorizable => @project
      role.users << @user << @bad_user
      @request_type = create :request_type, :key => "library_creation", :name => "Library creation"
      @request = create :request, :request_type => @request_type, :user => @user, :project => @project
    end

    context "#new_project" do
      setup do
        @event_count =  Event.count
        admin = create :role, :name => "administrator"
        user1 = create :user, :login => "abc123"
        user1.roles << admin
        EventFactory.new_project(@project, @user)
      end

     should "change Event.count by 1" do
       assert_equal 1,  Event.count  - @event_count, "Expected Event.count to change by 1"
     end

      context "send 1 email to 1 recipient" do

        should 'Have sent an email' do
          last_mail = ActionMailer::Base.deliveries.last
          assert /Project/ === last_mail.subject
          assert last_mail.bcc.include?("abc123@example.com")
          assert /Project registered/, last_mail.body
          assert_equal 1, last_mail.bcc.size
        end
      end
    end

    context "#new_sample" do
      setup do
        @event_count =  Event.count
        admin = create :role, :name => "administrator"
        user1 = create :user, :login => "abc123"
        user1.roles << admin
        @sample = create(:sample, :name => "NewSample")
      end

      context "project is blank" do
        setup do
          EventFactory.new_sample(@sample, [], @user)
        end

       should "change Event.count by 1" do
         assert_equal 1,  Event.count  - @event_count, "Expected Event.count to change by 1"
      end

        context "send an email to one recipient" do
          should 'Have sent an email' do
            last_mail = ActionMailer::Base.deliveries.last
            assert /Sample/ === last_mail.subject
            assert last_mail.bcc.include?("abc123@example.com")
            assert /New 'NewSample' registered by south/, last_mail.body
          end
        end

      end

      context "project is not blank" do
        setup do
          ActionMailer::Base.deliveries.clear
          @event_count =  Event.count
          EventFactory.new_sample(@sample, @project, @user)
        end


         should "change Event.count by 2" do
           assert_equal 2,  Event.count  - @event_count, "Expected Event.count to change by 2"
        end

        context "send 2 emails each to one recipient" do
          should 'Have sent a 2 emails' do
            assert_equal 2, ActionMailer::Base.deliveries.count
            assert ActionMailer::Base.deliveries.detect {|d| /Sample/ === d.subject }
            assert ActionMailer::Base.deliveries.detect {|d| /Project/ === d.subject }
            assert ActionMailer::Base.deliveries.all? {|d| d.bcc.include?("abc123@example.com") }
            assert ActionMailer::Base.deliveries.detect  {|d| /New 'NewSample' registered by south/ === d.body }
            assert ActionMailer::Base.deliveries.detect  {|d| /This sample was assigned to the 'hello world' project./ === d.body }
          end
        end
      end
    end

    context "#project_approved" do
      setup do
        @event_count =  Event.count
        ::ActionMailer::Base.deliveries = [] # reset the queue
        role = create :manager_role, :authorizable => @project
        role.users << @user
        admin = create :role, :name => "administrator"
        user1 = create :user, :login => "west"
        user1.roles << admin
        EventFactory.project_approved(@project, @user)
      end

      should "change Event.count by 1" do
        assert_equal 1,  Event.count  - @event_count, "Expected Event.count to change by 1"
      end

      context "send email to project manager" do
        should 'Have sent an email' do
          last_mail = ActionMailer::Base.deliveries.last
          assert /Project approved/ === last_mail.subject
          assert last_mail.bcc.include?("south@example.com")
          assert !last_mail.bcc.include?("")
          assert /Project approved/, last_mail.body
        end
      end
    end

    context "#project_approved by administrator" do
      setup do
        @event_count =  Event.count
        ::ActionMailer::Base.deliveries = [] # reset the queue
        admin = create :role, :name => "administrator"
        @user1 = create :user, :login => "west"
        @user1.roles << admin
        @user2 = create :user, :login => "north"
        @user2.roles << admin
        role = create :manager_role, :authorizable => @project
        role.users << @user
        EventFactory.project_approved(@project, @user2)
      end

      should "change Event.count by 1" do
        assert_equal 1,  Event.count  - @event_count, "Expected Event.count to change by 1"
      end

      context ": send emails to everyone administrators" do
        should 'Have sent an email' do
          last_mail = ActionMailer::Base.deliveries.last
          assert /Project approved/ === last_mail.subject
          assert last_mail.bcc.include?("north@example.com")
          assert last_mail.bcc.include?("south@example.com")
          assert last_mail.bcc.include?("west@example.com")
          assert !last_mail.bcc.include?("")
          assert /Project approved/, last_mail.body
        end
      end

    end

    context "#project_approved but not by administrator" do
      setup do
        @event_count =  Event.count
        ActionMailer::Base.deliveries.clear
        admin = create :role, :name => "administrator"
        @user1 = create :user, :login => "west"
        @user1.roles << admin
        follower = create :role, :name => "follower"
        @user2 = create :user, :login => "north"
        @user2.roles << follower
        role = create :manager_role, :authorizable => @project
        role.users << @user
        EventFactory.project_approved(@project, @user2)
      end


       should "change Event.count by 1" do
         assert_equal 1,  Event.count  - @event_count, "Expected Event.count to change by 1"
      end

      context ": send email to project manager" do
        should 'Have sent an email' do
          last_mail = ActionMailer::Base.deliveries.last
          assert /Project approved/ === last_mail.subject
          assert last_mail.bcc.include?("south@example.com")
          assert !last_mail.bcc.include?("")
          assert /Project approved/, last_mail.body
        end
      end

      context "send no email to adminstrator nor to approver" do
        ActionMailer::Base.deliveries.each do |d|
          assert !d.bcc.include?("west@example.com")
          assert !d.bcc.include?("north@example.com")
          assert !d.bcc.include?("")
        end
      end
    end

    context "#study has samples added" do
      setup do
        @event_count =  Event.count
        ::ActionMailer::Base.deliveries = []
        role = create :manager_role, :authorizable => @project
        role.users << @user
        follower = create :role, :name => "follower"
        @user1 = create :user, :login => "north"
        @user1.roles << follower
        @user2 = create :user, :login => "west"
        @user2.roles << follower
        @study = create :study, :user => @user2
        @submission = FactoryHelp::submission :project => @project, :study => @study, :asset_group_name => 'to prevent asset errors'
        @samples = []
        @samples[0] = create :sample, :name => "NewSample-1"
        @samples[1] = create :sample, :name => "NewSample-2"
        EventFactory.study_has_samples_registered(@study, @samples, @user1)
      end

       should "change Event.count by 1" do
         assert_equal 1,  Event.count  - @event_count, "Expected Event.count to change by 1"
      end

      context "send email to project manager" do
        should 'Have sent an email' do
          last_mail = ActionMailer::Base.deliveries.last
          assert /Sample/ === last_mail.subject
          assert /registered/ === last_mail.subject
          assert last_mail.bcc.include?("south@example.com")
        end
      end

    end

    context "#request update failed" do
      setup do
        @event_count =  Event.count
        ::ActionMailer::Base.deliveries = []
        role = create :manager_role, :authorizable => @project
        role.users << @user
        @user1 = create :user, :login => "north"
        @request.user = @user1
        follower = create :role, :name => "follower"
        @user2 = create :user, :login => "west"
        @user2.roles << follower
        @study = create :study, :user => @user2
        @submission = FactoryHelp::submission(:project => @project, :study => @study, :assets => [create(:sample_tube)])
        @request = create :request, :study => @study, :project => @project,  :submission => @submission
        @user3 = create :user, :login => "east"
        message = "An error has occurred"
        EventFactory.request_update_note_to_manager(@request, @user3, message)
      end


       should "change Event.count by 1" do
         assert_equal 1,  Event.count  - @event_count, "Expected Event.count to change by 1"
      end

      context "send email to project manager" do
        should 'Have sent an email' do
          last_mail = ActionMailer::Base.deliveries.last
          assert /Request update/ === last_mail.subject
          assert /failed/ === last_mail.subject
          assert last_mail.bcc.include?("south@example.com")
        end
      end
    end
  end

  def assert_did_not_send_email
# invocation with block tests absence of a specific email
    if block_given?
      emails = ::ActionMailer::Base.deliveries
      matching_emails = emails.select do |email|
        yield email
      end
      assert matching_emails.empty?
    else
# invocation without block lists any mails in the queue for test
# e.g. use as: 'should "list" do  assert_did_not_send_mail; end'
      msg = "Sent #{::ActionMailer::Base.deliveries.size} emails.\n"
      ::ActionMailer::Base.deliveries.each do |email|
        msg << "  '#{email.subject}' sent to #{email.bcc}:\n#{email.body}\n\n"
      end
      assert ::ActionMailer::Base.deliveries.empty?, msg
    end
  end

end
