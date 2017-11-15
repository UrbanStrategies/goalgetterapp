require 'test_helper'
class FriendsTabTest < Capybara::Rails::TestCase
  include Warden::Test::Helpers
  self.use_transactional_tests = false
  
  def setup
    Capybara.current_driver = :selenium

    u = create :user
    v = create :user
    u.make_friends v
    v.add_achievement 'work', 'internship'
    login_as u, scope: :user, run_callbacks: false
    jsonb_initializations!

    visit "/"

    # needs this fo sho
    sleep 1
    page.all('.footer .nav-change')[3].click
    sleep 1
  end

  describe 'can get to portfolio screen' do
    it 'works normally' do
      page.all('.goto')[1].click
      sleep 1
      assert page.has_content?('internship')
      page.all('.goto')[2].click
      sleep 1
      assert page.has_content?('no likes')
      
      page.all('.goto')[1].click
      sleep 1
      assert page.has_content?('internship')
    end
  end
  
  def teardown
    Warden.test_reset!
  end
end
