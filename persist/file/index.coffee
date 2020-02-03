path = require 'path'

Storage = require '../../storage/storage'

applyChanges = require './applyChanges'
OnChange = require './onChange'

FilePersist = (dataDir, fs, d = require('../../common/dates'), p = process)->
  pathGameData = path.join dataDir, 'data.json'
  pathChanges = path.join dataDir, 'changes.json'

  gameData = JSON.parse fs.readFileSync pathGameData, encoding: 'utf8'

  pathChanges = path.join dataDir, 'changes.json'
  if fs.existsSync pathChanges
    changes = fs.readFileSync(pathChanges, encoding: 'utf8')
  else
    fs.writeFileSync pathChanges, ''

  if p.env.NODE_ENV in ['production', 'test']
    backupName = d.nowDate().toISOString()

    backupDataPath = path.join dataDir, "#{backupName}_data.json"
    fs.renameSync pathGameData, backupDataPath

    backupChangesPath = path.join dataDir, "#{backupName}_changes.json"
    fs.renameSync pathChanges, backupChangesPath

  if changes?
    applyChanges gameData, changes

  fs.writeFileSync pathGameData, JSON.stringify(gameData, null, '\t')

  changesStream = fs.createWriteStream pathChanges, flags: 'w'
  onChange = OnChange changesStream, p

  return Storage gameData, onChange

module.exports = FilePersist
