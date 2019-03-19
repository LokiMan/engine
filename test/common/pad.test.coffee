describe 'Pad', ->
  pad = require '../../common/pad'

  it 'should add 0 if v < 10', ->
    v = 3

    result = pad v

    expect(result).to.equal '03'

  it 'should not add 0 if v > 10', ->
    v = 13

    result = pad v

    expect(result).to.equal '13'

  it 'should not add 0 if v is 10', ->
    v = 10

    result = pad v

    expect(result).to.equal '10'
