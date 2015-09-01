
Route = require('../..//lib/local_modules/react-router/route.coffee')
expect = require('expect.js')
# sinon = require('sinon')

describe 'react-router-wrapper/route.coffee', ->
  context 'Router.normalizePath(path)', ->
    it 'should return a blank string if a blank string is passed', ->
      expect(Route.normalizePath('')).to.equal('')

    it 'should return the passed string if a string with a prefixed "/" is passed', ->
      expect(Route.normalizePath('/foo')).to.equal('/foo')

    it 'should prepend a "/" when a string without a prefixed "/" is passed', ->
      expect(Route.normalizePath('foo')).to.equal('/foo')

  context 'constructor(path, callback)', ->
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

      context 'correctly', ->
        it 'should not throw when a string is passed', ->
          expect(-> new Route(null, '/')).to.not.throwException()

        it 'should normalize a @path to be prefixed with a "/" when it is not empty', ->
          route = new Route(null, 'foo')
          expect(route.path).to.equal('/foo')

        it 'should not prefix an empty @path string', ->
          route = new Route(null, '')
          expect(route.path).to.equal('')

        it 'should correctly set @path from the parent', ->
          parent = new Route(null, 'foo')
          child = new Route(parent, 'bar')
          expect(child.path).to.equal('/foo/bar')

        it 'should correctly set @path from the parent', ->
          parent = new Route(null, 'foo')
          child = new Route(parent, 'bar')
          expect(child.path).to.equal('/foo/bar')

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
      route = null

      beforeEach ->
        route = new Route()

      it 'should accept another route', ->
        childRoute = new Route(null, '/test')
        expect(-> route._add(childRoute)).to.not.throwException()

      it 'should add the route to .children', ->
        route._add new Route(null, '/test')
        expect(route.children.length).to.equal(1)

      it 'should return false when routes that have already been added are added a second time', ->
        childRoute = new Route(route, 'foo')
        expect(route._add(childRoute)).to.equal(false)

      it 'should ignore any routes that have already been added', ->
        childRoute = new Route(route, 'foo')
        route._add(childRoute)
        expect(route.children.length).to.equal(1)

      it 'should ignore any routes that already exist', ->
        new Route(route, 'test')
        route._add new Route(null, 'test')
        expect(route.children.length).to.equal(1)

      it 'should return false on any paths that already exist', ->
        new Route('test', route)
        expect(route._add new Route(null, 'test')).to.equal(false)

  context 'hasMatchingRoute(matchRoute)', ->
    route = null

    beforeEach ->
      route = new Route()

    it 'should throw when matchRoute is not a Route', ->
      expect(-> route.hasMatchingRoute('foo')).to.throwException()

    it 'should return false when there are no child routes', ->
      fooRoute = new Route('foo')
      expect(route.hasMatchingRoute(fooRoute)).to.equal(false)

    it 'should return false when there are child routes but none matching', ->
      new Route(route, 'bar')
      new Route(route, 'baz')
      otherPath = new Route(null, 'foobar')
      expect(route.hasMatchingRoute(otherPath)).to.equal(false)

    it 'should return true when there are child routes with one matching', ->
      new Route(route, 'bar')
      bazRoute = new Route(route, 'baz')
      expect(route.hasMatchingRoute(bazRoute)).to.equal(true)

  context 'hasMatchingPath(path)', ->
    route = null

    beforeEach ->
      route = new Route()

    it 'should return false when there are no child routes', ->
      expect(route.hasMatchingPath('foo')).to.equal(false)

    it 'should return false when there are child routes but none matching', ->
      new Route(route, 'bar')
      new Route(route, 'baz')
      expect(route.hasMatchingPath('foobar')).to.equal(false)

    it 'should return true when there are child routes with one matching', ->
      new Route(route, 'bar')
      new Route(route, 'baz')
      expect(route.hasMatchingPath('baz')).to.equal(true)


