spy = require '../../../common/test_helpers/spy'

describe 'MouseOut', ->
  MouseOut = require '../../../gui/extenders/mouseOut'

  it "should call addEventListener with 'mouseout'", ->
    element = addEventListener: spy()

    MouseOut element

    expect(element.addEventListener.calls[0][0]).to.equal 'mouseout'

  it 'should call action guiElement on mouseout', ->
    events = {}
    element = addEventListener: (name, cb)->
      events[name] = cb
    action = spy()
    guiElement = {}

    MouseOut element, action, guiElement
    events['mouseout']()

    expect(action.calls[0][0]).to.equal guiElement
