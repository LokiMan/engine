defaultBodyStyle = 'background: #E5E6D8; color: #000;'

metaLines = "
\n    <meta name='apple-mobile-web-app-capable' content='yes'/>
\n    <meta name='apple-mobile-web-app-status-bar-style' content='black' />
\n    <meta name='mobile-web-app-capable' content='yes' />
\n    <meta name='viewport' content='width=1024' />
"

{NODE_ENV} = process.env

if NODE_ENV in ['production', 'test']
  gameDir = process.cwd()
  path = require('path').join(gameDir, 'res/js/hash.json')
  hashJsonText = require('fs').readFileSync path, {encoding: 'utf8'}
  hashJson = JSON.parse hashJsonText

GamePage = ({title, entries, bodyStyle = defaultBodyStyle, container, meta})->
  scriptLine = ''

  scripts = []
  for name in entries
    if NODE_ENV in ['production', 'test']
      entry = "/res/js/#{name}-#{hashJson[name]}"
    else
      entry = "/js/#{name}"

    scripts.push "<script type='text/javascript' src='#{entry}.js'></script>"
  scriptLine = scripts.join '\n    '

  containerStyle = if container? then " style=\"#{container}\"" else ''

  beforeTitle = """
<!DOCTYPE html>
<html style='height: 100%'>
  <head>
    <meta charset='utf-8'>
    <title>
"""

  afterTitle = """
#{title}</title>
    <link rel='shortcut icon' href='/res/img/favicon.ico'>
    <link rel="apple-touch-icon" href='/res/img/favicon.ico'>\
#{if meta then metaLines else ''}
  </head>
  <body style="margin: 0; padding: 0; height: 100%; \
-webkit-tap-highlight-color: rgba(0,0,0,0); \
font: 16px trebuchet ms, Tahoma, Arial, Helvetica, sans-serif; #{bodyStyle}">
    <div id="container_g"#{containerStyle}></div>
    #{scriptLine}
"""

  begin = beforeTitle + afterTitle
  end = '\n  </body>\n</html>'

  both = begin + end

  render: (script, subTitle)->
    first = if subTitle?
      beforeTitle + subTitle + ' - ' + afterTitle
    else
      begin

    if script?
      first + "<script>#{script};</script>" + end
    else
      both

module.exports = GamePage
