OnChange = (changesStream, process)->
  buffer = []
  writeNum = 0

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

  ->
    if buffer.length is 0
      process.nextTick writeBuffer

    buffer.push _argumentsToLine arguments

module.exports = OnChange
