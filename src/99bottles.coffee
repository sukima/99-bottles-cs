# 99 Bottles of Beer
# ------------------
# Sung by [CoffeeScript](http://coffeescript.org)  
# Writen by [Devin Weaver](http://tritarget.org)
#
# This is an example application to show off some of the neat parts of the
# CoffeeScript language. It was intended as a submission to their
# [99 bottles of beer][] programming language database.
#
# This file is the basic file you would use to run in your own webpage. The
# supporting files such as the original [source][], [demo][] or to run the
# [unit tests][] You can visit the project [homepage][]
#
# [99 bottles of beer]: http://99-bottles-of-beer.net/
# [source]: http://github.com/sukima/99-bottles-cs/
# [demo]: http://sukima.github.com/99-bottles-cs/
# [unit tests]: http://sukima.github.com/99-bottles-cs/
# [homepage]: http://sukima.github.com/99-bottles-cs/


# ### Capitalize a string
# A utility method to quickly capitalize the first letter in a string.
# This is added onto the `String` object as a utility.
#
# The `::` operator is a CS form of the JavaScript prototype:
#
#     String.prototype.cap = function() {...}
#
String::cap = ->
  @charAt(0).toUpperCase() + @slice(1)


# ### Our main namespace
# A namespace for all our code. This allows us to export just one object instead
# of several. It also houses variables for state, defaults, and strings.
#
# #### State machine
# A simple variable to allow us to interactively turn off any running timed
# events.
#
# #### Defaults
# Provides a easy accessible spot to change configuration options.
#
# #### Strings
# Used to easily change the strings used in the song. Perhaps different wording
# or localizing to another language. This is a simplistic way of doing that.
#
# This also shows the use of CS
# [heredoc](http://rosettacode.org/wiki/Here_document#CoffeeScript).
#
# #### Application Error objects
# Easily create throw-able and query-able errors.
#
# Instead of making new classes for errors or just sending a simple string
# (which would make querying more difficult and would _not_ DRY the code) we can
# use an object which has the name and message properties already defined.
App =
  asyncRunning: on
  defaults:
    bottle_count: 99
    loop_delay: 500
  strings:
    bottle: "bottle of beer"
    bottles: "bottles of beer"
    on_the_wall: "on the wall"
    take_one_down: "take one down and pass it around"
    buy_some_more: "go to the store and buy some more"
    no_more: "no more"
    large_loop_warn: """
      Calculating this many bottles in a loop can slow down your
      browser or freeze it. Are you sure you wish to continue?
      """
  errors:
    BottleCountTooSmall:
      name: "BottleCountError"
      message: "bottle count cannot be less then 1"
    BottleCountTooLarge:
      name: "BottleCountError"
      message: "bottle count too large for display method"
    MissingArgument:
      name: "ArgumentError"
      message: "missing argument"


# ### Class Song
# This is the main logic for singing a song. Because there is more then one way
# to make the looping (synchronous vs asynchronous) this class acts as an
# adapter which other *song methods* will extend to implement the *song*
# functionality.
class App.Song
  constructor: (@initial_bottle_count = App.defaults.bottle_count) ->
    throw App.errors.BottleCountTooSmall unless @initial_bottle_count > 0
    @bottle_count = @initial_bottle_count

  # `gitDisplay()` will either return the save display adapter or make a
  # default one the first time this method is called.
  getDisplay: ->
    @display ?= new App.ConsoleDisplay

  # Allow us to set the display adapter pragmatically.
  setDisplay: (@display) ->

  # Get and construct the string for how many bottles we have.
  #
  # It can handle arguments but we default them to what would normally be used
  # to add some flexibility. Using the = operator in the argument list CS
  # automatically takes care of assignment for us and we don't have to type in
  # any initialization at the beginning of the function.
  #
  # the variable `s` is used to prevent from having to type `App.strings` over
  # and over.
  bottles: (count = @bottle_count, s = App.strings) ->
    num = if count > 0 then "#{count}" else s.no_more
    if count is 1
      "#{num} #{s.bottle}"
    else
      "#{num} #{s.bottles}"

  # Construct a full verse taking into account how many bottles are left. Then
  # use the assigned display adapter to output the new verse.
  printVerse: (s = App.strings) ->
    @getDisplay().print "#{@bottles().cap()} #{s.on_the_wall}, #{@bottles()}."
    if @bottle_count > 0
      @getDisplay().print "#{s.take_one_down.cap()}, #{@bottles(@bottle_count - 1)} #{s.on_the_wall}."
    else
      @getDisplay().print "#{s.buy_some_more.cap()}, #{@bottles(@initial_bottle_count)} #{s.on_the_wall}."
    @getDisplay().flush()

  # This is the main method for the singing loop. Because we wanted to offer
  # examples of different loop methods we will inherit from the Song class and
  # override the sing method.
  #
  # Some display adapters will really bork the browser if they are to display
  # 100 verses (like the default 99 bottles song goes) Most notably the display
  # method which uses alert boxes would end up displaying 100 pop ups. So we add
  # a check to prevent executing with that many bottles.
  sing: ->
    throw App.errors.BottleCountTooLarge if @getDisplay().isBottleCountUnsafe(@bottle_count)
    @getDisplay().clear()


