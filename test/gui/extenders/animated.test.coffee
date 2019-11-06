describe 'Animated', ->
  Animated = require '../../../gui/extenders/animated'

  it 'should set animated value to guiElement', ->
    guiElement = {}
    value = true

    Animated {}, value, guiElement

    expect(guiElement.animated).to.equal value
