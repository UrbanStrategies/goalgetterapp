mainapp_fns = ->
  if document.location.pathname == '/'
    model = new GoalGetter.Models.AppBodyModel()
    GoalGetter.Models.AppMainModel = model
    
    model.set_screen_by_role()
    control_view = new window.GoalGetter.Views.ControlView
      el: '.main-app'
      model: model
    control_view.load_and_render()
  
$(document).on('ready page:load', mainapp_fns)