# ### Synchronized Song
# This version of the loop is *synchronous* meaning it will block the
# environment until the loop finishes.
#
# Becouse of this blocking if our loop is too long it can freeze the browser.
# The contructor will ask the user if they are sure they want to continue if the
# requested number of verses reach 1200 bottles.
class App.SyncSong extends App.Song
  constructor: (bottles) ->
    if bottles >= 1200
      throw App.errors.BottleCountTooLarge unless confirm App.strings.large_loop_warn
    super bottles
  # We overide the sing method to run our loop. Calling super allows us to use
  # the safty checks from the parrent Song object above.
  sing: ->
    super
    # The for loop is a good example of how simple CS can be.
    @printVerse() for i in [@bottle_count..0]
    # The use of return at the end stops CS from creating a results array like
    # it usually does with the for loop. It's done purly so the JavaScript
    # created is slightly more efficient since we will not use the results.
    return


# ### Asynchronous Song
class App.AsyncSong extends App.Song
  constructor: (bottles, @callback) ->
    super bottles
    App.asyncRunning = on
  sing: ->
    super
    @singVerse()
  singVerse: =>
    if App.asyncRunning and @bottle_count >= 0
      @printVerse()
      @bottle_count--
      setTimeout @singVerse, App.defaults.loop_delay
    else
      @callback?()


# ##Display Adapters
# Used to display the results. Uses an adapter model to allow multiple ways to
# display the output.
class App.DisplayAdapter
  constructor: ->
    @resetLines()
  isBottleCountUnsafe: (bottle_count) -> no
  clear: ->
    @resetLines()
  print: (text) ->
    @lines.push text
  flush: ->
  resetLines: ->
    @lines = []
  @getAdapter: (display_id, selector) ->
    switch display_id
      when "jq" then new App.JqDisplay(selector)
      when "alert" then new App.AlertDisplay
      when "dom" then new App.DomDisplay(selector)
      else new App.ConsoleDisplay


# ### jQuery diaply adapter
do ($ = jQuery) ->
  class App.JqDisplay extends App.DisplayAdapter
    constructor: (@selector) ->
      throw App.errors.MissingArgument unless @selector?
      super
      @el = $(@selector)
    clear: ->
      super
      @el.empty()
    flush: ->
      html = "<p>"
      html += "#{line}<br />" for line in @lines
      html += "</p>"
      @el.append html
      @resetLines()


# ### Console Display Adapter (default)
class App.ConsoleDisplay extends App.DisplayAdapter
  print: (text) ->
    console?.log text
  flush: ->
    console?.log "-----"


# ### Non-jQuery dom display adapter
# Used to show how to manipulate the dom for when jQuery is not used.
class App.DomDisplay extends App.DisplayAdapter
  constructor: (@selector) ->
    throw App.errors.MissingArgument unless @selector?
    super
    @el = document.querySelector(@selector)
  clear: ->
    super
    @el.innerHTML = ""
  flush: ->
    html = ""
    html += "#{line} <br />" for line in @lines
    p = document.createElement "p"
    p.innerHTML = html
    @el.appendChild p
    @resetLines()


# ### Alert display adapter
class App.AlertDisplay extends App.DisplayAdapter
  isBottleCountUnsafe: (bottle_count) -> (bottle_count > 5)
  flush: ->
    text = ""
    text += "#{line}\n" for line in @lines
    @resetLines()
    alert text


window.App = App


# ## Program main runner
# (jQuery document ready)
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
