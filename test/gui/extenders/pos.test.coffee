spy = require '../../../common/test_helpers/spy'

describe 'Pos', ->
  Pos = require '../../../gui/extenders/pos'

  describe 'not animated', ->
    it 'should add .pos to guiElement', ->
      guiElement = {}
  
      Pos {}, {}, guiElement
  
      expect(guiElement.pos).to.exist
      
    describe 'as array', ->
      it 'should set style.position to absolute', ->
        element = style: {}
        
        Pos element, [], {}
        
        expect(element.style.position).to.equal 'absolute'
        
      it 'should copy array elements to style with px', ->
        element = style: {}

        Pos element, [10, 20, 30, 40], {}

        expect(element.style).to.eql {
          position: 'absolute'
          left: '10px'
          top: '20px'
          width: '30px'
          height: '40px'
        }

      it 'should copy values to guiElement.pos', ->
        guiElement = {}

        Pos {style: {}}, [10, 20, 30, 40], guiElement

        expect(guiElement.pos).to.eql {
          '0': 10, '1': 20, '2': 30, '3': 40,
          left: 10, top: 20, width: 30, height: 40
        }

    describe 'as object', ->
      it 'should not set style.position to absolute on empty object', ->
        element = style: {}

        Pos element, {}, {}

        expect(element.style.position).to.not.exist

      it 'should set style.position to absolute if present left in pos', ->
        element = style: {}

        Pos element, {left: 1}, {}

        expect(element.style.position).to.equal 'absolute'

      it 'should set style.position to absolute if present top in pos', ->
        element = style: {}

        Pos element, {top: 1}, {}

        expect(element.style.position).to.equal 'absolute'

      it 'should set style.position to absolute if present right in pos', ->
        element = style: {}

        Pos element, {right: 1}, {}

        expect(element.style.position).to.equal 'absolute'

      it 'should set style.position to absolute if present bottom in pos', ->
        element = style: {}

        Pos element, {bottom: 1}, {}

        expect(element.style.position).to.equal 'absolute'

      it 'should copy elements to style with px', ->
        element = style: {}

        Pos element, {
          left: 10, top: 20, width: 30, height: 40, right: 50, bottom: 60
        }, {}

        expect(element.style).to.eql {
          position: 'absolute'
          left: '10px'
          top: '20px'
          width: '30px'
          height: '40px'
          right: '50px'
          bottom: '60px'
        }

      it 'should copy values to guiElement.pos', ->
        guiElement = {}

        Pos {style: {}}, {
          left: 10, top: 20, width: 30, height: 40, right: 50, bottom: 60
        }, guiElement

        expect(guiElement.pos).to.eql {
          '0': 10, '1': 20, '2': 30, '3': 40, '4': 50, '5': 60
          left: 10, top: 20, width: 30, height: 40, right: 50, bottom: 60
        }

  describe 'animated', ->
    initPos = (element = {style: {}}, pos = [10, 20, 30, 40], guiElement = {})->
      guiElement.animated = true
      Pos element, pos, guiElement
      return element.style

    it 'should add absolute position to style', ->
      style = initPos()

      expect(style.position).to.equal 'absolute'

    it 'should set left&top to 0', ->
      style = initPos()

      expect(style.left).to.equal '0'
      expect(style.top).to.equal '0'

    it 'should set guiElement.pos to pos', ->
      pos = [1, 2, 3, 4]
      guiElement = {}

      initPos undefined, pos, guiElement

      expect(guiElement.pos).to.equal pos

    it 'should add translate3d(left, top, 0) transform', ->
      style = initPos()

      expect(style.transform).to.equal 'translate3d(10px, 20px, 0px)'

    it 'should set style width&height if pos.length > 2', ->
      style = initPos()

      expect(style.width).to.equal '30px'
      expect(style.height).to.equal '40px'

    it 'should just change pos if pos.length <= 2', ->
      pos = [3, 4]
      guiElement = {pos: [1, 2]}

      initPos undefined, pos, guiElement

      expect(guiElement.pos).to.eql [3, 4]
