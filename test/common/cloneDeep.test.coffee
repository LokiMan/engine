describe 'Deep clone', ->
  cloneDeep = require '../../common/cloneDeep'

  it 'should return null if null', ->
    result = cloneDeep null
    expect(result).to.equal null

  it 'should return undefined if undefined', ->
    result = cloneDeep undefined
    expect(result).to.equal undefined

  it 'should return new instance of Date if Date', ->
    date = new Date()
    result = cloneDeep date
    expect(result).to.be.instanceOf Date
    expect(result).to.eql date

  it 'should return value if not an object', ->
    string = 1
    result = cloneDeep string
    expect(result).to.equal string

    string = 'a'
    result = cloneDeep string
    expect(result).to.equal string

  it 'should return copy of Arrays', ->
    array = [1, 2]
    result = cloneDeep array
    expect(result).to.not.equal array

  it 'should return copy of Objects', ->
    object = {a: 1, b: 2}
    result = cloneDeep object
    expect(result).to.not.equal object

  it 'should work recursive', ->
    object = {a: [1, 2], b: {c: 3, d: 'a'}}

    result = cloneDeep object

    expect(result['a']).to.eql object['a']
    expect(result['a']).to.not.equal object['a']

    expect(result['b']).to.eql object['b']
    expect(result['b']).to.not.equal object['b']

  it 'should return new RegExp', ->
    regExp = /a^b/im
    result = cloneDeep regExp
    expect(result).to.be.instanceOf RegExp
    expect(result).to.eql regExp

  it 'should skip functions during cloning', ->
    obj = c: 1, b: (->)

    a = cloneDeep obj

    expect(Object.keys(a)).to.not.include 'b'

  it 'should not skip functions if set flag', ->
    obj = c: 1, b: (->)

    a = cloneDeep obj, functions: yes

    expect(Object.keys(a)).to.include 'b'

  it 'should not skip functions if set flag recursively', ->
    obj = c: 1, d: {e: ->}

    a = cloneDeep obj, functions: yes

    expect(Object.keys(a.d)).to.include 'e'
