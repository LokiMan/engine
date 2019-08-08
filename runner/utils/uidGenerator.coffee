dates = require '../../common/dates'
{RandomString} = require '../../common/rand'

UID_EXPIRES_3_YEARS = 1000 * 60 * 60 * 24 * 365 * 3

UIDGenerator = (
  playersCollection, router, GamePage
  {cookieName = 'uid', expires = UID_EXPIRES_3_YEARS} = {}
)->
  randomString = RandomString playersCollection

  indexPage = GamePage {}

  router.get['/'] = (req, res, player)->
    if not player?
      uid = randomString 20

      now = dates.now()
      expiresStr = dates.fromValue(now + expires).toUTCString()
      res.setHeader 'Set-Cookie', [
        "#{cookieName}=#{uid}; expires=#{expiresStr}; HttpOnly=true"
      ]

    res.end indexPage.render()

  getUid = (cookie)->
    return cookie[cookieName]

  {getUid}

module.exports = UIDGenerator
