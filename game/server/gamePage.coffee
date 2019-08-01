DEFAULT_BODY_STYLE = 'background: #E5E6D8; color: #000;'

GamePageFactory = (
  baseTitle = 'no_title', baseBodyStyle = DEFAULT_BODY_STYLE, baseContainer
  getHash
)->
  hash = getHash()

  pageRefreshes = []

  GamePage = ({
    title = baseTitle, meta = true, metas
    bodyStyle = baseBodyStyle, container = baseContainer
  })->
    beforeTitle = getBeforeTitle()

    afterTitle = getAfterTitle title, metas, meta, container, bodyStyle
    afterTitleAndScriptLine = afterTitle + getScriptLine()

    begin = beforeTitle + afterTitleAndScriptLine
    end = '\n  </body>\n</html>'

    both = begin + end

    pageRefreshes.push ->
      afterTitleAndScriptLine = afterTitle + getScriptLine()
      begin = beforeTitle + afterTitleAndScriptLine
      both = begin + end

    render: (script, subTitle)->
      first = if subTitle?
        beforeTitle + subTitle + ' - ' + afterTitleAndScriptLine
      else
        begin

      if script?
        first + "<script>#{script};</script>" + end
      else if subTitle?
        first + end
      else
        both

  getBeforeTitle = ->
    """
<!DOCTYPE html>
<html style='height: 100%'>
  <head>
    <meta charset='utf-8'>
    <title>
"""

  getAfterTitle = (title, metas, meta, container, bodyStyle)->
    metasLines = ''
    if metas?
      for name, value of metas
        metasLines += "\n    <meta name=\"#{name}\" content=\"#{value}\">"

    containerStyle = if container? then " style=\"#{container}\"" else ''

    """
#{title}</title>#{metasLines}
    <link rel='shortcut icon' href='/res/img/favicon.ico'>
    <link rel="apple-touch-icon" href='/res/img/favicon.ico'>\
#{if meta then createMetaLines(meta) else ''}
    <style type="text/css">
      * {
        -webkit-tap-highlight-color: rgba(0,0,0,0);
      }
      body {
        -webkit-touch-callout: none;
        -webkit-text-size-adjust: none;
      }
    </style>
  </head>
  <body style="margin: 0; padding: 0; height: 100%; \
font: 16px trebuchet ms, Tahoma, Arial, Helvetica, sans-serif; #{bodyStyle}">
    <div id="container_g"#{containerStyle}></div>

"""

  createMetaLines = (meta)->
    viewport = meta.viewport ? 'width=1024, user-scalable=no'

    "
\n    <meta name='apple-mobile-web-app-capable' content='yes'/>
\n    <meta name='apple-mobile-web-app-status-bar-style' content='black' />
\n    <meta name='mobile-web-app-capable' content='yes' />
\n    <meta name='viewport' content='#{viewport}' />
"

  getScriptLine = ->
    entryName = if hash? then "/res/js/game-#{hash['game']}" else '/js/game'
    "<script type='text/javascript' src='#{entryName}.js'></script>"

  refreshGamePagesHash = ->
    hash = getHash()
    fn() for fn in pageRefreshes
    return

  return {GamePage, refreshGamePagesHash}

module.exports = GamePageFactory
