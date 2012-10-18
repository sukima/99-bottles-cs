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
# supporting files such as the original [source][1], [demo][1] or to run the
# [unit tests][1] You can visit the project [homepage][1]
#
# [99 bottles of beer]: http://99-bottles-of-beer.net/
# [1]: http://sukima.github.com/99-bottles-cs/
#
# ### How it works
# Depending on your environment and prefered execution method you instantiate a
# new Song and a new DisplayAdapter. Then you run the `sing()` method of the
# Song.
# 
# Depending on how you wish to display the output pick a DisplayAdapter. This
# file currently supports the following Display Adapters:
#
# * `ConsoleDisplay` - Will print the verses to the JavaScript console (default)
# * `AlertDisplay` - Will pop-up an alert for each verse
# * `DomDisplay` - Will manipulate a div to print out the song into it's contents
# * `JqDisplay` - Uses jQuery to do the same thing as the DomDisplay
#
# The two choices for execution method are:
#
# * `SyncSong` - Uses a for loop to iterate over the verses in the song (blocking)
# * `AsyncSong` - Uses setTimeout to iterate over the song (non-blocking)
#
# #### Example
#
#     display = new ConsoleDisplay()
#     song = new SyncSong(99)
#     song.setDisplay display
#     song.sing()


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
    MissingLibrary:
      name: "MissingLibrary"
      message: "missing jQuery library"


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
  printVerse: (bottle_count = @bottle_count, s = App.strings) ->
    @getDisplay().print "#{@bottles(bottle_count).cap()} #{s.on_the_wall}, #{@bottles(bottle_count)}."
    if bottle_count > 0
      @getDisplay().print "#{s.take_one_down.cap()}, #{@bottles(bottle_count - 1)} #{s.on_the_wall}."
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
# Because of this blocking if our loop is too long it can freeze the browser.
# The constructor will ask the user if they are sure they want to continue if the
# requested number of verses reach 1200 bottles. (limit chosen at a whim)
class App.SyncSong extends App.Song
  constructor: (bottles) ->
    if bottles >= 1200
      throw App.errors.BottleCountTooLarge unless confirm App.strings.large_loop_warn
    super bottles
  # We override the sing method to run our loop. Calling super allows us to use
  # the safety checks from the parent Song object above.
  sing: ->
    super
    # CoffeeScript abstracts for loops. This statement will not change
    # `@bottle_count`. In most cases this is preferred but in this one use case
    # it looks redundant to also decrement the variable on our own.
    #
    #     for i in [@bottle_count..0]
    #       @printVerse()
    #       @bottle_count--
    #
    # A better approach is to avoid a state/instance variable and instead
    # pass the counter to the function in question. The downside is that
    # `@bottle_count` will not hold an accurate value of the current state.
    # However, since this is in a synchronous method there is never going to be
    # need to access the state outside of the running loop. Only in
    # Asynchronous methods would the `@bottle_count` need to be accurate.
    @printVerse(count) for count in [@bottle_count..0]

    # The use of return at the end stops CS from creating a results array like
    # it usually does with the for loop. It's done purely so the JavaScript
    # created is slightly more efficient since we will not use the results.
    return


# ### Asynchronous Song
# This execution method uses JavaScript's `setTimeout` function to return the
# thread control back to the browser intermittently. This form of non-blocking
# allows the user to feel like he/she still can interact with the web page even
# though there is work being done in the background. Granted the work is
# blocking as it executes but because we only calculate on interval of the loop
# at a time in between the steps the browser lets the user interact. This form
# of asynconous code isn't trully threaded but will provide enough that it seems
# threaded. It also has the added advantage of allowing the verses to be printed
# out in a more delay manor as if the song was really being sung.
class App.AsyncSong extends App.Song
  # This constructor like the ones above also takes an optional *callback*
  # function which will allow things to happen after the song is finished.
  constructor: (bottles, @callback) ->
    super bottles
    App.asyncRunning = on
  # Handle the sing method and pass it on to the async recursive function.
  sing: ->
    super
    @singVerse()
  # This methos calls itself through the use of `setTimeout`.
  #
  # Each time it executes it checks the `App.asyncRunning` boolean to see if it
  # should abandon (finish) this loop or continue. When complete it will execute
  # the callback if it exists
  singVerse: =>
    if App.asyncRunning and @bottle_count >= 0
      @printVerse()
      @bottle_count--
      setTimeout @singVerse, App.defaults.loop_delay
    else
      @callback?()


# ## Display Adapters
# Used to display the results. Uses an adapter model to allow multiple ways to
# display the output.
class App.DisplayAdapter
  constructor: ->
    @resetLines()
  # this is only used for some adapters so we will default to "no"
  isBottleCountUnsafe: (bottle_count) -> no
  # clear() is responsable for clearing the output buffer (not applicable for
  # all adapters)
  clear: ->
    @resetLines()
  # print() will add a line of text to the output buffer
  print: (text) ->
    @lines.push text
  # flush() is responsible for displaying the output buffer. Functionally used to
  # display a full verse.
  flush: ->
  # resetLines() will clear out the internal output buffer. **this should be
  # called in every implementation of flush()**
  resetLines: ->
    @lines = []
  # getAdapter() is a static method which will create a new adapter based on a
  # string keyword. This is an entirely optional method designed to make web site
  # integration easier allowing the value of a input field drive the choice of
  # what display adapter to use. It also illustrates the use of the CS switch
  # statement.
  @getAdapter: (display_id, selector) ->
    switch display_id
      when "jq" then new App.JqDisplay(selector)
      when "alert" then new App.AlertDisplay
      when "dom" then new App.DomDisplay(selector)
      else new App.ConsoleDisplay


# ### Console Display Adapter (default)
# A simple display adapter that writes all output to the JavaScript console.
class App.ConsoleDisplay extends App.DisplayAdapter
  print: (text) ->
    console?.log text
  flush: ->
    console?.log "-----"


# ### Alert display adapter
# Another simple display adapter which prints out each verse in a pop-up alert.
#
# Because this can be a nightmare if the number of verses are large we will
# prevent this method from working if the bottle count is more then 5 verses.
# (5 seemed a reasonable number of pop-ups to go through).
class App.AlertDisplay extends App.DisplayAdapter
  isBottleCountUnsafe: (bottle_count) -> (bottle_count > 5)
  flush: ->
    text = ""
    text += "#{line}\n" for line in @lines
    @resetLines()
    alert text


# ### Non-jQuery dom display adapter
# This is an example on how to use a display adapter to manipulate a DIV and
# print the verses to it using the standard JavaScript DOM functions.
#
# We need a selector to work with so fail if one is missing.
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


# ### jQuery display adapter
# This does the same thing as the DomDisplay but uses jQuery syntax to
# manipulate the DOM. It also checks for a selector argument. If we attempt to
# use this class on a page that did not load jQuery it will have problems so we
# check to make sure jQuery is defined. Otherwise fail with an error.
class App.JqDisplay extends App.DisplayAdapter
  constructor: (@selector) ->
    throw App.errors.MissingArgument unless @selector?
    throw App.errors.MissingLibrary unless jQuery?
    super
    @el = jQuery(@selector)
  clear: ->
    super
    @el.empty()
  flush: ->
    html = "<p>"
    html += "#{line}<br />" for line in @lines
    html += "</p>"
    @el.append html
    @resetLines()


# If this file is used *without* using CommonJS (as you would if building from a
# node.js environment using [hem][]) then the module line won't work. We instead
# allow it to export to the window object. We also will export it for when we do
# run it in a CommonJS environment.
#
# [hem]: http://spinejs.com/docs/hem
window.App = App
module?.exports = App
