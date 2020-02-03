UnpackAndRun = (onCommand)->
  runCommand = ([fullName, args...])->
    pos = fullName.indexOf '.'
    if pos is -1
      target = ''
      action = fullName
    else
      target = fullName[0...pos]
      action = fullName[(pos + 1)...]

    onCommand target, action, args

  (message)->
    try
      command = JSON.parse message
    catch
      return

    if Array.isArray command[0]
      for cmd in command
        runCommand cmd
    else
      runCommand command

    return

module.exports = UnpackAndRun
