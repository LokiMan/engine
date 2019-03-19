describe 'style', ->
  Extenders = require '../../../gui/extenders/index'

  it 'should add mouse over/out if not touch', ->
    extenders = Extenders false, body: firstElementChild: {}

    expect(extenders.mouseOver).to.be.exist
    expect(extenders.mouseOut).to.be.exist
