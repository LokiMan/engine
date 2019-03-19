describe 'Compiler', ->
  Compiler = require '../../../dev-server/packer/compiler'
  ParseError = require '../../../dev-server/packer/parseError'

  it 'should catch error on parse coffee error', ->
    compiler = Compiler()

    fn = -> compiler.compile 'var a'
    expect(fn).to.throw ParseError