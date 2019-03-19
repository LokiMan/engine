describe 'ZIndex', ->
  ZIndex = require '../../../gui/extenders/zIndex'

  it 'should set value of style', ->
    element = {style: {}}

    ZIndex element, 2, {}

    expect(element.style.zIndex).to.equal 2

  it 'should store value', ->
    guiElement = {}
    ZIndex {style: {}}, 3, guiElement

    result = guiElement.zIndex

    expect(result).to.equal 3
