GoalGetter.Views.AddWorkView = GoalGetter.Views.ScreenBase.extend
  initialize: ->
    _.bindAll @, 'render'

  events:
    a: 1
    
  render: ->
    t_func = _.template $('#body_add-work_template').html()
    @$el.html t_func()
    @$el