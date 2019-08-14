pp = require 'preprocess'
coffee = require 'coffeescript'
ParseError = require './parseError'

Compiler = (preprocessContext = {})->
  compile: (content, scriptName, ext, options = {})->
    try
      preprocessed = pp.preprocess content, preprocessContext, ext
      if ext is 'js' then preprocessed else coffee.compile preprocessed, options
    catch e
      throw if e.location?
        new ParseError e, content, scriptName + '.coffee'
      else
        e

module.exports = Compiler
