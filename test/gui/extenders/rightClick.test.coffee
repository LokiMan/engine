spy = require '../../../common/test_helpers/spy'

describe 'RightClick', ->
  RightClick = require '../../../gui/extenders/rightClick'

  it 'should set oncontextmenu if action', ->
    element = {}

    RightClick element, (->)

    expect(element.oncontextmenu).to.exist

  it 'should set oncontextmenu to null if no action', ->
    element = {oncontextmenu: ->}

    RightClick element

    expect(element.oncontextmenu).to.be.null

  it 'should call action with guiElement on oncontextmenu', ->
    element = {}
    action = spy()
    guiElement = {}

    RightClick element, action, guiElement
    element.oncontextmenu()

    expect(action.calls).to.eql [[guiElement]]

  it 'should return false from oncontextmenu', ->
    element = {}

    RightClick element, (->), {}
    result = element.oncontextmenu()

    expect(result).to.be.false

