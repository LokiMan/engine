describe 'visible', ->
  visible = require '../../../gui/extenders/visible'

  it "should set style.display 'none' if false", ->
    style = {}

    visible {style}, false, {}

    expect(style.display).to.equal 'none'

  it "should set style.display '' if true", ->
    style = {}

    visible {style}, true, {}

    expect(style.display).to.equal ''

  it 'should set isVisible to guiElement as value', ->
    guiElement = {}
    value = 123

    visible {style: {}}, value, guiElement

    expect(guiElement.isVisible).to.equal value
