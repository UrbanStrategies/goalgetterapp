GoalGetter.Views.AppBodyView = GoalGetter.Views.ScreenBase.extend
  className: 'app-body'
  initialize: ->
    _.bindAll @, 'render'
    _.bindAll @, 'close_and_up'
    _.bindAll @, 'garbage'
    _.bindAll @, 'show_fail'
    
    @screens = {}
    @listenTo @, 'switch_screen', @switch_screen
    @listenTo @, 'header:submit-body-form', @render_and_close

  construct_and_trigger: (ref) ->
    if typeof @screens[ref] == 'undefined'
      @construct_screen ref, @screens
      @listenTo @screens[ref].view_obj, 'navigation:change', @pass_navigation
      @listenTo @screens[ref].view_obj, 'body:render', @pass_body_render
    @screens[ref].view_obj.$el.show()
    
  garbage: (ref) ->
    @model.screen_data_ready[ref] = false
    @screens[ref].view_obj.$el.empty()
    if @screens[ref].view_obj.hasOwnProperty('fetcher') # stop fetching
      @screens[ref].view_obj.fetcher.stop()
    delete @screens[ref]

  refresh: (ref) ->
    @garbage ref
    @construct_and_trigger ref
    
  close_and_up: (data) ->
    # data will be an empty array if the form wasn't filled in: see models/base/form_processor

    # TODO There might be more complex logic for what needs to be refreshed; than simply what's the up level screen
    obj = {to: 'up'}
    if @model.has_header_behavior('done_refreshes')
      obj.refresh_screen = [@model.up_level[@model.current_screen]]
    @pass_navigation obj
    
  show_fail: (errorThrown) ->
    @$el.append($('<div>got error ' + errorThrown + ' </div>'))
    null
    
  render_and_close: ->
    # POST an update to the backend; trigger server response
    if @$el.find('.input-form').length == 1
      code = @$el.find('.input-form').data('server-code')
      @model.process_form_data(code, @$el.find('.input-form input')).then(@close_and_up).catch(@show_fail)

  pass_navigation: (obj) ->
    # Pass thru event arguments up to control app
    @trigger 'navigation:change', obj
    
  pass_body_render: (obj) ->
    # Pass thru event arguments up to control app
    @trigger 'body:render', obj
    
  action_target: (action_name) ->
    # Each body view has its own rules for what happens when buttons are clicked in the header
    ret = false
    if @screens[@model.current_screen] != 'undefined'
      if typeof @screens[@model.current_screen].view_obj.action_target == 'function'
        ret = @screens[@model.current_screen].view_obj.action_target action_name

    ret
    
  render: ->
    view_self = @
    curr_screen_ref = @model.current_screen
    @construct_and_trigger curr_screen_ref
  
    @$el
