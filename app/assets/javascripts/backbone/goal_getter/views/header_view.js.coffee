GoalGetter.Views.HeaderView = Backbone.View.extend
  className: 'header'
  initialize: ->
    _.bindAll @, 'render'
    _.bindAll @, 'render_with_body'
    @body_view = new GoalGetter.Views.AppBodyView
      model: @model

    @listenTo @body_view, 'navigation:change', @change_screens
    @listenTo @body_view, 'body:render', @render_and_pass

  render_and_pass: ->
    # Let control know there's a data change, for the footer's sake. Right now, this trigger is
    # entirely ignored by control.

    @trigger 'body:render'
    @render()

  events:
    'click .nav-back': ->
      @change_screens
        to: 'up'
    'click #save': (e) ->
      button = $(e.target)
      $.ajax('/resource_bookmarks',
        method: 'post'
        data:
          resource_id: @model.get('body_guide_id')
          resource_type: 'content-resource-guide'
        success: (d, s, x) ->
          if d.data.status == 'deleted'
            button.removeClass 'saved'
          else
            button.addClass 'saved'
      )
      null
      
    'click #logout': ->
      if (m = @model.logged_in) != 'none'
        f = $('form#logout_form')
        f.attr 'action', '/' + m + 's/sign_out'
        f.append($('<input>').attr('type', 'hidden').attr('name', 'authenticity_token').attr('value', ($('meta[name="csrf-token"]').attr('content'))))
        f.submit()
        
    'click #add': ->
      @change_screens
        to: @body_view.action_target('add')
        
    'click #search': ->
      @trigger 'query', {to: 'search'}
      
    'click #published': ->
      view_self = @
      $.ajax('/profile.json',
        method: 'put'
        data:
          payload:
            code: 'toggle-publish'
        success: (d, s, x) ->
          view_self.model.set 'profile_published', d.data.profile_published
          view_self.render()
      )
          
    'click #share': ->
      @trigger 'show_overlay'
      
    'click #submit-body-form': ->
      @body_view.trigger 'header:submit-body-form'

  fill_save: (event_name) ->
    @$el.find('#save use').addClass 'saved'
    
  change_screens: (change_obj) ->
    # This method does a lot.
    # Gonna make it double up to also do redirects
    if change_obj.hasOwnProperty 'redirect'
      @trigger 'post_redirect', {dest: change_obj.redirect}
      return null

    view_self = @
    current_screen = @body_view.screens[@model.current_screen].view_obj
    current_screen.$el.hide()
    if current_screen.hasOwnProperty('fetcher') # pause fetching
      current_screen.fetcher.pause()
    
    if @model.garbage_src_screen()
      @body_view.garbage @model.current_screen
      
    dest = change_obj.to
    if change_obj.hasOwnProperty('from')
      @model.history.push change_obj.from
      
    if dest == 'chat'
      @model.set 'current_chat_counselor_id', change_obj.with.id
      @model.set 'current_chat_counselor', change_obj.with.name
      
    if dest == 'up'
      @model.current_screen = if @model.history.length > 0 then @model.history.pop() else @model.up()
    else
      @model.current_screen = dest

    if change_obj.hasOwnProperty('refresh_screen')
      change_obj.refresh_screen.forEach (key) ->
        view_self.body_view.refresh key

    @render_with_body()
    
  render_with_body: ->
    # The header renders itself and the body element, and returns it to the control
    # view to be appended into the main container. The return value is only ever used the first time
    # the SPA page is rendered.
    
    top_parts = []
    # If the body needs a login, divert it here.
    login_requirement = @model.requires_login[@model.current_screen]
    if !(_.contains(login_requirement, 'none') or _.contains(login_requirement, @model.logged_in))
      # Pretend to use the title from whatever screen you don't have access to
      @model.pretend_key = @model.current_screen
      @model.current_screen = 'logged-out'

    top_parts.push(@render())
    top_parts.push(@body_view.render())
    top_parts

  set_publish_status: ->
    # we will get the publish status only after the body has rendered.
    if @model.get('profile_published') == true
      @$el.find('#published .button-rectangular').removeClass('private').addClass('public').text('unpublish')
    else
      @$el.find('#published .button-rectangular').removeClass('public').addClass('private').text('publish')
    @$el
        
  render: ->
    header_obj =
      header_title: @model.header_title()
      
    @$el.html(_.template($('#header_template').html())(header_obj))

    if !@model.at_root()
      @$el.find('.nav-back').css('display', 'inline-block')
    else
      @$el.find('.nav-back').hide()

    # portfolio manages header
    if @model.current_screen == '3'
      @$el.find('#published').css('display', 'inline-block')
      @set_publish_status()

    if @model.logged_in != 'none'
      e = @$el.find('.header-actions .item#logout')
      e.css 'display', 'inline-block'
      e.find('.tool-icon-img').attr 'title', @model.data_div.data('login-id')
    if @model.has_header_behavior('save') and @model.logged_in != 'none'
      @$el.find('.header-actions .item#save').css 'display', 'inline-block'
      gd = @model.get('guide_data')
      if typeof gd != 'undefined' and gd.is_saved == true
        @$el.find('#save use').addClass('saved')
    if @model.has_header_behavior('add') and @model.logged_in != 'none'
      @$el.find('.header-actions .item#add').css 'display', 'inline-block'
    if @model.has_header_behavior('share')
      @$el.find('.header-actions .item#share').css 'display', 'inline-block'
    if @model.has_header_behavior('search')
      @$el.find('.header-actions .item#search').css 'display', 'inline-block'
      
    if @model.has_header_behavior('done')
      @$el.find('#submit-body-form').css 'display', 'inline-block'
      
    @$el
