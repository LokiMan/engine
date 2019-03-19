spy = require '../../../../common/test_helpers/spy'
EventElement = require '../../eventElement'

describe 'TouchDraggable', ->
  TouchDraggable = require '../../../../gui/extenders/draggable/touch'

  initTouchDraggable = (actions)->
    element = {}
    events = EventElement element

    guiElement = {}

    TouchDraggable element, actions, guiElement

    return {element, events, guiElement}

  it 'should call start on touchstart', ->
    actions = start: spy()
    {events} = initTouchDraggable actions

    events['touchstart'] {touches: [{clientX: 1, clientY: 2}]}

    expect(actions.start.calls).to.eql [[1, 2]]

  move = (
    events, touches = [{clientX: 10, clientY: 20}]
    e = changedTouches: [{clientX: 12, clientY: 25}], preventDefault: spy()
  )->
    events['touchstart'] {touches}
    events['touchmove'] e
    return e

  it 'should call startMove with coords on begin touch move', ->
    actions = startMove: spy()
    {events} = initTouchDraggable actions

    move events

    expect(actions.startMove.calls).to.eql [[10, 20]]

  it 'should not call startMove on several touches', ->
    actions = startMove: spy()
    {events} = initTouchDraggable actions

    move events, [{clientX: 10, clientY: 20}, {}]

    expect(actions.startMove.calls).to.be.empty

  it 'should call move with diffs coords on touch move', ->
    actions = move: spy()
    {events} = initTouchDraggable actions

    move events

    expect(actions.move.calls).to.eql [[2, 5]]

  it 'should not start drag if touchCheck return false', ->
    actions = startMove: spy(), touchCheck: (-> false)
    {events} = initTouchDraggable actions

    move events

    expect(actions.startMove.calls).to.be.empty

  it 'should not call preventDefault if not started', ->
    actions = startMove: spy(), touchCheck: (-> false)
    {events} = initTouchDraggable actions

    e = move events

    expect(e.preventDefault.calls).to.be.empty

  it 'should call preventDefault if started', ->
    {events} = initTouchDraggable {}

    e = move events

    expect(e.preventDefault.calls).to.not.empty

  describe 'endMove', ->
    endMove = (
      events
      e = {
        changedTouches: [{clientX: 13, clientY: 27}]
        preventDefault: spy()
        stopPropagation: spy()
      }
    )->
      events['touchend'] e
      return e

    it 'should call endMove with diffs coords on touch end', ->
      actions = endMove: spy()
      {events} = initTouchDraggable actions

      move events
      endMove events

      expect(actions.endMove.calls).to.eql [[3, 7]]

    it 'should call preventDefault', ->
      {events} = initTouchDraggable {}

      move events
      e = endMove events

      expect(e.preventDefault.calls).to.not.empty

    it 'should call stopPropagation', ->
      {events} = initTouchDraggable {}

      move events
      e = endMove events

      expect(e.stopPropagation.calls).to.not.empty

  it 'should clear events on false action', ->
    {element, events, guiElement} = initTouchDraggable {}

    TouchDraggable element, false, guiElement

    expect(Object.keys(events)).to.be.empty

  it 'should call end on touch end even if was not move', ->
    actions = end: spy()
    {events} = initTouchDraggable actions

    events['touchstart'] {touches: [{clientX: 1, clientY: 2}]}
    events['touchend'] {changedTouches: [{clientX: 3, clientY: 7}]}

    expect(actions.end.calls).to.eql [[2, 5]]
