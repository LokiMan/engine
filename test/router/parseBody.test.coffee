describe "Parse body", ->
  parseBody = require '../../router/parseBody'

  it "should read body from stream", (done)->
    EventEmitter = require '../../common/eventEmitter'
    req = EventEmitter()

    parseBody req, 1000, (err)->
      expect(err).to.be.a.null
      expect(req.body).to.eql {asd: '123', login: '123asd'}
      done()

    req.emit 'data', Buffer.from "asd="
    req.emit 'data', Buffer.from "123&"
    req.emit 'data', Buffer.from "login=123"
    req.emit 'data', Buffer.from "asd"
    req.emit 'end'

  it "should return error 'entity.too.large' if entry params bigger than 1Kb", (done)->
    EventEmitter = require '../../common/eventEmitter'
    req = EventEmitter()

    parseBody req, 1000, (err)->
      expect(err).to.equal 'entity.too.large'
      done()

    array = 'a'.repeat 1001

    req.emit 'data', Buffer.from array
