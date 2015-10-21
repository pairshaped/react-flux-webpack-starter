
Route = require('../../../lib/local_modules/react-router/route.coffee')
expect = require('expect.js')

describe 'react-router-wrapper/route.coffee', ->

  context 'constructor(parent, relativePath, onPathHitCallback)', ->
    context 'when creating a route with all default parameters', ->
      route = null

      beforeEach ->
        route = new Route()

      it 'should not throw', ->
        constructorFn = -> new Route()
        expect(constructorFn).to.not.throwException()

      it 'should set .path to "/"', ->
        expect(route.path).to.equal("/")

      it 'should set .children to an array', ->
        expect(route.children).to.be.a(Array)

      it 'should set .children to an empty array', ->
        expect(route.children.length).to.equal(0)

    context 'when setting path (the second Route constructor parameter)', ->
      context 'incorrectly', ->
        [0, new Array(), new Object(), (->)].forEach (value) ->
          it 'should throw when a number is passed', ->
            expect(-> new Route(null, value)).to.throwException()

        it 'should throw if the path has any "/"s', ->
          expect(-> new Route(null, 'foo/bar')).to.throwException()

      context 'correctly', ->
        it 'should not throw when a string is passed', ->
          expect(-> new Route(null, 'foobar')).to.not.throwException()

        it 'should normalize a @path to be prefixed with a "/" when it is not empty', ->
          route = new Route(null, 'foo')
          expect(route.path).to.equal('/foo')

        it 'should correctly set @path from the parent', ->
          parent = new Route(null, 'foo')
          child = new Route(parent, 'bar')
          expect(child.path).to.equal('/foo/bar')

        it 'should correctly set @path from the parent', ->
          parent = new Route(null, 'foo')
          child = new Route(parent, 'bar')
          expect(child.path).to.equal('/foo/bar')

    context 'when setting onPathHitCallback', ->
      it 'should set @onPathHitCallback', ->
        route = new Route null, 'foo', -> console.log('Route foo HIT!')
        expect(route.onPathHitCallback).to.be.ok()

