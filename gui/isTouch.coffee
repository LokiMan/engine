module.exports = (w, d)->
  ('ontouchstart' of w) ||
    (('DocumentTouch' of w) && d instanceof w['DocumentTouch'])
