require 'test_helper'
class ProfilesControllerTest < ActionController::TestCase
  include ActionDispatch::TestProcess
  include Devise::Test::ControllerHelpers
  
  def setup
    @student_1 = users(:student_1)
    sign_in @student_1

    set_net_stubs
    jsonb_initializations!
  end
  
  describe '#show' do
    it 'works for friends' do
      get :show, xhr: true, params: {format: 'json', screen_name: 'portfolio-friends'}
      b = JSON.parse(response.body)['data']['friend_entries']
      assert_equal 2, b.length
    end
    it 'works for likes' do
      get :show, xhr: true, params: {format: 'json', screen_name: 'portfolio-likes'}
      b = JSON.parse(response.body)['data']['likes']
      assert_equal 2, b.length
    end
    
    it 'works for contacts' do
      get :show, xhr: true, params: {format: 'json', screen_name: '4'}
      b = JSON.parse(response.body)['data']['user_info']['friends']
      assert_equal 2, b.length
    end
    
    it 'works for counselor screen' do
      get :show, xhr: true, params: {format: 'json', screen_name: '2'}

      # let student 1 have two counselors in fixtures
      assert_equal 2, JSON.parse(response.body)['data']['user_info']['counselors'].size
      assert_match /the first/, JSON.parse(response.body)['data']['user_info']['counselors'][0]['name']
    end

    it 'works for portfolio screen' do
      get :show, xhr: true, params: {format: 'json', screen_name: '3'}
      b = JSON.parse response.body
      
      # see fixtures for this data (added WE 4200 on May 20)
      assert_equal 2, b['data']['work_experience'].size
      assert_equal 4, b['data']['work_experience'][0].keys.size
      assert_equal 2, b['data']['achievements'].size

      assert b['data']['profile_published']
    end

    it 'works for chat screen with couns 1' do
      get :show, xhr: true, params: {format: 'json', screen_name: 'chat', counselor_id: users(:counselor_1).id}
      d = JSON.parse(response.body)['data']['user_info']
      # See fixtures
      assert_equal 3, d['rec_count']
      assert_match /now/, d['recs'].last['message']

      # I sent two, and received a response
      assert_equal false, d['recs'][1]['is_response']      
      assert_equal true, d['recs'][2]['is_response']
    end

    it 'shows alerts if there are some' do
      AccountInboxMessage.create message_attachment: content_resources(:cr_1)
      r_read = AccountInboxMessage.create message_attachment: content_resources(:cr_2), is_read: true
      
      # new alerts show up for screen keys that don't exist
      get :show, xhr: true, params: {format: 'json', screen_name: 'nosuchkey'}
      # r_read won't be shown; one more added in fixtures Aug 8
      assert_equal 2, JSON.parse(response.body)['data']['inbox']['ContentResource'].size
    end
    
    it 'shows alerts with dawn of time logic' do
      AccountInboxMessage.create message_attachment: content_resources(:cr_1), is_read: false
      get :show, xhr: true, params: {format: 'json', screen_name: 'nosuchkey'}
      assert_equal 2, JSON.parse(response.body)['data']['inbox'].keys.size
    end
  end

  describe '#update' do
    it '(un)makes friendships' do
      sign_out :user
      sign_in users(:student_1)

      assert_difference('Friendship.count', -1) do
        put :update, xhr: true, params: {format: 'json',
                                         payload: {code: 'unfriend'}, friend_id: users(:student_1_f1).id}
      end
      assert_difference('Friendship.count', 1) do
        put :update, xhr: true, params: {format: 'json',
                                         payload: {code: 'add-friend'}, friend_id: users(:noschool_student).id}
      end      
    end
    
    it 'toggles publish' do
      current_state = @student_1.profile.published
      put :update, xhr: true, params: {format: 'json',
                                       payload: {code: 'toggle-publish', data: ''}}
      assert (@student_1.reload.profile.published != current_state)
    end
    
    it 'adds entries for some but only permitted codes' do
      AccountInboxMessage.create message_attachment: content_resources(:cr_1), is_read: false, user: users(:student_1)

      # one unread added in fixtures Aug 8
      assert_difference('AccountInboxMessage.where(is_read: false).count', -2) do
        put :update, xhr: true, params: {format: 'json',
                                         payload: {code: 'set-to-read', data: {type: 'ContentResource'}}}
      end
    end
  end

  describe '#public' do
    it 'shows login message' do
      sign_out :user

      # student 1 is published
      u = users(:student_1)
      get :public, params: {identifier: u.public_link}
      assert_equal I18n.t('messages.login_to_view', fullname: u.full_name), flash[:notice]
    end
  end
  
  describe '#add_photo' do
    it 'fails without login' do
      sign_out @student_1
      post :add_photo, xhr: true, params: {file: File.open(fixture_file_as_io('sample.png'))}
      assert_equal '', response.body
    end

    it 'returns redirect directive' do
      Aws.config = {stub_responses: true}
      Profile.any_instance.stubs(:save_attached_files).returns true
      post :add_photo, xhr: true, params: {file: fixture_file_upload("files/sample.png", 'application/png')}
      assert_match /{"redirect".*"3"}/, response.body
    end      
  end
end
