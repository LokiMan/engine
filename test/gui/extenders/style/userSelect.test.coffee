describe 'Gray', ->
  Gray = require '../../../../gui/extenders/style/gray'

  it 'should add isGray to guiElement', ->
    value = {a: 1}
    guiElement = {}
    Gray {}, value, {}, guiElement

    expect(guiElement.isGray).to.equal value

  it 'should off if false', ->
    style = {}
    Gray style, false, {}, {}

    expect(style.filter).to.equal 'none'

