spy = require '../../../../common/test_helpers/spy'
EventElement = require '../../eventElement'

describe 'MouseClick', ->
  MouseClick = require '../../../../gui/extenders/click/mouse'

  initMouseClick = (action)->
    element = {}
    events = EventElement element

    guiElement = {}

    MouseClick element, action, guiElement

    return {element, events, guiElement}

  it 'should call action with guiElement and event on click', ->
    action = spy()
    {events, guiElement} = initMouseClick action
    event = {a: 1}

    events['click'] event

    expect(action.calls).to.eql [[guiElement, event]]

  it 'should clear event listeners on empty action', ->
    {element, events, guiElement} = initMouseClick (->)

    MouseClick element, null, guiElement

    expect(Object.keys(events)).to.be.empty

  it 'should clear events on other action', ->
    {element, events, guiElement} = initMouseClick (->)

    MouseClick element, (->), guiElement

    expect(events['click'].length).to.eql 1
