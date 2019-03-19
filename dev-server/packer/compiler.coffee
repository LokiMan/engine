pp = require 'preprocess'
coffee = require 'coffeescript'
ParseError = require './parseError'

Compiler = (preprocessContext = {})->
  compile: (content, scriptName, options = {})->
    try
      preprocessed = pp.preprocess content, preprocessContext, 'coffee'
      return coffee.compile preprocessed, options
    catch e
      throw if e.location?
        new ParseError e, content, scriptName + '.coffee'
      else
        e

module.exports = Compiler
