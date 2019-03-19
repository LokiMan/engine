transform = (style, value)->
  style['webkitTransform'] = value
  style['msTransform'] = value
  style['transform'] = value

module.exports = transform