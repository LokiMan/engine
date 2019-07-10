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

  prevNum = -1

  try
    for line, i in lines
      commands = JSON.parse line

      currentNum = commands[0]
      if currentNum isnt prevNum + 1
        throw new Error 'On parse changes wrong numbering.'
      prevNum = currentNum

      length = commands.length
      cmdNum = 1 #skip first element - writeNum
      while cmdNum < length
        [cmd, path, args...] = commands[cmdNum]
        storage[cmd] path, args...
        cmdNum++
  catch e
    console.log e
    throw new Error "On parse changes on line #{i}:#{line}"

  fs.writeFileSync pathGameData, JSON.stringify(gameData, null, '\t')

  changesStream = fs.createWriteStream pathChanges, flags: 'w'

  buffer = []
  writeNum = 0

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
    changesStream.write "[#{writeNum},#{buffer.join(',')}]\n"
    buffer.length = 0
    writeNum++

  return Storage gameData, onChange

module.exports = Persist
