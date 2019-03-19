FileReader = (fs)->
  read: (path)->
    fs.readFileSync path + '.coffee', 'utf8'

module.exports = FileReader