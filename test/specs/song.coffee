require = window.require

describe 'Class Song', ->
  {Song,strings} = require("99bottles")

  beforeEach ->
    @mock_display = jasmine.createSpyObj 'display', ['print', 'clear', 'flush', 'isBottleCountUnsafe']
    @song = new Song
    @s = strings
    @s.bottle = "A"
    @s.bottles = "B"
    @s.no_more = "C"

  describe 'constructor', ->

    it 'should throw an error with bottles < 1', ->
      @song = -> new Song(0)
      expect( @song ).toThrow()
      @song = -> new Song(-1)
      expect( @song ).toThrow()

    it 'should define bottle_count', ->
      expect( @song.bottle_count ).toBeDefined()
      @song = new Song(12345)
      expect( @song.bottle_count ).toBe 12345

  describe 'getDisplay', ->

    it 'should define display', ->
      d = @song.getDisplay()
      expect( @song.display ).toBeDefined()

  describe 'setDisplay', ->

    it 'should set display', ->
      @song.setDisplay "foo"
      expect( @song.display ).toBe "foo"

  describe 'bottles', ->

    it 'should return a string', ->
      expect( @song.bottles(100,@s) ).toMatch /B/

    it 'should handle non-plural', ->
      expect( @song.bottles(1,@s) ).toMatch /A/

    it 'should handle zero', ->
      expect( @song.bottles(0,@s) ).toMatch /C/

  describe 'printVerse', ->

    beforeEach ->
      @song.setDisplay @mock_display
      @song.printVerse()

    it 'should use a display adapter to print a verse', ->
      expect( @mock_display.print ).toHaveBeenCalled()
      expect( @mock_display.flush ).toHaveBeenCalled()

  describe 'sing', ->

    beforeEach ->
      @song.setDisplay @mock_display

    it 'should throw an error when display has unsafe bottle count', ->
      @mock_display.isBottleCountUnsafe.andReturn(true)
      expect( @song.sing ).toThrow()

    # Is calling clear really a requirement?
    xit 'should clear the display', ->
      @mock_display.isBottleCountUnsafe.andReturn(false)
      @song.sing()
      expect( @mock_display.clear ).toHaveBeenCalled()
