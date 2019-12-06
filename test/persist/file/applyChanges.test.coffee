describe 'ApplyChanges', ->
  applyChanges = require '../../../persist/file/applyChanges'

  it 'should apply simple changes', ->
    gameData = {}

    applyChanges gameData, '
[0,["set",["a"],{}]]\n
[1,["set",["b"],[1, 2]]]\n
'

    expect(gameData).to.eql {a: {}, b: [1, 2]}

  it 'should apply array of commands', ->
    gameData = {players: plID: {}}

    applyChanges gameData, '
[0,["set",["players","plID","location"],{"path":"center"}]]\n
[1,["set",["players","plID","location"],{"path":"center2"}], ["set",["players","plID","location"],{"path":"center3"}]]\n
'

    expect(gameData).to.eql players: plID: location: path: 'center3'

  it 'should thrown error on broken transaction', ->
    gameData = players: plID: {}

    fn = ->
      applyChanges gameData, '
[0,["set",["players","plID","location"],{"path":"center"}]]\n
[1,["set",["players","plID","location"],{"path":"center2"}], ["set",["players","plID","location"],{"path":"center3"}]]\n
[2,["set",["players","plID","location"],{"path":"center4"}], ["set",["play
'

    expect(fn).to.throw 'Unexpected end of JSON input'

  it 'should thrown on wrong numbering', ->
    gameData = {}

    fn = ->
      applyChanges gameData, '
[0,["set",["a"],{}]]\n
[1,["set",["b"],[1, 2]]]\n
[3,["set",["b"],[1, 2]]]\n
'

    expect(fn).to.throw 'wrong numbering'
