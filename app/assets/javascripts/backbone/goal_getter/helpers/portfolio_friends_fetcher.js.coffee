GoalGetter.Helpers.PortfolioFriendsFetcher = GoalGetter.Helpers.HeartbeatFetcher.extend
  url: ->
    '/profile.json?screen_name=portfolio-friends'

  initialize: ->
    @_lrt = -1
    @stop_interval = false
    @interval = ''
    
    _.bindAll @, 'lrt_data'
    _.bindAll @, 'modify_data'

  modify_data: (coll, resp, opts) ->
    # entry_refresher is a backbone collection, remember?
    if resp.data.friend_entries.length > 0
      coll.set resp.data.friend_entries
    else
      coll.set []
    @last_request_time(Date.now())
    
  lrt_data: ->
    {last_request_time: @_lrt}

