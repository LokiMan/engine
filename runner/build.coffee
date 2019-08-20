path = require 'path'
fs = require 'fs'
crypto = require 'crypto'

Production = require '../dev-server/packer/production'
loadGame = require '../game/server/loadGame'

Build = ->
  gameDir = process.cwd()
  srcDir = path.join gameDir, './src/'
  engineDir = path.join __dirname, '../'

  gameFile = if fs.existsSync("#{srcDir}game.coffee") then 'game' else 'main'

  config = {}

  {requiresSource} = loadGame {srcDir, gameFile, fs, env: 'production', config}

  hashJson = {}

  build = (name, entry)->
    code = Production engineDir, srcDir, entry
    hash = crypto.createHash('md5').update(code).digest('hex')[...10]
    output = path.join gameDir, "res/js/#{name}-#{hash}.js"
    fs.writeFileSync output, code

    hashJson[name] = hash

    console.info "Saved to #{output}"

  build 'game', {source: requiresSource, path: './'}

  if config.build?
    for name, entryPath of config.build
      build name, {path: entryPath}

  fs.writeFileSync path.join(gameDir, 'res/js/hash.json'),
    JSON.stringify(hashJson), {encoding: 'utf8'}

module.exports = Build
