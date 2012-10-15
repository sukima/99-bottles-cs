require = window.require

describe 'DisplayAdapter', ->
  {DisplayAdapter} = require('99bottles')

  beforeEach ->
    @display = new DisplayAdapter

  describe 'constructor', ->

    it 'should define lines property', ->
      expect( @display.lines ).toBeDefined()

  xdescribe 'isBottleCountUnsafe', ->

  xdescribe 'clear', ->

  describe 'print', ->

    it 'should add a line to lines property', ->
      @display.lines = ['foobar']
      @display.print "barfoo"
      expect( @display.lines.length ).toEqual 2
      expect( @display.lines[1] ).toEqual "barfoo"

  describe 'resetLines', ->

    it 'should empty the lines property', ->
      @display.lines = ['foobar']
      @display.resetLines()
      expect( @display.lines.length ).toEqual 0

  describe 'getAdapter', ->

    beforeEach ->
      spyOn(App, 'ConsoleDisplay').andReturn({val:"CONSOLE"})
      spyOn(App, 'AlertDisplay').andReturn({val:"ALERT"})
      spyOn(App, 'DomDisplay').andReturn({val:"DOM"})
      spyOn(App, 'JqDisplay').andReturn({val:"JQUERY"})

    it 'should return a new AlertDisplay with tag "alert"', ->
      d = DisplayAdapter.getAdapter('alert')
      expect( App.AlertDisplay ).toHaveBeenCalled()
      expect( d?.val ).toEqual "ALERT"

    it 'should return a new DomDisplay with tag "dom"', ->
      d = DisplayAdapter.getAdapter('dom')
      expect( App.DomDisplay ).toHaveBeenCalled()
      expect( d?.val ).toEqual "DOM"

    it 'should return a new JqDisplay with tag "jq"', ->
      d = DisplayAdapter.getAdapter('jq')
      expect( App.JqDisplay ).toHaveBeenCalled()
      expect( d?.val ).toEqual "JQUERY"

    it 'should return a new ConsoleDisplay with tag "console"', ->
      d = DisplayAdapter.getAdapter('console')
      expect( App.ConsoleDisplay ).toHaveBeenCalled()
      expect( d?.val ).toEqual "CONSOLE"

    it 'should return a new ConsoleDisplay as default', ->
      d = DisplayAdapter.getAdapter('default_value')
      expect( App.ConsoleDisplay ).toHaveBeenCalled()
      expect( d?.val ).toEqual "CONSOLE"
