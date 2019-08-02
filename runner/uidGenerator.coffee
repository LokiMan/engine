dates = require '../common/dates'
{RandomString} = require '../common/rand'

UID_EXPIRES_3_YEARS = 1000 * 60 * 60 * 24 * 365 * 3

UIDGenerator = (
  playersCollection, router, GamePage
  cookieName = 'uid', expiresMSec = UID_EXPIRES_3_YEARS
)->
  randomString = RandomString playersCollection

  indexPage = GamePage {}

  router.get['/'] = (req, res, player)->
    if not player?
      uid = randomString 20

      now = dates.now()
      expires = dates.fromValue (now + expiresMSec)
      res.setHeader 'Set-Cookie', [
        "#{cookieName}=#{uid}; expires=#{expires.toUTCString()}; HttpOnly=true"
      ]

    res.end indexPage.render()

  getUid = (cookie)->
    return cookie[cookieName]

  {getUid}

module.exports = UIDGenerator
