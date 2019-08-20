{join, relative} = require 'path'
Concat = require 'concat-with-sourcemaps'

SourceTree = require './sourceTree'

Development = (engineDir, srcDir, entry)->
  {sourceTree, guiNames} = SourceTree.create engineDir, srcDir, DEVELOPMENT: on
  {files} = sourceTree

  prelude = '
    var _modules_ = {};
    var _require_ = function(index){return _modules_[index].exports;};
    var gui;'

  files.set 'prelude', {compiled: prelude}

  devReloadSocketPath = if entry? then entry.name else 'game'
  devReload = sourceTree.addFile relative srcDir, join(__dirname, './devReload')
  devReload.compiled = devReload.compiled.replace '#path', devReloadSocketPath

  guiFile = sourceTree.addFile relative srcDir, (join engineDir, 'gui/index')

  preludeGui = "
    gui = _require_(#{guiFile.index}); var {#{guiNames.join(',')}} = gui;"

  files.set 'guiGlobal', {compiled: preludeGui}

  needBuild = true
  built = ''

  entryName = undefined
  entryFile = undefined

  if entry?
    entryName = entry.name
    entryFile = sourceTree.addFile entry.path

  inserted = new Set

  files: files

  setEntry: (name, path, source)->
    entryName = name
    entryFile = sourceTree.addSource name, source, path
    needBuild = true

  build: ->
    if not needBuild
      return built
    else
      concat = new Concat true, entryName + '.js', '\n'

      concat.add 'prelude.js', files.get('prelude').compiled
      concat.add devReload.path + '.js', devReload.compiled

      inserted.clear()

      _process = (file)->
        for req in file.requires
          _process req

        if not inserted.has file.path
          concat.add file.path + '.js', file.compiled
          inserted.add file.path

      _process guiFile
      concat.add 'guiGlobal.js', files.get('guiGlobal').compiled
      _process entryFile

      built = """
        (function() {"use strict"; #{concat.content.toString()}}).call(this);
      """

      base64 = Buffer.from(concat.sourceMap).toString('base64')

      built +=
        '\n//# sourceMappingURL=data:application/json;charset=utf-8;base64,' +
        base64

      needBuild = false

      return built

  reLoad: (pathToFile)->
    if files.has pathToFile
      sourceTree.reAddFile pathToFile
      needBuild = true
      return true
    else
      return false

  clients: []

  getDevReloadJS: ->
    prelude + '\n' + devReload.compiled

module.exports = Development
