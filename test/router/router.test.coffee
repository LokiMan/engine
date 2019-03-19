spy = require '../../common/test_helpers/spy'

describe 'Router', ->
  Router = require '../../router/router'

  it 'should add two routes for trailing slash (add slash)', ->
    router = Router()

    fooSpy = spy()
    router.get['/foo'] = fooSpy

    req = {method: 'GET', url: '/foo'}
    res = {setHeader: ->}

    router req, res
    expect(fooSpy.calls[0]).to.eql [req, res]

    req.url += '/'
    router req, res
    expect(fooSpy.calls[1]).to.eql [req, res]

  it 'should add two routes for trailing slash (remove slash)', ->
    router = Router()

    fooSpy = spy()
    router.get['/foo/'] = fooSpy

    req = {method: 'GET', url: '/foo'}
    res = {setHeader: ->}

    router req, res
    expect(fooSpy.calls[0]).to.eql [req, res]

    req.url += '/'
    router req, res
    expect(fooSpy.calls[1]).to.eql [req, res]


  it 'should skip adding slash for root route', ->
    router = Router()

    router.get['/'] = ->

    req = {method: 'GET', url: ''}
    res = {end: spy()}

    router req, res
    expect(res.end.calls).to.eql [['Not found']]


  it "should convert route with ':' to regexp", ->
    spyGet = spy()

    router = Router()

    router.get['/foo/:id/:id2'] = spyGet

    req = {method: 'GET', url: '/foo/123/asd'}
    res = {setHeader: ->}
    router req, res

    expect(spyGet.calls).to.eql [[{
      method: 'GET'
      url: '/foo/123/asd'
      params: {id: '123', id2: 'asd'}
    }, res]]

  it 'should call parseBody in simple request if method is POST', ->
    parseBody = spy()
    router = Router 1000, (->), parseBody
    router.post['/foo'] = (->)

    router {method: 'POST', url: '/foo'}, {}

    expect(parseBody.calls).to.not.empty

  it 'should call parseBody in regexp request if method is POST', ->
    parseBody = spy()
    router = Router 1000, (->), parseBody
    router.post['/foo/:bar'] = (->)

    router {method: 'POST', url: '/foo/123'}, {}

    expect(parseBody.calls).to.not.empty

  it 'should try obtain player if callback has third argument', (done)->
    player = {}
    router = Router 1000, (-> player)

    router.get['/foo'] = (req, res, pl)->
      expect(pl).to.equal player
      done()

    router {method: 'GET', url: '/foo'}, {setHeader: ->}

  it 'should add headers for no-cache', ->
    router = Router()
    res = setHeader: spy()
    req = {method: 'GET', url: '/foo'}
    router.get['/foo'] = ->

    router req, res

    expect(res.setHeader.calls[0]).to.eql [
      'Cache-Control',
      [ 'no-cache, no-store, must-revalidate, max-age=0',
        'post-check=0, pre-check=0' ]
    ]

  it 'should result code 400 and error on error in POST', ->
    router = Router 1000, (->), (req, num, cb)-> cb 'error1'
    res = setHeader: spy(), end: spy()
    router.post['/foo/:bar'] = (->)

    router {method: 'POST', url: '/foo/123'}, res

    expect(res.setHeader.calls[0]).to.eql [
      'Cache-Control',
      [ 'no-cache, no-store, must-revalidate, max-age=0',
        'post-check=0, pre-check=0' ]
    ]

    expect(res.statusCode).to.equal 400

    expect(res.end.calls).to.eql [['error1']]
