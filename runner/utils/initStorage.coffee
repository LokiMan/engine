path = require 'path'
fs = require 'fs'

initStorage = (gameDir, gameData, NODE_ENV)->
  dataDir = path.join gameDir, './data/'

  checkDataFile = ->
    dataFilePath = path.join dataDir, 'data.json'
    return true if fs.existsSync dataFilePath
    return false if NODE_ENV is 'local'

    fs.mkdirSync dataDir
    fs.writeFileSync dataFilePath, '{}', encoding: 'utf8'
    return true

  if gameData? or not checkDataFile()
    Storage = require '../../storage/storage'
    Storage gameData ? {}
  else
    FilePersist = require '../../persist/file'
    FilePersist dataDir, fs

module.exports = initStorage
