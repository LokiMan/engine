PackFor = (componentName)->
  fixActionName = (command)->
    if command[0].indexOf('.') is -1
      command[0] = componentName + '.' + command[0]
    return

  (command)->
    if Array.isArray command[0]
      commands = command[0]
      for cmd, i in commands
        fixActionName cmd
      command = commands
    else
      fixActionName command

    JSON.stringify command

module.exports = PackFor
