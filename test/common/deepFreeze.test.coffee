describe 'DeepFreeze', ->
  deepFreeze = require '../../common/deepFreeze'

  it 'should freeze deep', ->
    a = b: c: '1'

    deepFreeze a
    a.b.c = '2'

    expect(a.b.c).to.equal '1'
