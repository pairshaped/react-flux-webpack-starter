
Route = require('../../../lib/local_modules/react-router/route.coffee')
expect = require('expect.js')

describe 'react-router-wrapper/route.coffee', ->
  context 'Router.normalizePath(path)', ->
    it 'should return a single slash string if a blank string is passed', ->
      expect(Route.normalizePath('')).to.equal('/')

    it 'should return the passed string if a string with a prefixed "/" is passed', ->
      expect(Route.normalizePath('/foo')).to.equal('/foo')

    it 'should prepend a "/" when a string without a prefixed "/" is passed', ->
      expect(Route.normalizePath('foo')).to.equal('/foo')

