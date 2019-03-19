spy = require '../../../../common/test_helpers/spy'
EventElement = require '../../eventElement'

describe 'TouchClick', ->
  TouchClick = require '../../../../gui/extenders/click/touch'

  initTouchClick = (action)->
    element = {}
    events = EventElement element

    guiElement = {}

    TouchClick element, action, guiElement

    return {element, events, guiElement}

  it 'should call action on touchstart & touchend', ->
    action = spy()
    {events} = initTouchClick action

    events['touchstart'] touches: [{pageX: 0, pageY: 0}]
    events['touchend'] {}

    expect(action.calls).to.not.empty

  it 'should not call action if several touches on touchstart', ->
    action = spy()
    {events} = initTouchClick action

    events['touchstart'] touches: [{}, {}]
    events['touchend'] {}

    expect(action.calls).to.be.empty

  it 'should not call action if was touchcancel', ->
    action = spy()
    {events} = initTouchClick action

    events['touchstart'] touches: [{pageX: 0, pageY: 0}]
    events['touchcancel'] {}
    events['touchend'] {}

    expect(action.calls).to.be.empty

  it 'should clear event listeners on empty action', ->
    {element, events, guiElement} = initTouchClick (->)

    TouchClick element, null, guiElement

    expect(Object.keys(events)).to.be.empty

  describe 'boundary', ->
    endAfterMove = (action, {pageX = 0, pageY = 0})->
      {events} = initTouchClick action

      events['touchstart'] touches: [{pageX: 0, pageY: 0}]
      events['touchmove'] changedTouches: [{pageX, pageY}]
      events['touchend'] {}

    it 'should not call action if touch move beyond boundaries on X', ->
      action = spy()
      endAfterMove action, {pageX: 11}
      expect(action.calls).to.be.empty

    it 'should not call action if touch move beyond boundaries on -X', ->
      action = spy()
      endAfterMove action, {pageX: -11}
      expect(action.calls).to.be.empty

    it 'should not call action if touch move beyond boundaries on Y', ->
      action = spy()
      endAfterMove action, {pageY: 11}
      expect(action.calls).to.be.empty

    it 'should not call action if touch move beyond boundaries on -Y', ->
      action = spy()
      endAfterMove action, {pageY: -11}
      expect(action.calls).to.be.empty

