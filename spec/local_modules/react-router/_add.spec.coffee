
Route = require('../../../lib/local_modules/react-router/route.coffee')
expect = require('expect.js')

describe 'react-router-wrapper/route.coffee', ->
  context '_add(route)', ->
    context 'incorrectly', ->
      ['foo', 0, new Array(), new Object()].forEach (value) ->
        it "should throw when a #{typeof(value)} is passed", ->
          route = new Route()
          expect(-> route._add(value)).to.throwException()

      it 'should not allow a default "/" to be nested inside a "/"', ->
        route = new Route()
        childRoute = new Route()
        expect(-> route._add(childRoute)).to.throwException()

    context 'correctly', ->
      it 'should accept another route', ->
        route = new Route()
        childRoute = new Route(null, 'test')
        expect(-> route._add(childRoute)).to.not.throwException()

      it 'should add the route to .children', ->
        route = new Route()
        route._add new Route(null, 'foo')
        expect(route.children.length).to.equal(1)

      it 'should throw when routes that have already been added are added a second time', ->
        route = new Route()
        childRoute = new Route(route, 'bar')
        expect(-> route._add(childRoute)).to.throwException()

      it 'should throw when a route is added with an already used path', ->
        route = new Route()
        new Route(route, 'foobar')
        expect(-> route._add new Route(null, 'foobar')).to.throwException()


