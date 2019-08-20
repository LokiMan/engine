{join, relative, dirname} = require 'path'
UglifyJS = require 'uglify-js'

SourceTree = require './sourceTree'

Production = (engineDir, srcDir, entry)->
  {sourceTree, guiNames, compiler} = SourceTree.create engineDir, srcDir
  {files} = sourceTree

  guiFile = sourceTree.addFile relative srcDir, (join engineDir, 'gui/index')

  if entry.source?
    sourceTree.addSource entry.path, entry.source, srcDir
  else
    sourceTree.addFile entry.path

  all = ['_modules_ = {}; _require_ = (index)-> _modules_[index].exports']

  regExp = /require( |\()('|")(.+?)\2/gm

  files.forEach (file, pathToFile)->
    currentPath = join srcDir, dirname pathToFile

    source = file.source.replace regExp, (_, brace, __, path)->
      if path[0] is '.'
        fullPath = join currentPath, path
      else
        fullPath = join engineDir, path

      relativePath = relative srcDir, fullPath
      found = files.get(relativePath) ? files.get(relativePath + '/index')

      return "require#{brace}#{found?.index}"

    mdl = "module = _modules_[#{file.index}] = {exports: {}};
      ((require, module, exports)->\n\n"

    mdl += '  ```\n' if file.ext is 'js'

    for line, i in source.split '\n'
      mdl += '  ' + line + '\n'

    mdl += '  ```\n  return\n' if file.ext is 'js'

    mdl += '\n).call(module.exports, _require_, module, module.exports)'

    all.push mdl

    if file is guiFile
      all.push "gui = _require_(#{guiFile.index}); {#{guiNames.join ','}} = gui"

  str = compiler.compile all.join('\n\n'), '', 'coffee', {
    transpile: {
      presets: ['env']
      plugins: [
        'transform-es2015-destructuring', 'transform-object-rest-spread'
      ]
      compact: true
    }
  }
  UglifyJS.minify(str, {compress: drop_console: true}).code

module.exports = Production
