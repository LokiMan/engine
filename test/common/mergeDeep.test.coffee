describe 'MergeDeep', ->
  mergeDeep = require '../../common/mergeDeep'

  it 'should merge two simple objects', ->
    obj1 = {a: 1, c: true}
    obj2 = {b: '2'}

    result = mergeDeep obj1, obj2

    expect(result).to.eql {
      a: 1
      b: '2'
      c: true
    }
    
  it 'should merge two complex objects', ->
    obj1 = {a: 1, b: 2, c: {d: '3', e: true}}
    obj2 = {a: 2, c: {d: 4, f: {a: 4}}}

    result = mergeDeep obj1, obj2

    expect(result).to. eql {
      a: 2, b: 2, c: {d: 4, e: true, f: {a: 4}}
    }

  it 'should not change target object', ->
    obj1 = {a: 1, b: 2}
    obj2 = {c: 3}

    mergeDeep obj1, obj2

    expect(obj1).to.eql {a: 1, b: 2}

  it 'should change target simple value to complex object', ->
    obj1 = {a: 1, c: true}
    obj2 = {c: {a: 2}}

    result = mergeDeep obj1, obj2

    expect(result).to.eql {
      a: 1
      c: {a: 2}
    }

  it 'should merge simple array fields', ->
    obj1 = {a: 1, c: true}
    obj2 = {c: [0, 1]}

    result = mergeDeep obj1, obj2

    expect(result).to.eql {
      a: 1
      c: [0, 1]
    }

  it 'should merge multiple sources', ->
    obj1 = {a: 1, c: true}
    obj2 = {c: [0, 1]}
    obj3 = {a: '2', d: {e: 1}}

    result = mergeDeep obj1, obj2, obj3

    expect(result).to.eql {
      a: '2'
      c: [0, 1]
      d: {e: 1}
    }
