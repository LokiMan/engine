Gray = (style, value, element, guiElement)->
  if value
    style['filter'] = "url(\"data:image/svg+xml;utf8,<svg%20xmlns='http://www.w3.org/2000/svg'>
					<filter%20id='grayscale'><feColorMatrix%20type='matrix'%20values='0.3333%200.3333%200.3333%200%200%200.3333%20
					0.3333%200.3333%200%200%200.3333%200.3333%200.3333%200%200%200%200%200%201%200'/></filter></svg>#grayscale\")"
    style['filter'] = 'gray'
    style['-webkit-filter'] = 'grayscale(1)'
  else
    style['filter'] = 'none'
    style['-webkit-filter'] = 'grayscale(0)'

  guiElement.isGray = value

module.exports = Gray
