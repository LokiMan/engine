describe 'Html', ->
  Html = require '../../../gui/extenders/html'

  it 'should set textContent of dom element', ->
    element = {}
    html = '123'

    Html element, html

    expect(element.innerHTML).to.equal html
