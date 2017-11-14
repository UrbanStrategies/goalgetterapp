require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    jsonb_initializations!
  end

  test '##publicly_found' do
    refute(User.publicly_found(users(:student_1).public_link) == nil)
    assert_nil User.publicly_found(users(:student_private).public_link)
  end
  
  test '#identifier' do
    s = users(:student_1)
    assert_nil s.slug
    assert_equal 'public___user1_valid_com', s.public_link
    assert s.slug
  end
    
  describe '#valid_counselor_id' do
    before do
      @s = users(:student_1)
    end
    
    it 'works' do
      assert @s.valid_counselor_id?(users(:counselor_1).id)
    end
  end

  describe 'type checking' do
    it 'works for student?' do
      assert users(:student_1).student?
    end

    it 'works for counselors' do
      assert users(:counselor_1).counselor?
    end

    it 'handles empty profiles' do
      u = create :user
      refute u.student?
    end
  end
  
  describe '#students' do
    it 'works for counselor without students' do
      assert_equal 0, users(:counselor_empty_school).students.count
    end
    
    it 'works for counselors with students' do
      assert_equal 1, users(:counselor_1).students.count
    end
  end
  
  describe '#counselors' do
    describe 'failure' do
      it 'when there is no school' do
        assert_nil users(:noschool_student).counselors.first
      end

      it 'when there is no counselor' do
        assert_nil users(:uncounseled_student).counselors.first
      end
    end
    
    it 'works' do
      assert_equal users(:counselor_1).email, users(:student_1).counselors.order(created_at: :asc).first.email
    end
  end

  test '#friends' do
    # 2, in fixtures.
    assert_equal 2, users(:student_1).friends.count
  end

  test '#friendships' do
    # 2, in fixtures
    assert_equal 2, users(:student_1).friendships.count
  end

  test 'making friends' do
    assert_difference('Friendship.count', 1) do
      users(:student_1).make_friend(users(:nothing_user))
    end
  end
end
