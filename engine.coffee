#!/usr/bin/env coffee

cmd = process.argv.splice(2, 1)[0]

if not cmd?
  console.info 'Use as engine <cmd> args...'
  process.exit 1

commands =
  run: ->
    if process.env.NODE_ENV in ['production', 'test']
      require('./runner/run')()
    else
      require('./runner/devReload')()

  serve: ->
    require('./dev-server/serve')()

  build: ->
    require('./runner/build')()

  gen: ->
    require('./runner/utils/generate')()

if not (command = commands[cmd])?
  console.error "ERROR: unknown command: #{cmd}"
  process.exit 1

command()
