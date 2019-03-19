spy = require '../../../common/test_helpers/spy'

describe 'GuiElement Factory', ->
  GuiElementFactory = require '../../../gui/factories/guiElementFactory'

  describe 'update', ->
    it 'should call extenders function if exists', ->
      extender1 = spy()
      element = {}
      GuiElement = GuiElementFactory {extender1}
      guiElement = GuiElement element

      value = 1
      guiElement.update {extender1: value}

      expect(extender1.calls).to.eql [[element, value, guiElement]]

    it 'should just set value if not extender', ->
      GuiElement = GuiElementFactory {}
      element = {}
      guiElement = GuiElement element
      value = 2

      guiElement.update {name: value}

      expect(element.name).to.equal value

  describe 'clear', ->
    it 'should call removeChild for all the firstChild of element', ->
      firstChild = {}
      element = {
        removeChild: spy ->
          delete element.firstChild
        firstChild
      }
      GuiElement = GuiElementFactory {}
      guiElement = GuiElement element

      guiElement.clear()

      expect(element.removeChild.calls).to.eql [[firstChild]]

  describe 'append', ->
    it 'should call next with element', ->
      GuiElement = GuiElementFactory {}
      next = spy()
      guiElement = GuiElement()

      guiElement.append next

      expect(next.calls).to.eql [[guiElement]]

    it 'should appendChild to dom element', ->
      GuiElement = GuiElementFactory {}
      domElement = appendChild: spy()
      guiElement = GuiElement domElement

      domElement2 = {}
      guiElement2 = GuiElement domElement2

      guiElement.append guiElement2

      expect(domElement.appendChild.calls).to.eql [[domElement2]]

