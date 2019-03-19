describe "Spy", ->
  spy = require '../../../common/test_helpers/spy'

  it "should store calls info", ->
    spyFunc = spy()
    spyFunc 'a', 1
    expect(spyFunc.calls).to.eql [['a', 1]]

  it "should call received function on call", ->
    called = false
    spyFunc = spy(-> called = true)
    spyFunc()
    expect(called).to.equal true

  it "should copy array arg", ->
    spyFunc = spy()
    arr = [1, 2]
    spyFunc arr
    arr.length = 0
    expect(spyFunc.calls).to.eql [[[1, 2]]]