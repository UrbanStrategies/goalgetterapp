class User
  def make_friends(other_user)
    Friendship.create first_friend_id: id, second_friend_id: other_user.id
  end
end

    
