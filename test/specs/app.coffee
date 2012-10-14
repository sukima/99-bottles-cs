require = window.require

describe "App", ->
  require("99bottles")
  App = window.App

  it 'can noop', ->
