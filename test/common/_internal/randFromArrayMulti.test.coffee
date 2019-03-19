spy = require '../../../common/test_helpers/spy'

describe 'Rand from array multi', ->
  RandFromArrayMulti = require '../../../common/_internal/randFromArrayMulti'

  it 'should return array with length of count', ->
    array = [1, 2]
    randFromArrayMulti = RandFromArrayMulti fromArray: (-> array.shift())

    result = randFromArrayMulti [1, 2], 2

    expect(result.length).to.equal 2

  it 'should call rand.fromArray several times if value is exist', ->
    array = [1, 1, 1, 2]
    fromArray = spy ->
      array.shift()

    randFromArrayMulti = RandFromArrayMulti {fromArray}

    randFromArrayMulti [1, 2], 2

    expect(fromArray.calls.length).to.equal 4

