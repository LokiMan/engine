Storage = require '../../storage/storage'

ApplyChanges = (gameData, changes)->
  # этот Storage без onChange, чтобы наложить изменения без
  # повторного их сохранения, и без cloneDeep данных
  storage = Storage gameData, (->), (obj)-> obj

  lines = changes.split '\n'

  # убираем последнюю пустую строку, чтоб не мешалась в цикле
  if lines[lines.length - 1].length == 0
    lines.pop()

  prevNum = -1

  try
    for line, i in lines
      commands = JSON.parse line

      currentNum = commands[0]
      if currentNum isnt prevNum + 1
        throw new Error 'wrong numbering'
      prevNum = currentNum

      length = commands.length
      cmdNum = 1 #skip first element - writeNum
      while cmdNum < length
        [cmd, path, args...] = commands[cmdNum]
        storage[cmd] path, args...
        cmdNum++
  catch e
    throw new Error "On parse changes on line #{i}:#{line}, #{e}"

  return

module.exports = ApplyChanges
