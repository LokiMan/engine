Generate = ->
  name = process.argv[2]

  typeArg = process.argv[3] ? '-all'

  type = typeArg[1..]

  if type not in ['client', 'server', 'both', 'all']
    console.log "ERROR: unknown type: #{typeArg}"
    process.exit 1

  fs = require 'fs'

  srcPart = if fs.existsSync './src' then 'src/' else ''
  dirPath = "./#{srcPart}#{name}"
  fs.mkdirSync dirPath

  file = (dir)->
    path = "#{dirPath}/#{dir}"
    fs.mkdirSync path

    componentName = name[0].toUpperCase() + name[1..]
    fs.writeFileSync "#{path}/#{name}.coffee", """
  #{componentName} = ()->

  module.exports = #{componentName}

  """

  client = ->
    file 'client'

  server = ->
    file 'server'

  generators = {
    client
    server
    both: ->
      client()
      server()

    all: ->
      @both()
      fs.mkdirSync "#{dirPath}/lib"
  }

  generators[type]()

module.exports = Generate
