smoothVerticalScrolling = ({style}, value)->
  if value is true
    style['overflowY'] = 'auto'
    style['WebkitOverflowScrolling'] = 'touch'

module.exports = smoothVerticalScrolling
