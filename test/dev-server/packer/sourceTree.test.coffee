describe 'SourceTree', ->
  Compiler = require '../../../dev-server/packer/compiler'
  SourceTree = require '../../../dev-server/packer/sourceTree'

  createSourceTree = (loadFile = (-> {source: '', add: ''}))->
    SourceTree '/www/engine', '/www/game', Compiler(), loadFile, []

  it 'should add to tree required local file', ->
    sourceTree = createSourceTree()

    sourceTree.addSource 'a', "require './b'"

    expect(sourceTree.files).to.have.all.keys 'a', 'b'

  it 'should not add file repeatedly', ->
    sourceTree = createSourceTree()

    sourceTree.addSource 'a', "require './b'\nrequire './b'"

    expect(Array.from sourceTree.files.keys()).to.eql ['b', 'a']

  it "should raise error if find 'server' word in path", ->
    sourceTree = createSourceTree()

    fn = ->
      sourceTree.addSource 'a', "require './a/b/c/server/b'"

    expect(fn).to.throw "'server' in require path:"

  it 'should take engineDir if require from engine', ->
    sourceTree = createSourceTree()

    sourceTree.addSource 'a', "require 'b'"

    expect(sourceTree.files).to.have.all.keys 'a', '../engine/b'

  it 'should read files recursive', ->
    loadFile = (p)->
      source = if p is '/www/game/b' then "require './c'" else ''
      {source, add: ''}
    sourceTree = createSourceTree loadFile

    sourceTree.addSource 'a', "require './b'"

    expect(sourceTree.files).to.have.all.keys 'a', 'b', 'c'

  it 'should fill requires in file', ->
    sourceTree = createSourceTree()

    file = sourceTree.addSource 'a', "require './b'\nrequire './c'"

    expect(file.requires).to.deep.equal [
      sourceTree.files.get('b'), sourceTree.files.get('c')
    ]

  it 'should raise error if includes gui override', ->
    sourceTree = createSourceTree()

    fn = ->
      sourceTree.addSource 'a', 'div = 123'

    expect(fn).to.throw 'includes gui override'

  it 'should not change index for repeatedly added source', ->
    sourceTree = createSourceTree()
    {index} = sourceTree.addSource 'a', "require './b'"

    sourceTree.addSource 'a', "require './c'"

    expect(sourceTree.files.get('a').index).to.equal index
