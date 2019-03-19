spy = (fnc)->
  calls = []
  replacement = (args...)->
    simpleArgs = []
    for arg in args
      simpleArgs.push if Array.isArray(arg) then arg.slice(0) else arg
    calls.push simpleArgs

    fnc? args...

  replacement.calls = calls

  return replacement

module.exports = spy