path = require 'path'
fs = require 'fs'

initStorage = (gameDir, packageJson, NODE_ENV)->
  dataDir = path.join gameDir, './data/'

  checkDataFile = ->
    dataFilePath = path.join dataDir, 'data.json'
    return true if fs.existsSync dataFilePath
    return false if NODE_ENV isnt 'production' and NODE_ENV isnt 'test'

    fs.mkdirSync dataDir
    fs.writeFileSync dataFilePath, '{}', encoding: 'utf8'
    return true

  if checkDataFile()
    FilePersist = require '../persist/file/persist'
    FilePersist dataDir
  else
    Storage = require '../storage/storage'
    gameData = packageJson.data ? {}
    Storage gameData

module.exports = initStorage
