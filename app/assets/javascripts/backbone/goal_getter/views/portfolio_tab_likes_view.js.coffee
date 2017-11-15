GoalGetter.Views.PortfolioTabLikesView = GoalGetter.Views.ScreenBase.extend
  className: 'portfolio-sub-card'
  initialize: ->
    _.bindAll @, 'render'
    @entry_refresher = new GoalGetter.Helpers.PortfolioLikesFetcher()
    @fetcher = @entry_refresher
    
    # The view will start to refresh entries; in some future version, we need a way to have the
    # view stop the fetcher if it gets garbaged.

    @entry_refresher.run()
    @listenTo @entry_refresher, 'sync', @show_new_entries

  show_new_entries: ->
    @entry_refresher.pause()
    @entry_refresher.last_request_time(Date.now())

    @render()
    @entry_refresher.resume()
    
  render: ->
    t_func = _.template($('#body_portfolio-tab_template').html())
    @$el.html(t_func())

    view_self = @
    # this is not set the first time when the tab is initially loaded
    if @entry_refresher.models.length == 0
      # Store this as an instance variable so we can avoid a jQuery lookup later.
      @empty_mesg_div = @empty_feed_message('There are no likes on your activities yet!')      
      @$el.append @empty_mesg_div
    else
      @empty_mesg_div.hide()    
      @entry_refresher.each (m, i) ->
        str = " liked your entry " + m.get('profile_entry_text')

        card_html = _.template($('#body_portfolio-tab-likes-item_template').html())(
          name: m.get('user_name'),
          public_link: m.get('public_link'),
          description_string: str
        )
        e = $(card_html)
        view_self.$el.append e

        e.find('img').attr('src', m.get('img_url'))

    @$el
    
