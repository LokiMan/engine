spy = require '../../common/test_helpers/spy'
{append, appendAsync, prepend, prependAsync} = require '../../common/appendPrepend'

describe 'Methods', ->
  describe 'Append', ->
    it 'should call previous function', ->
      prev = spy()
      obj = func: prev
      append obj, 'func', (->)

      obj.func 1, 2

      expect(prev.calls).to.eql [[1, 2]]

    it 'should call new function with result of prev', ->
      obj = func: -> 3
      append obj, 'func', newFunc = spy()

      obj.func 1, 2

      expect(newFunc.calls).to.eql [[1, 2, 3]]

    it 'should return prev function', ->
      prev = (->)
      obj = func: prev

      result = append obj, 'func', (->)

      expect(result).to.equal prev

    it 'should not throw if no prev func', ->
      fn = ->
        obj = {}
        append obj, 'func', (->)

        obj.func 1, 2

      expect(fn).to.not.throw()

    it 'should call append result array as array', ->
      obj = func: -> [3, 4]
      append obj, 'func', newFunc = spy()

      obj.func 1, 2

      expect(newFunc.calls).to.eql [[1, 2, [3, 4]]]

    it 'should use current this', ->
      obj = func: (-> 1)
      newObj = {}

      append obj, 'func', (-> this)

      result = obj.func.call newObj

      expect(result).to.eql newObj

    it 'should set object function as appended if no previous', ->
      obj = {}
      method = (->)

      append obj, 'method', method

      expect(obj.method).to.equal method

  describe 'Append Async Method', ->
    it 'should call previous function', ->
      prev = spy()
      obj = func: prev
      appendAsync obj, 'func', (->)

      await obj.func 1, 2

      expect(prev.calls).to.eql [[1, 2]]

    it 'should skip call new function without resolve promise', ->
      obj = func: -> 3
      appendAsync obj, 'func', newFunc = spy()

      obj.func 1, 2

      expect(newFunc.calls).to.be.empty

    it 'should call new function with result of prev', ->
      obj = func: -> 3
      appendAsync obj, 'func', newFunc = spy()

      await obj.func 1, 2

      expect(newFunc.calls).to.eql [[1, 2, 3]]

    it 'should return prev function', ->
      prev = (->)
      obj = func: prev

      result = appendAsync obj, 'func', (->)

      expect(result).to.equal prev

    it 'should not throw if no prev func', ->
      fn = ->
        obj = {}
        appendAsync obj, 'func', (->)

        obj.func 1, 2

      expect(fn).to.not.throw()

    it 'should call append result array as array', ->
      obj = func: -> [3, 4]
      appendAsync obj, 'func', newFunc = spy()

      await obj.func 1, 2

      expect(newFunc.calls).to.eql [[1, 2, [3, 4]]]

    it 'should use current this', ->
      obj = func: (-> 1)
      newObj = {}

      appendAsync obj, 'func', (-> this)

      result = await obj.func.call newObj

      expect(result).to.eql newObj

    it 'should set object function as appended if no previous', ->
      obj = {}
      method = (->)

      appendAsync obj, 'method', method

      expect(obj.method).to.equal method

  describe 'Prepend', ->
    it 'should call previous function', ->
      prev = spy()
      obj = func: prev
      prepend obj, 'func', (->)

      obj.func 1, 2

      expect(prev.calls).to.eql [[1, 2]]

    it 'should return prev function', ->
      prev = (->)
      obj = func: prev

      result = prepend obj, 'func', (->)

      expect(result).to.equal prev

    it 'should not throw if no prev func', ->
      fn = ->
        obj = {}
        prepend obj, 'func', (->)

        obj.func 1, 2

      expect(fn).to.not.throw()

    it 'should use current this', ->
      _call1 = null
      _call2 = null
      obj = func: (-> _call2 = this)
      newObj = {}
      prepend obj, 'func', (-> _call1 = this)

      obj.func.call newObj

      expect(_call1).to.eql newObj
      expect(_call2).to.eql newObj

    it 'should set object function as prepended if no previous', ->
      obj = {}
      method = (->)

      prepend obj, 'method', method

      expect(obj.method).to.equal method

  describe 'Prepend Async Method', ->
    it 'should call previous function', ->
      prev = spy()
      obj = func: prev
      prependAsync obj, 'func', (->)

      await obj.func 1, 2

      expect(prev.calls).to.eql [[1, 2]]

    it 'should skip call prev function without resolve promise', ->
      prev = spy()
      obj = func: prev
      prependAsync obj, 'func', (->)

      obj.func 1, 2

      expect(prev.calls).to.be.empty

    it 'should return prev function', ->
      prev = (->)
      obj = func: prev

      result = prependAsync obj, 'func', (->)

      expect(result).to.equal prev

    it 'should not throw if no prev func', ->
      fn = ->
        obj = {}
        prependAsync obj, 'func', (->)

        obj.func 1, 2

      expect(fn).to.not.throw()

    it 'should use current this', ->
      _call1 = null
      _call2 = null
      obj = func: (-> _call2 = this)
      newObj = {}
      prependAsync obj, 'func', (-> _call1 = this)

      await obj.func.call newObj

      expect(_call1).to.eql newObj
      expect(_call2).to.eql newObj

    it 'should set object function as prepended if no previous', ->
      obj = {}
      method = (->)

      prependAsync obj, 'method', method

      expect(obj.method).to.equal method
