# ## Collapsible: jQuery plugin
# A simple plugin to add collapible support to divs
$ = jQuery

# ### Usage
# Initialized any element with the collapsible() function. This will wrap the
# element and add aheader which is clickable. Clicking on the header will
# toggle the original div to be visible or not.
#
# You can progromatically open and close using the collapsible("open") and
# collapsible("close") commands.
#
# You can turn of animation by passing false ass the second argument to
# collapsible.
#
# #### Example
#
#     require('collapsible');
#     // Initialize
#     $(".collapsible").collapsible();
#     // Close the div
#     $("#myDiv").collapsible("close");
#     // Open the div
#     $("#myDiv").collapsible("open");
#     // Close the div no animation
#     $("#myDiv").collapsible("close", false);
#
$.fn.extend
  collapsible: (command = "", async = true) ->
    return @each ->

      el = $(this)
      unless el.parent().hasClass("ui-collapsible")
        props =
          text: el.attr("title")
          class: "ui-opened"
          click: ->
            clicked_el = $(this)
            opened = clicked_el.parent().hasClass("ui-opened")
            command = if opened then "close" else "open"
            clicked_el.next().collapsible(command)

        el.wrap $("<div/>", {"class": "ui-collapsible ui-opened"})
        el.parent().prepend $("<h3/>", props)

      toggleClass = (e) -> e.toggleClass("ui-opened ui-closed")

      switch command
        when "close"
          toggleClass el.parent()
          toggleClass el.prev("h3")
          if async
            el.slideUp("fast")
          else
            el.hide()
        when "open"
          toggleClass el.parent()
          toggleClass el.prev("h3")
          if async
            el.slideDown("fast")
          else
            el.show()
