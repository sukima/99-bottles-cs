require = window.require

describe 'AsyncSong', ->
  App = require('99bottles')
  {AsyncSong} = App
  timmer = App.defaults.loop_delay + 1

  describe 'constructor', ->

    it 'should set App.asyncRunning on', ->
      song = new AsyncSong(99)
      expect( App.asyncRunning ).toEqual on

  describe 'sing', ->

    beforeEach ->
      @display = jasmine.createSpyObj 'TestDisplay', ['clear','print','flush','isBottleCountUnsafe']
      jasmine.Clock.useMock()
      @callback = jasmine.createSpy('callback')

    it 'should stop when App.asyncRunning is off', ->
      song = new AsyncSong(10, @callback)
      song.setDisplay @display
      spyOn(song, 'singVerse').andCallThrough()
      song.sing()
      expect( song.singVerse ).toHaveBeenCalled()
      jasmine.Clock.tick(timmer)
      expect( song.singVerse.calls.length ).toEqual 2
      App.asyncRunning = off
      jasmine.Clock.tick(timmer)
      expect( song.singVerse.calls.length ).toEqual 3
      jasmine.Clock.tick(timmer)
      expect( song.singVerse.calls.length ).toEqual 3

    it 'should call the callback when finished', ->
      song = new AsyncSong(1, @callback)
      song.setDisplay @display
      spyOn(song, 'singVerse').andCallThrough()
      song.sing()
      expect( song.singVerse ).toHaveBeenCalled()
      jasmine.Clock.tick(timmer)
      expect( song.singVerse.calls.length ).toEqual 2
      jasmine.Clock.tick(timmer)
      expect( @callback ).toHaveBeenCalled()
