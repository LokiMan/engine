describe 'ScrollTop', ->
  ScrollTop = require '../../../gui/extenders/scrollTop'

  it 'should set scrollTop to scrollHeight if value is -1', ->
    element = scrollHeight: 100

    ScrollTop element, -1

    expect(element.scrollTop).to.equal element.scrollHeight

  it 'should set scrollTop to value if value is not -1', ->
    element = scrollHeight: 100

    ScrollTop element, 20

    expect(element.scrollTop).to.equal 20
    
  it 'should add getScrollTop function if value is true', ->
    guiElement = {}

    ScrollTop {}, true, guiElement

    expect(guiElement.getScrollTop).to.be.a 'function'

  it 'should return current scrollTop on call guiElement.getScrollTop()', ->
    element = {}
    guiElement = {}
    ScrollTop element, true, guiElement

    element.scrollTop = 18
    result = guiElement.getScrollTop()

    expect(result).to.equal 18
