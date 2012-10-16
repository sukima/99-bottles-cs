# ## Program main runner
# This is used to create and run the song. It is application specific and so a
# seperate module from `99bottles.coffee`. It is dependent on jQuery.
#
# To use this Runner class you need to add the following to your index.html
# after the script tag for `application.js`:
#
#     <script type="text/javascript">
#       Runner = require('runner');
#       Runner.init();
#     </script>
#
App = require('99bottles')
require('collapsible')
$ = jQuery

# ### Runner
# A class to encapsolate the application logic.
#
# It offeres methods to enable and disable the buttons on the page. Along with a
# single run method that initiates and completes the singing of a song.
class Runner
  @init: ->
    # And your ussual document.ready() setup.
    jQuery ->
      $("#intro").collapsible()
      Runner.enableControls()
      $("#runControls button").click Runner.run
      $("#stopAsyncBtn").click ->
        App.asyncRunning = off
        Runner.enableControls()
  @enableControls: ->
    $("#runControls button").removeAttr "disabled"
    $("#asyncControls button").attr "disabled", true
  @disableControls: ->
    $("#runControls button").attr "disabled", true
    $("#asyncControls button").removeAttr "disabled"
  @run: ->
    $("#intro").collapsible("close")
    display_type = $(this).data "display"
    adapter = App.DisplayAdapter.getAdapter display_type, "#output"
    bottles = parseInt $("#bottleCount").val()

    if $("input[name=async]:checked").val() is "yes"
      Runner.disableControls()
      mySong = new App.AsyncSong bottles, Runner.enableControls
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

module.exports = Runner
