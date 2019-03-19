spy = require '../../../common/test_helpers/spy'

describe 'Value', ->
  Value = require '../../../gui/extenders/value'

  describe 'value', ->
    it 'should set value to dom element', ->
      domElement = {}
      value = {a: 1}

      Value domElement, value, {}

      expect(domElement.value).to.equal value

    it 'should define getter', ->
      domElement = {}
      guiElement = {}

      Value domElement, {a: 1}, guiElement

      expect(guiElement.value).to.equal domElement.value

    it 'should define setter', ->
      domElement = {}
      guiElement = {}

      Value domElement, {a: 1}, guiElement

      value2 = {a: 2}
      guiElement.value = value2

      expect(domElement.value).to.equal value2


  describe 'focus', ->
    it 'should call dom element focus on guiElement.focus()', ->
      domElement = focus: spy()
      guiElement = {}
      Value domElement, '', guiElement

      guiElement.focus()

      expect(domElement.focus.calls).to.not.empty
