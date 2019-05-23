smoothVerticalScrolling = (element, value)->
  if value is true
    {style} = element

    style['overflowY'] = 'auto'
    style['WebkitOverflowScrolling'] = 'touch'

    element.addEventListener 'touchmove', (e)->
      if element.offsetHeight < element.scrollHeight
        e._isScroller = true # it's for prevent preventing :) document scroll

module.exports = smoothVerticalScrolling
