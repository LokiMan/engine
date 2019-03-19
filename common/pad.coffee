pad = (v) ->
  (if v < 10 then "0#{v}" else "#{v}")

module.exports = pad
