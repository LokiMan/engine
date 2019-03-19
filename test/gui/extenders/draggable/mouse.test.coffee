spy = require '../../../../common/test_helpers/spy'
EventElement = require '../../eventElement'

describe 'MouseDraggable', ->
  MouseDraggableFactory = require '../../../../gui/extenders/draggable/mouse'

  initMouseDraggable = (actions, document = {})->
    documentEvents = EventElement document

    document.body = firstElementChild: {}

    MouseDraggable = MouseDraggableFactory document, (->)

    element = {}
    events = EventElement element

    guiElement = {}

    MouseDraggable element, actions, guiElement

    return {element, events, guiElement, MouseDraggable, documentEvents}

  it 'should call start on mousedown', ->
    start = spy()
    {events} = initMouseDraggable {start}

    events['mousedown'] {button: 0, clientX: 1, clientY: 2}

    expect(start.calls).to.eql [[1, 2]]

  it 'should skip starting draggable if clicked by right button', ->
    start = spy()
    {events} = initMouseDraggable {start}

    events['mousedown'] {button: 1}

    expect(start.calls).to.be.empty

  describe 'move', ->
    callMove = (e)->
      startMove = spy()
      move = spy()
      {events, documentEvents} = initMouseDraggable {startMove, move}

      events['mousedown'] {button: 0, clientX: 10, clientY: 20}
      result = documentEvents['mousemove'] e

      return {startMove, move, result, documentEvents}

    it 'should call startMove on first mouse move with coords', ->
      e = {clientX: 12, clientY: 25}

      {startMove} = callMove e

      expect(startMove.calls).to.eql [[10, 20]]

    it 'should not call startMove on other move', ->
      e = {clientX: 12, clientY: 25}

      {startMove, documentEvents} = callMove e
      documentEvents['mousemove'] e

      expect(startMove.calls.length).to.equal 1

    it 'should call move on mousemove with coords diffs', ->
      e = {clientX: 12, clientY: 25}

      {move} = callMove e

      expect(move.calls).to.eql [[2, 5]]

    it 'should call preventDefault if presents', ->
      e = {clientX: 12, clientY: 25, preventDefault: spy()}

      callMove e

      expect(e.preventDefault.calls).to.not.empty

    it 'should call stopPropagation if presents', ->
      e = {clientX: 12, clientY: 25, stopPropagation: spy()}

      callMove e

      expect(e.stopPropagation.calls).to.not.empty

    it 'should return false', ->
      e = {clientX: 12, clientY: 25}

      {result} = callMove e

      expect(result).to.be.false

  describe 'endMove', ->
    callEndMove = (e = {}, needMove)->
      actions = endMove: spy()
      {events, documentEvents} = initMouseDraggable actions

      events['mousedown'] {button: 0, clientX: 10, clientY: 20}
      if needMove
        documentEvents['mousemove'] e
      documentEvents['mouseup'] e

      return {endMove: actions.endMove, documentEvents}

    it 'should not call endMove on mouseup if no started', ->
      e = {clientX: 12, clientY: 25}

      {endMove} = callEndMove e

      expect(endMove.calls).to.be.empty

    it 'should call endMove on mouseup with coords diffs if was move', ->
      e = {clientX: 12, clientY: 25}

      {endMove} = callEndMove e, true

      expect(endMove.calls).to.eql [[2, 5]]

    it 'should clear document events', ->
      {documentEvents} = callEndMove()

      expect(Object.keys(documentEvents)).to.be.empty

  it 'should clear mousedown event on false action', ->
    {element, events, guiElement, MouseDraggable} = initMouseDraggable {}

    MouseDraggable element, false, guiElement

    expect(Object.keys(events)).to.be.empty

  it 'should clear previous events on new draggable', ->
    {element, events, guiElement, MouseDraggable} = initMouseDraggable {}

    MouseDraggable element, {}, guiElement

    expect(events['mousedown']).to.be.a 'function'

  it 'should call end on mouseup even if was not move', ->
    end = spy()
    {events, documentEvents} = initMouseDraggable {end}

    events['mousedown'] {button: 0, clientX: 1, clientY: 2}
    documentEvents['mouseup'] {clientX: 3, clientY: 7}

    expect(end.calls).to.eql [[2, 5]]
