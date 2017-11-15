GoalGetter.Views.PortfolioTabFriendsView = GoalGetter.Views.ScreenBase.extend
  className: 'portfolio-sub-card'
  initialize: ->
    _.bindAll @, 'render'
    @entry_refresher = new GoalGetter.Helpers.PortfolioFriendsFetcher()
    @fetcher = @entry_refresher
    
    # The view will start to refresh entries; in some future version, we need a way to have the
    # view stop the fetcher if it gets garbaged.

    @entry_refresher.run()
    @listenTo @entry_refresher, 'sync', @show_new_entries

  events:
    'click .like': (e) ->
      tgt = $(e.target)
      r = tgt.closest('.row')
      entryid = r.data('entry-id')
      current_status = r.data('liked-status')
      
      update_like_class = ((d, s, x) ->
        btn = r.find('.floating-action')
        btn.toggleClass 'liked'
        # Set a filled in or outlined heart.
        if btn.hasClass('liked') then btn.text(String.fromCharCode(9829)) else btn.text(String.fromCharCode(9825))
      )

      $.ajax('/profile_entries/' + entryid + '.json',
        method: 'put'
        data:
          payload:
            code: 'like'
            data:
              current_status: current_status
        statusCode:
          201: update_like_class
          202: update_like_class
      )
      
  show_new_entries: ->
    @entry_refresher.pause()
    @entry_refresher.last_request_time(Date.now())

    @render()
    @entry_refresher.resume()
    
  render: ->
    t_func = _.template($('#body_portfolio-tab_template').html())
    @$el.html(t_func())

    view_self = @

    if @entry_refresher.models.length == 0
      @$el.append @empty_feed_message('No friends in your network.')
    else
      @entry_refresher.each (m, i) ->
        if m.get('entry_type') == 'profile_achievement'
          str = "added an achievement " + m.get('description')
        else if m.get('entry_type') == 'profile_work'
          str = "added job experience at " + m.get('description')
        else if m.get('entry_type') == 'program'
          str = "suggested a service at " + m.get('description')
        else
          str = "Feed entry " + m.get('description')

        card_html = _.template($('#body_portfolio-tab-item_template').html())(
          description_string: str, entry_name: m.get('user_name'), public_link: m.get('public_link')
        )
        
        e = $(card_html)
        
        e.data 'entry-id', m.get('id')
        e.data 'liked-status', m.get('liked_status')
        
        view_self.$el.append e

        btn = e.find('.like')
        if m.get('liked_status')
          btn.addClass 'liked'
          btn.text(String.fromCharCode(9829))
        else
          btn.text(String.fromCharCode(9825))
        e.find('img').attr('src', m.get('img_url'))

    @$el
    
