spy = require '../../common/test_helpers/spy'

describe 'Ajax', ->
  Ajax = require '../../common/ajax'

  it 'should add data to url if method is get', ->
    success = spy()
    req = {open: spy(), send: (->), setRequestHeader: (->)}
    ajax = Ajax {XMLHttpRequest: -> req}

    ajax 'url', {a: 1, b: 'c'}

    expect(req.open.calls).to.eql [
      ['GET', 'url?a=1&b=c', true]
    ]

  it 'should call success on success', ->
    success = spy()
    req = {open: (->), send: (->), setRequestHeader: (->)}
    ajax = Ajax {XMLHttpRequest: -> req}

    ajax.post 'url', success
    req.readyState = 4
    req.status = 200
    req.onreadystatechange()

    expect(success.calls).to.not.empty

  it 'should call error on error', ->
    error = spy()
    req = {open: (->), send: (->), setRequestHeader: (->)}
    ajax = Ajax {XMLHttpRequest: -> req}

    ajax.post 'url', (->), error
    req.readyState = 4
    req.status = 100
    req.responseText = 'text'
    req.onreadystatechange()

    expect(error.calls).to.eql [
      [100, 'text']
    ]

  it 'should try to use ActiveX if no XMLHttpRequest', ->
    ActiveXObject = spy -> {open: (->), send: (->)}
    ajax = Ajax {ActiveXObject}

    ajax 'url'

    expect(ActiveXObject.calls).to.eql [['Microsoft.XMLHTTP']]

  it "should do nothing if can't do anything", ->
    req = {open: spy()}
    ajax = Ajax {ActiveXObject: -> throw new Error()}

    ajax 'url'

    expect(req.open.calls).to.be.empty

  it 'should unset onreadystatechange on abort', ->
    req = {open: (->), send: (->), setRequestHeader: (->), abort: (->)}
    ajax = Ajax {XMLHttpRequest: -> req}

    request = ajax.post 'url'
    request.abort()

    expect(req.onreadystatechange).to.be.null
