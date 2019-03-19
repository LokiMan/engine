fs = require 'fs'
path = require 'path'

FileReader = require './fileReader'
Compiler = require './compiler'
Concat = require 'concat-with-sourcemaps'

guiElements = (require '../../gui/elements')()
guiNames = Object.keys guiElements
guiRegexp = ///\b(#{guiNames.join('|')})\s*=///g

fileReader = FileReader fs
compiler = Compiler {DEVELOPMENT: true}

Development = (engineDir, rootDir, entry)->
  files = new Map

  prelude = 'var _modules_ = {}; var _require_ = function(index)
{return _modules_[index].exports;}; var gui;'

  files.set 'prelude', {compiled: prelude}

  loadFile = (pathToFile)->
    fullPathToFile = path.join rootDir, pathToFile
    currentPath = path.dirname fullPathToFile
    source = fileReader.read fullPathToFile

    addSource pathToFile, currentPath, source

  addSource = (pathToFile, currentPath, source)->
    compiled = compiler.compile source, pathToFile, bare: true

    requires = []

    compiled = compiled.replace /require\((['"])(.+?)\1\)/gm, (match, quote, filePath)->
      if filePath[0] is '.'
        if filePath.split('/').includes 'server'
          throw new Error "'server' in require path: '#{filePath}' in file #{pathToFile}"

        fullPath = path.join currentPath, filePath

        if not fs.existsSync(fullPath + '.coffee')
          filePath += '/index'
          fullPath += '/index'
      else
        fullPath = path.join engineDir, filePath

        if not fs.existsSync(fullPath + '.coffee') and not fs.existsSync(fullPath + '/index.coffee')
          fullPath = path.join rootDir, '../node_modules/' + filePath

        if not fs.existsSync(fullPath + '.coffee')
          filePath += '/index'
          fullPath += '/index'

      relativePath = path.relative rootDir, fullPath
      if not (file = files.get relativePath)?
        file = loadFile relativePath
      requires.push file
      return "require(#{file.index})"

    if (file = files.get pathToFile)?
      index = file.index
      file.requires = requires
    else
      index = files.size
      file = {index, requires, path: pathToFile}
      files.set pathToFile, file

    if guiRegexp.test compiled
      throw new Error "#{pathToFile}.coffee includes gui override: #{compiled.match guiRegexp}"

    file.compiled = "module = _modules_['#{index}'] = {exports: {}}; (function(require, module, exports) {\n\n" + compiled +
      "\n}).call(module.exports, _require_, module, module.exports);"

    return file

  devReloadSource = fileReader.read path.join __dirname, './devReload'
  devReloadSocketPath = if entry? then entry.name else 'game'
  devReloadSource = devReloadSource.replace '#path', devReloadSocketPath
  addSource 'devReload', '/', devReloadSource

  source = fileReader.read path.join __dirname, '../../gui/index'
  guiFile = addSource 'gui', engineDir + '/gui/', source

  preludeGui = "
gui = _require_(#{guiFile.index}); ({#{guiNames.join(',')}} = gui);"

  files.set 'guiGlobal', {compiled: preludeGui}

  needBuild = true
  built = ''

  entryName = undefined
  entryFile = undefined

  if entry?
    entryName = entry.name
    entryFile = loadFile entry.path

  _traverse = (file, callback)->
    for req in file.requires
      _traverse req, callback

    callback file

  files: files

  setEntry: (name, path, source)->
    entryName = name
    entryFile = addSource name, path, source
    needBuild = true

  build: ->
    if not needBuild
      return built
    else
      concat = new Concat true, entryName + '.js', '\n'

      concat.add 'prelude.js', files.get('prelude').compiled
      concat.add 'devReload.js', files.get('devReload').compiled

      inserted = new Set

      _traverse guiFile, (file)->
        return if inserted.has file.path
        concat.add file.path + '.js', file.compiled
        inserted.add file.path

      concat.add 'guiGlobal.js', files.get('guiGlobal').compiled

      _traverse entryFile, (file)->
        return if inserted.has file.path
        concat.add file.path + '.js', file.compiled
        inserted.add file.path

      built = '(function() {' + concat.content.toString() + '}).call(this);'

      base64 = Buffer.from(concat.sourceMap).toString('base64')

      built +=
        '\n//# sourceMappingURL=data:application/json;charset=utf-8;base64,' +
        base64

      needBuild = false

      return built

  reLoad: (pathToFile)->
    if files.has pathToFile
      loadFile pathToFile
      needBuild = true
      return true
    else
      return false

  clients: []

module.exports = Development
