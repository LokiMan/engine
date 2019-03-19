spy = require '../../../common/test_helpers/spy'

describe 'MouseOver', ->
  MouseOver = require '../../../gui/extenders/mouseOver'

  it "should call addEventListener with 'mouseover'", ->
    element = addEventListener: spy()

    MouseOver element

    expect(element.addEventListener.calls[0][0]).to.equal 'mouseover'

  it 'should call action guiElement on mouseover', ->
    events = {}
    element = addEventListener: (name, cb)->
      events[name] = cb
    action = spy()
    guiElement = {}

    MouseOver element, action, guiElement
    events['mouseover']()

    expect(action.calls[0][0]).to.equal guiElement
