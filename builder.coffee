path = require 'path'
fs = require 'fs'
crypto = require 'crypto'

Production = require './dev-server/packer/production'

loadGame = require './game/server/loadGame'

gameDir = process.cwd()

packageJson = require path.join gameDir, './package.json'

gameFile = process.env['npm_package_main'] ? 'game'

srcDir = path.join gameDir, './src/'

{gameComponents, scenes} = loadGame dir: srcDir, file: gameFile

gameComponentsRequires = []
for name, component of gameComponents
  reqPath = "./src/#{name}/client/#{name}"
  if fs.existsSync path.join gameDir, "#{reqPath}.coffee"
    gameComponentsRequires.push "  #{name}: require '#{reqPath}'"

scenesComponents = {}
scenesComponentsRequires = []
for id, scene of scenes
  for name, value of scene
    if not scenesComponents[name]?
      reqPath = "./src/#{name}/client/#{name}"
      if fs.existsSync path.join gameDir, "#{reqPath}.coffee"
        scenesComponentsRequires.push "  #{name}: require '#{reqPath}'"
      scenesComponents[name] = true

source = """
Game = require 'game/client/index'

Game {
#{scenesComponentsRequires.join '\n'}
}, {
#{gameComponentsRequires.join '\n'}
}
  """

hashJson = {}

build = (name, entry)->
  code = Production __dirname, gameDir, entry
  hash = crypto.createHash('md5').update(code).digest('hex')[...10]
  output = path.join gameDir, "res/js/#{name}-#{hash}.js"
  fs.writeFileSync output, code

  hashJson[name] = hash

  console.info "Saved to #{output}"

build 'game', {source: source, path: './'}

if packageJson.build?
  for name, entryPath of packageJson.build
    build name, {path: 'src/' + entryPath}

fs.writeFileSync path.join(gameDir, 'res/js/hash.json'),
  JSON.stringify(hashJson), {encoding: 'utf8'}
