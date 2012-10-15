require = window.require

describe 'SyncSong', ->
  {SyncSong} = require('99bottles')

  describe 'constructor', ->

    beforeEach ->
      spyOn(window, 'confirm').andReturn(false)
      @testConstructor = -> new SyncSong(2000)

    it 'should ask the user to continue with a high bottle count', ->
      try @testConstructor()
      expect( window.confirm ).toHaveBeenCalled()

    it 'should throw an error if user cancles', ->
      expect( @testConstructor ).toThrow()
