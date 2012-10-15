# ## Program main runner
# (jQuery document ready)
App = {} unless App?
App.enableControls = ->
  $("#runControls button").removeAttr "disabled"
  $("#asyncControls button").attr "disabled", true
App.disableControls = ->
  $("#runControls button").attr "disabled", true
  $("#asyncControls button").removeAttr "disabled"
App.run = (e) ->
  display_type = $(this).data "display"
  adapter = App.DisplayAdapter.getAdapter display_type, "#output"
  bottles = parseInt $("#bottleCount").val()

  if $("input[name=async]:checked").val() is "yes"
    App.disableControls()
    mySong = new App.AsyncSong bottles, App.enableControls
  else
    mySong = new App.SyncSong bottles
  
  mySong.setDisplay(adapter)
  
  try
    mySong.sing()
  catch e
    if e.name is "BottleCountError"
      adapter.print "#{e.message.cap()}."
      adapter.flush()
    else throw e

$ ->
  App.enableControls()
  $("#runControls button").click App.run
  $("#stopAsyncBtn").click ->
    App.asyncRunning = off
    App.enableControls()
