spy = require '../../../common/test_helpers/spy'

describe 'Hover', ->
  Hover = require '../../../gui/extenders/hover'

  it 'should restore specified properties after mouseout', ->
    events = {}
    element = addEventListener: (name, cb)->
      events[name] = cb

    props =
      prop1: 1
      prop2: '2'

    guiElement =
      style:
        prop1: 0
      update: spy()

    Hover element, props, guiElement

    events['mouseover']()
    events['mouseout']()

    expect(guiElement.update.calls).to.eql [
      [style: {prop1: 1, prop2: '2'}]
      [style: {prop1: 0, prop2: ''}]
    ]
