require = window.require

describe "String::cap()", ->
  require("99bottles")

  it 'capitalizes the first character', ->
    expect( "this is a test".cap() ).toBe "This is a test"

  it 'ignores non-alpha and already capitalized letters', ->
    expect( "123".cap() ).toBe "123"
    expect( "ABC".cap() ).toBe "ABC"
