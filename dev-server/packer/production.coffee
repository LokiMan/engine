fs = require 'fs'
pathFS = require 'path'

FileReader = require './fileReader'
Compiler = require './compiler'
UglifyJS = require 'uglify-js'

guiElements = (require '../../gui/elements')()
guiNames = Object.keys guiElements
guiRegexp = ///\b(#{guiNames.join('|')})\s*=///g

fileReader = FileReader fs
compiler = Compiler()

Production = (engineDir, rootDir, entry)->
  files = new Map

  loadSource = (source, pathToFile, currentPath)->
    compiled = compiler.compile source, pathToFile, bare: true

    compiled = compiled.replace /require\((['"])(.+?)\1\)/gm, (match, quote, filePath)->
      if filePath[0] isnt '.'
        fullPath = pathFS.join engineDir, filePath
        if not fs.existsSync(fullPath + '.coffee') and not fs.existsSync(fullPath + '/index.coffee')
          fullPath = pathFS.join rootDir, 'node_modules/' + filePath

        if not fs.existsSync(fullPath + '.coffee')
          filePath += '/index'
          fullPath += '/index'
      else
        if filePath.split('/').includes 'server'
          throw new Error "'server' in require path: '#{filePath}' in file #{pathToFile}"

        fullPath = pathFS.join currentPath, filePath

        if not fs.existsSync(fullPath + '.coffee')
          filePath += '/index'
          fullPath += '/index'

      relativePath = pathFS.relative rootDir, fullPath
      if not (file = files.get relativePath)?
        file = loadFile relativePath
      return "require(#{file.index})"

    file = {source, index: files.size}
    files.set pathToFile, file
    return file

  loadFile = (pathToFile)->
    fullPathToFile = pathFS.join rootDir, pathToFile
    currentPath = pathFS.dirname fullPathToFile
    source = fileReader.read fullPathToFile

    loadSource source, pathToFile, currentPath

  source = fileReader.read pathFS.join __dirname, '../../gui/index'
  guiFile = loadSource source, 'gui', engineDir + '/gui/'

  if entry.source?
    loadSource entry.source, entry.path, rootDir
  else
    loadFile entry.path

  all = ['_modules_ = {}; _require_ = (index)-> _modules_[index].exports']

  files.forEach (file, path)->
    currentPath = pathFS.join rootDir, pathFS.dirname path

    source = file.source.replace /require (['"])(.+?)\1/gm, (match, quote, filePath)->
      if filePath[0] isnt '.'
        fullPath = pathFS.join engineDir, filePath
        if not fs.existsSync(fullPath + '.coffee') and not fs.existsSync(fullPath + '/index.coffee')
          fullPath = pathFS.join rootDir, 'node_modules/' + filePath

        if not fs.existsSync(fullPath + '.coffee')
          fullPath += '/index'
      else
        if filePath.split('/').includes 'server'
          throw new Error "'server' in require path: '#{filePath}' in file #{path}"

        fullPath = pathFS.join currentPath, filePath
        if not fs.existsSync(fullPath + '.coffee')
          fullPath += '/index'

      relativePath = pathFS.relative rootDir, fullPath

      return "require #{files.get(relativePath)?.index}"

    mdl = "module = _modules_[#{file.index}] =
 {exports: {}}; ((require, module, exports)->\n\n"

    for line, i in source.split '\n'
      if guiRegexp.test line
        throw new Error "'#{line}' includes gui override in
 #{path}.coffee:#{i+1}"
      mdl += '  ' + line + '\n'

    mdl += '\n).call(module.exports, _require_, module, module.exports)'

    all.push mdl

    if file is guiFile
      all.push "gui = _require_(#{guiFile.index}); {#{guiNames.join ','}} = gui"

  str = compiler.compile all.join('\n\n'), '', {
    transpile: {
      presets: ['env']
      plugins: ['transform-es2015-destructuring', 'transform-object-rest-spread']
    }
  }
  UglifyJS.minify(str, {compress: drop_console: true}).code

module.exports = Production
