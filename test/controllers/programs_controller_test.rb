require 'test_helper'

class ProgramsControllerTest < ActionController::TestCase
  test 'no query' do
    get :index, xhr: true
    assert_equal Program.count, JSON.parse(response.body)['data'].length
  end

  test 'with query' do
    # the phrase _tutor_ is a substring in 2 programs

    # Spaces are ignored
    get :index, xhr: true, params: {q: ' tutor '}
    assert_equal 2, JSON.parse(response.body)['data'].length
    
    get :index, xhr: true, params: {q: 'tutor'}
    assert_equal 2, JSON.parse(response.body)['data'].length
  end    
end