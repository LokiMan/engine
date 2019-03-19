spy = require '../../../common/test_helpers/spy'

describe 'CreateElement Factory', ->
  CreateElementFactory = require '../../../gui/factories/createElementFactory'

  it 'should update props if it set', ->
    update = spy()
    GuiElement = -> {update}
    GuiElement._appendToCurrent = ->

    createElement = CreateElementFactory GuiElement, {createElement: ->}

    createElement 'div', {}

    expect(update.calls).to.not.empty

  it 'should append next if it set', ->
    append = spy()
    GuiElement = -> {append}
    GuiElement._appendToCurrent = ->
    createElement = CreateElementFactory GuiElement, {createElement: ->}

    createElement 'div', null, 'ap'

    expect(append.calls[0][0]).to.equal 'ap'

  it 'should use second argument as next if this type is function', ->
    next = (->)
    append = spy()
    GuiElement = -> {append}
    GuiElement._appendToCurrent = ->
    createElement = CreateElementFactory GuiElement, {createElement: ->}

    createElement 'div', next

    expect(append.calls[0][0]).to.equal next

  it 'should append child to current element', ->
    element = {}

    GuiElement = ->
    GuiElement._appendToCurrent = spy()

    createElement = CreateElementFactory GuiElement, {createElement: -> element}

    createElement 'div'

    expect(GuiElement._appendToCurrent.calls[0][0]).to.equal element
