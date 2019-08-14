describe 'Compiler', ->
  Compiler = require '../../../dev-server/packer/compiler'
  ParseError = require '../../../dev-server/packer/parseError'

  it 'should catch error on parse coffee error', ->
    compiler = Compiler()

    fn = -> compiler.compile 'var a', '', 'coffee'
    expect(fn).to.throw ParseError

  it "should not coffee compile if ext is 'js'", ->
    compiler = Compiler()

    result = compiler.compile 'var a', 'name', 'js'

    expect(result).to.equal 'var a'
