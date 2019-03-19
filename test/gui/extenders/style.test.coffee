spy = require '../../../common/test_helpers/spy'

describe 'style', ->
  StyleFactory = require '../../../gui/extenders/style'

  initStyle = (extenders = {})->
    StyleFactory extenders

  it 'should add style to guiElement', ->
    guiElement = {}
    Style = initStyle()

    Style {}, {}, guiElement

    expect(guiElement.style).to.exist

  it 'should copy stules to style', ->
    Style = initStyle()
    element = {style: {}}

    styles = {st1: true, st2: ''}
    Style element, styles, {}

    expect(element.style).to.eql styles

  it 'should use extender for styles if exist', ->
    Style = initStyle {
      st2: (style, v)-> style.st2 = 'asd'
    }
    element = {style: {}}

    Style element, {st1: true, st2: ''}, {}

    expect(element.style).to.eql {st1: true, st2: 'asd'}
