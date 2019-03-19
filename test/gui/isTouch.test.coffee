describe 'isTouch', ->
  isTouch = require '../../gui/isTouch'

  it 'should return true if set window.ontouchstart', ->
    result = isTouch {ontouchstart: {}}, {}

    expect(result).to.be.true

  it 'should return true if document is instance of DocumentTouch', ->
    class DocumentTouch

    result = isTouch {'DocumentTouch': DocumentTouch}, new DocumentTouch

    expect(result).to.be.true
