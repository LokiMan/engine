path = require 'path'
fs = require 'fs'
crypto = require 'crypto'

Production = require './dev-server/packer/production'

loadGame = require './game/server/loadGame'

gameDir = process.cwd()

packageJson = require path.join gameDir, './package.json'

gameFile = process.env['npm_package_main'] ? 'game'

srcDir = path.join gameDir, './src/'

{
  componentsConstructors
} = loadGame {
  srcDir, gameFile, components: packageJson.components, fs, env: 'production'
}

componentsRequires = []
for name, component of componentsConstructors when not component.isServerOnly
  relPath = path.relative gameDir, component.pathTo
  reqPath = if relPath[0] is '.' then relPath else "./#{relPath}"
  componentsRequires.push "  #{name}: require '#{reqPath}/client/#{name}'"

source = """
require('game/client/index') {
#{componentsRequires.join '\n'}
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
