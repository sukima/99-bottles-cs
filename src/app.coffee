# ## Program main runner
# This is used to create and run the song. It is application specific and so a
# seperate module from `99bottles.coffee`. It is dependent on jQuery.
App = require('99bottles')
$ = jQuery

# ### Runner
# A class to encapsolate the application logic.
#
# It offeres methods to enable and disable the buttons on the page. Along with a
# single run method that initiates and completes the singing of a song.
class Runner
  @enableControls: =>
    $("#runControls button").removeAttr "disabled"
    $("#asyncControls button").attr "disabled", true
  @disableControls: =>
    $("#runControls button").attr "disabled", true
    $("#asyncControls button").removeAttr "disabled"
  @run: (e) =>
    display_type = $(this).data "display"
    adapter = App.DisplayAdapter.getAdapter display_type, "#output"
    bottles = parseInt $("#bottleCount").val()

    if $("input[name=async]:checked").val() is "yes"
      @disableControls()
      mySong = new App.AsyncSong bottles, @enableControls
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

# And your ussual document.ready() setup.
jQuery ->
  Runner.enableControls()
  $("#runControls button").click Runner.run
  $("#stopAsyncBtn").click ->
    App.asyncRunning = off
    Runner.enableControls()
