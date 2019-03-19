pathModule = require 'path'

Storage = require '../../storage/storage'

Persist = (dataDir, fs = require 'fs')->
  pathGameData = pathModule.join dataDir, 'data.json'

  gameData = JSON.parse fs.readFileSync pathGameData, encoding: 'utf8'

  # этот Storage без onChange, чтобы наложить изменения без
  # повторного их сохранения, и без cloneDeep данных
  storage = Storage gameData, (->), (obj)-> obj

  pathChanges = pathModule.join dataDir, 'changes.json'
  if not fs.existsSync pathChanges
    fs.writeFileSync pathChanges, ''

  content = fs.readFileSync pathChanges, encoding: 'utf8'

  if process.env.NODE_ENV in ['production', 'test']
    backupName = new Date().toISOString()

    backupDataPath = pathModule.join dataDir, "#{backupName}_data.json"
    fs.renameSync pathGameData, backupDataPath

    backupChangesPath = pathModule.join dataDir, "#{backupName}_changes.json"
    fs.renameSync pathChanges, backupChangesPath

  lines = content.split '\n'

  # убираем последнюю пустую строку, чтоб не мешалась в цикле
  if lines[lines.length - 1].length == 0
    lines.pop()

  try
    for line, i in lines
      command = JSON.parse line
      if Array.isArray command[0]
        for [cmd, path, args...] in command
          storage[cmd] path, args...
      else
        [cmd, path, args...] = command
        storage[cmd] path, args...
  catch e
    console.log e
    throw new Error "On parse changes on line #{i}:#{line}"

  fs.writeFileSync pathGameData, JSON.stringify(gameData, null, '\t')

  changesStream = fs.createWriteStream pathChanges, flags: 'w'

  buffer = []

  onChange = ->
    if buffer.length is 0
      process.nextTick writeBuffer

    buffer.push _argumentsToLine arguments

  _argumentsToLine = (args)->
    length = args.length
    line = new Array length
    i = 0
    while i < length
      arg = args[i] ? null
      line[i] = JSON.stringify arg
      i++

    return "[#{line.join(',')}]"

  writeBuffer = ->
    if buffer.length is 1
      changesStream.write buffer[0] + '\n'
    else
      changesStream.write "[#{buffer.join(',')}]\n"
    buffer.length = 0

  return Storage gameData, onChange

module.exports = Persist
