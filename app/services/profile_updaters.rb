module ProfileUpdaters
  def process_friendship(u, params)
    success = false
    fr = Friendship.find_or_initialize_by first_friend_id: u.id, second_friend_id: params[:friend_id]
    is_friend = 'self'
    
    case params.dig(:payload, :code)
    when 'unfriend'
      if fr.present?
        fr.delete
        is_friend = 'not-friend'
        success = true
      end
    when 'add-friend'
      if fr.new_record? and User.find_by_id(params[:friend_id]).present?
        fr.save
        success = true
        is_friend = 'friend'
      end
    end

    {status: success, is_friend: is_friend}
  end  
  
  def add_work(u, params)
    resp = 
      if valid_data?(params, :card_type, :title, :workplace, :startdate, :enddate)
        data = params[:payload][:data]
        data[:entry_key] = 'work'
        p = ProfileEntry.create_from_api_call(
          data.permit(:title, :workplace, :startdate, :enddate, :entry_key), user: u
        )
        {id: p.id}
      else
        {}
      end
  end

  def add_achievement(u, params)
    ((valid_data?(params, :card_type, :text)) ?
       (
         p = u.add_achievement params[:payload][:data][:card_type], params[:payload][:data][:text];
         {id: p.id}
       )
     :
       {})
  end

  def add_service(u, params)
    resp = 
      if valid_data?(params, :title, :location, :description)
        data = params[:payload][:data]
        s = Program.new title: data[:title], address: data[:location], description: data[:description],
                        is_official: false
        s.save
        ProgramSuggestion.create(user: u, program: s)
        {id: s.id}
      else
        {}
      end
  end

  def add_milestone(u, params)
    resp = 
      if valid_data?(params, :title, :description, :enddate) &&
         at_least?(params, [:assign_to_all, :student_id], 0)
        MilestoneListing.create_from_api_call params[:payload][:data].
                                               permit(:title, :description, :enddate, :assign_to_all, :student_id).to_h, user: u
      else
        {}
      end
  end

  private
  def valid_data?(params, *required_keys)
    (d = params.dig(:payload, :data)) &&
      (required_keys - d.keys.map {|k| k.to_sym}).length == 0
  end
  def at_least?(params, required_key_list, strict_minimum)
    (d = params.dig(:payload, :data)) &&
      (d.keys.inject(0) {|memo, k| memo += (required_key_list.include?(k.to_sym) || required_key_list.include?(k) ? 1 : 0); memo}) > strict_minimum
  end
end
