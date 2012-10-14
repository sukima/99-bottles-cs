require = window.require

describe "App", ->
  App = require("99bottles")

  it 'defines asyncRunning', -> expect( App.asyncRunning ).toBeDefined()
  it 'defines defaults', -> expect( App.defaults ).toBeDefined()
  it 'defines strings', -> expect( App.strings ).toBeDefined()
  it 'defines errors', -> expect( App.errors ).toBeDefined()
