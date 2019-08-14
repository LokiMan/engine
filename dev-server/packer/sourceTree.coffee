SourceTree = (
  engineDir, srcDir, compiler, loadFile, guiNames, Path = require 'path'
)->
  guiRegexp = ///\b(#{guiNames.join('|')})\s*=///g

  files = new Map

  addSource = (pathToFile, source, currentDir = srcDir, ext = 'coffee')->
    compiled = compiler.compile source, pathToFile, ext, bare: true

    if guiRegexp.test compiled
      throw new Error "
        #{pathToFile} includes gui override: #{compiled.match guiRegexp}"

    requires = []

    compiled = compiled.replace /require\(('|")(.+?)\1\)/g, (_, __, filePath)->
      if filePath[0] is '.'
        if filePath.split('/').includes 'server'
          throw new Error "'server' in require path: '#{filePath}'
            in file #{pathToFile}"

        fullPath = Path.join currentDir, filePath
      else
        fullPath = Path.join engineDir, filePath

      file = addFile Path.relative srcDir, fullPath

      requires.push file

      return "require(#{file.index})"

    if (file = files.get pathToFile)?
      index = file.index
      file.requires = requires
    else
      index = files.size
      file = {index, source, requires, path: pathToFile, ext}
      files.set pathToFile, file

    file.compiled = "
      var module = _modules_['#{index}'] = {exports: {}};\
      (function(require, module, exports) {\n\n#{compiled}\n}).call(\
      module.exports, _require_, module, module.exports);"

    return file

  addFile = (path)->
    if (file = (files.get(path) ? files.get(path + '/index')))?
      return file

    reAddFile path

  reAddFile = (path)->
    fullPathToFile = Path.join srcDir, path
    {add, ext, source} = loadFile fullPathToFile
    currentDir = Path.dirname fullPathToFile + add

    addSource path + add, source, currentDir, ext

  {files, addSource, addFile, reAddFile}


SourceTree.create = (engineDir, srcDir, compilerOptions)->
  fs = require 'fs'

  Compiler = require './compiler'

  guiElements = (require '../../gui/elements')()
  guiNames = Object.keys guiElements

  loadFile = (path)->
    tries = [
      ['', 'coffee'], ['/index', 'coffee']
      ['', 'js'], ['/index', 'js']
    ]

    for [add, ext] in tries
      pathAdd = path + add
      pathAddExt = pathAdd + '.' + ext
      if fs.existsSync pathAddExt
        source = fs.readFileSync pathAddExt, 'utf8'

        return {add, ext, source}

    throw new Error "File not found: #{path}"

  compiler = Compiler compilerOptions

  sourceTree = SourceTree engineDir, srcDir, compiler, loadFile, guiNames

  {sourceTree, guiNames, compiler}

module.exports = SourceTree
