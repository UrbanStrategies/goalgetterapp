GoalGetter.Views.PortfolioView = GoalGetter.Views.ScreenBase.extend
  className: 'portfolio'
  initialize: ->
    _.bindAll @, 'render'
    @tab_views =
      'public': {}
      'portfolio-friends': null
      'portfolio-likes': null
      'milestones': null
        
    @shown_id = 'public'

  manage_bubbles: () ->
    view_self = @
    @$el.find('.goto').each (i, e) ->
      folder = $(e).find('.bubble').data('folder-name')
      if view_self.model.get('inbox').hasOwnProperty(folder) and (ml = view_self.model.get('inbox')[folder]).length > 0
        b = $(e).find('.bubble')
        b.text ml.length
        b.addClass('visible')
      
  set_friend_action: () ->
    status = @model.get 'is_friend'
    return if status == 'self'
    
    button_text = switch status
      when 'friend'
        'unfriend'
      when 'not-friend'
        'add friend'

    # Change this later if we change the text above.
    action = button_text.replace(' ', '-')
    b = @$el.find('#change-friend-status')
    b.show()
    b.text button_text

    b.data 'action', action
  
  delayed_render: (key) ->
    if key != 'public' and @tab_views[key] == null
      el = @construct_screen key, @tab_views
      @tab_views[key].root_el = el
    else
      if @tab_views[key].hasOwnProperty('view_obj') and @tab_views[key].view_obj.hasOwnProperty('fetcher')
        @tab_views[key].view_obj.fetcher.resume()
      @tab_views[key].root_el.show()
  events:
    # Name editing

    'click .username': (e) ->
      @$('.username').attr 'contentEditable', true
    'blur .username': (e) ->
      @model.data_change 'user_name', $(e.target).text(), target_div: $(e.target)
      
    # Tab switching
    'click .goto': (e) ->
      @previous_tab.removeClass('selected')
      @previous_tab = $(e.target)
      @previous_tab.addClass('selected')

      d = @previous_tab.find('.bubble')
      if d.hasClass('visible')
        folder = d.data('folder-name')
        d.removeClass 'visible'
        @update_alert folder
        
      vo = @tab_views[@shown_id].view_obj
      if typeof vo != 'undefined' and vo.hasOwnProperty('fetcher') # pause fetching
        @tab_views[@shown_id].view_obj.fetcher.pause()
        
      target_view_key = $(e.target).attr('id').replace('goto-', '')
      @tab_views[@shown_id].root_el.hide()
      @shown_id = target_view_key

      @delayed_render @shown_id

    # Generic handler for all portfolio additions
    'click .add-card': (e) ->
      if $(e.target).data('card-type')
        click_on_node = $(e.target)
      else
        click_on_node = $(e.target).closest('.card-entry')
      click_on = click_on_node.data('card-type')

      if click_on == 'an-achievement'
        achievement_type = click_on_node.data('achievement-type')
      @model.card_type = click_on
      @model.achievement_type = achievement_type

      # Want to show a wave
      @wave_wait = setInterval(
        (ctx) ->
          clearInterval ctx.wave_wait
          ctx.trigger 'navigation:change', {to: ('add-' + click_on)}
        400,
        @
      )

    'click #change-friend-status': (e) ->
      # is this orphaned code?
      f = $('form#make-friend-form')
      data =
        payload:
          code: $('#change-friend-status').data('action')
        friend_id: @model.get 'id'
      view_self = @
      
      $.ajax(
        method: 'PUT'
        url: '/profile.json'
        data: data
        success: (d, s, x) ->
          if d.data.status
            view_self.model.set 'is_friend', d.data.is_friend
            view_self.set_friend_action()
      )
            
    'click #sign-out': ->
      view_self = @
      $.ajax(
        method: 'DELETE'
        url: '/users/sign_out'
        success: (d, s, x) ->
          # assume correctness of response
          view_self.model.destroy_user_data()
          document.location.href = '/'
      )
      
  render: ->
    t_func = _.template $('#body_portfolio_template').html()

    @$el.html t_func({username: @model.get('user_name')})
    @set_friend_action()
    @manage_bubbles()
    
    @previous_tab = @$el.find('.goto.selected')
    @$el.find('#portfolio-img').attr 'src', @model.get('profile_pic_url')
    view_self = @

    # Create drop zone
    $.ajaxSetup(
      headers:
        'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
    )

    if @model.current_screen == '3'
      dz = $("#portfolio-img").dropzone(
        url: "/profile/photo"
        headers:
          'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
        init: ->
          @on('success', (file, resp) ->
            if resp.hasOwnProperty('redirect')
              view_self.trigger 'navigation:change', {redirect: resp.redirect}
          )
      )
      dz.on('dragenter', (e) ->
        $(e.target).addClass('dragged')
      )
      dz.on('dragleave', (e) ->
        $(e.target).removeClass('dragged')
      )
      dz.on('drop', (e) ->
        $(e.target).removeClass('dragged')
        $(e.target).hide()
        $('.portfolio-img.loading').show()
      )
          
    # Add work experience
    wex_card = @$el.find('.portfolio-card#workex')
    
    @model.get('work_experience').forEach (item) ->
      t_func = _.template $('#body_portfolio_work_experience').html()
      el = $(t_func(
        title: item.work_title
        workplace: item.work_workplace,
        startdate: item.work_startdate
        enddate: item.work_enddate
      ))
      wex_card.last().append el      

    # Add the remaining categories beneath work experience; these next two templates are in _portfolio_category.html.haml
    t_func = _.template $('#portfolio_category').html()
    @model.get('portfolio_categories').forEach (cat_name) ->
      add_bar = $(t_func({card_name: cat_name}))
      view_self.$el.find('.workex-row').after add_bar
      t_func_1 = _.template $('#body_portfolio_achievement').html()
      
      avlbl_ach = view_self.model.get('achievements').filter( (e) ->
        e.type == cat_name
      )
      if avlbl_ach.length > 0
        avlbl_ach[0]['texts'].forEach( (txt) ->
          add_bar.append $(t_func_1({text: txt}))
        )
      null

    @tab_views.public.root_el = @$el.find('#public')
    @$el
