describe 'Text', ->
  Text = require '../../../gui/extenders/text'

  it 'should set textContent of dom element', ->
    element = {}
    text = '123'

    Text element, text

    expect(element.textContent).to.equal text