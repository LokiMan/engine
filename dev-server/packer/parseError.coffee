util = require 'util'

ParseError = (error, src, file) ->
  SyntaxError.call this

  @message = error.message

  @line = error.location.first_line + 1
  @column = error.location.first_column + 1

  markerLen = 2
  if error.location.first_line == error.location.last_line
    markerLen += error.location.last_column - (error.location.first_column)

  @annotated = [
    file + ':' + @line
    src.split('\n')[@line - 1]
    Array(@column).join(' ') + Array(markerLen).join('^')
    'ParseError: ' + @message
  ].join('\n')

ParseError.prototype = Object.create(SyntaxError.prototype)

ParseError::toString = ->
  @annotated

ParseError::[util.inspect.custom] = ->
  @annotated

module.exports = ParseError
