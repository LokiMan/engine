path = require 'path'
fs = require 'fs'

CoreStarter = require './coreStarter'

Run = ->
  getGamePagesHash = ->
    gameDir = process.cwd()
    pathHash = path.join gameDir, 'res/js/hash.json'
    hashJsonText = fs.readFileSync pathHash, {encoding: 'utf8'}
    JSON.parse hashJsonText

  {
    router, reconnectAll, refreshGamePagesHash, entryPort, corePort
  } = CoreStarter getGamePagesHash

  router.get['/__core/refreshHash'] = (req, res)->
    refreshGamePagesHash()
    reconnectAll()
    res.end 'ok.\r\n'

  {entryPort, corePort}

module.exports = Run
