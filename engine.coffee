#!/usr/bin/env coffee

cmd = process.argv.splice(2, 1)[0]

if not cmd?
  console.info 'Use as engine <cmd>'
  process.exit 1

commands =
  run: ->
    require './runner'

if not commands[cmd]?
  console.error "ERROR: unknown command: #{cmd}"
  process.exit 1

commands[cmd]?()
