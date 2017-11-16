require 'test_helper'
class MilestoneListingTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  
  test '##from_api_call' do
    m = nil

    assert_difference('MilestoneListing.count', 1) do
      m = MilestoneListing.create_from_api_call({'title' => 'title 1', 'description' => 'desc 2', 'enddate' => 'Thu Jul 13 2017'})
    end

    assert_equal ['assigned_on', 'assigned_to', 'assigned_by', 'assigned_to_id', 'id', 'title', 'description', 'due_at', 'date', 'month'].
                  sort, m.keys.sort
    assert_equal -1, m['assigned_to_id']
  end

  test '##by_user_permission' do
    assert_equal milestone_listings(:milestone_1).description,
                 MilestoneListing.by_user_permission(users(:student_1)).first.description
  end

  test 'save callback to alert' do
    refute_difference('AccountInboxMessage.count') do
      m = MilestoneListing.create_from_api_call({'title' => 'title 1', 'description' => 'desc 2', 'enddate' => 'Thu Jul 13 2017'})
    end

    m = MilestoneListing.create_from_api_call({'title' => 'title 1', 'description' => 'desc 2', 'enddate' => 'Thu Jul 13 2017', 'student_id' => users(:student_1).id})
    assert_equal ['ActionMailer::DeliveryJob', 'CreateAlertJob'].sort, enqueued_jobs.map { |item| item[:job].to_s}.sort
  end
end
