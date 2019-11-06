Remote = (connection, onCommand)->
  remote = (command...)->
    _sendRaw Remote.pack command

  _sendRaw = remote.raw = (message)->
    connection.send message

  remote.makeFor = (componentName)->
    (command...)->
      remote.callFor componentName, command

  remote.callFor = (componentName, command)->
    if Array.isArray command[0]
      messages = (for cmd in command[0]
        Remote.fixActionName componentName, cmd
        cmd)
      _sendRaw Remote.pack messages
    else
      _sendRaw Remote.packFor componentName, command

  connection.onMessage = (message)->
    try
      command = JSON.parse message
    catch
      return

    if Array.isArray command[0]
      for cmd in command
        runCommand cmd
      return
    else
      runCommand command

  runCommand = ([fullName, args...])->
    pos = fullName.indexOf '.'
    if pos is -1
      target = ''
      action = fullName
    else
      target = fullName[0...pos]
      action = fullName[(pos + 1)...]

    onCommand {target, action, args}

  return remote

Remote.pack = (command)->
  return JSON.stringify command

Remote.fixActionName = (componentName, command)->
  if command[0].indexOf('.') is -1
    command[0] = componentName + '.' + command[0]
  return

Remote.packFor = (componentName, command)->
  Remote.fixActionName componentName, command
  return Remote.pack command

module.exports = Remote
