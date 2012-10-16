# ## Collapsible: jQuery plugin
# A simple plugin to add collapible support to divs
$ = jQuery

$.fn.extend
  collapsible: (option) ->
    return @each ->

      el = $(this)
      unless el.parent().hasClass("ui-collapsible")
        props =
          text: el.attr("title")
          click: ->
            clicked_el = $(this)
            opened = clicked_el.parent().hasClass("ui-opened")
            option = if opened then "close" else "open"
            clicked_el.next().collapsible(option)

        el.wrap $("<div/>", {"class": "ui-collapsible ui-opened"})
        el.parent().prepend $("<h3/>", props)

      switch option
        when "close"
          el.parent().removeClass("ui-opened")
          el.slideUp()
        when "open"
          el.parent().addClass("ui-opened")
          el.slideDown()
