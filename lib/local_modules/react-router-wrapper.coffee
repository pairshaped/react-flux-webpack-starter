
#
# TODO:
#   1. Jest Tests
#   2. Namespaced Routes, ie:
#     /namespace
#       /one
#       /two
#
#     rather than:
#
#     /namespace/one
#     /namespace/two
#

path = require('path')

class Route
  constructor: (router, routePath, callback) ->
    throw new Error('Path is not a valid string') unless _.isString(routePath)
    throw new Error('Callback is not a function') unless _.isFunction(callback)
    @path = @fullPath()
    @identifier = _.camelCase(
      @path.replace(/[-\/:]/g, '_')
    )
    @callback = _.bind(callback, router)

  fullPath: (router, p) ->
    path.join(router.getPath(), p)

  toMappedRoute: ->
    "#{@path}": @identifier


class RouteNotFound extends Route
  constructor: (router, callback) ->
    throw new Error('Callback is not a function') unless _.isFunction(callback)

    @identifier = 'notFound'
    @callback = _.bind(callback, router)


class Routable
  @normalize: (paths) ->
    pathStr = paths
    pathStr = path.join('/') if paths instanceof Array
    path.normalize(pathStr.join('/'))

  constructor: (@basePath, @routerBlock) ->
    @validateBasePath(@basePath)
    @validateRouterBlock(@routerBlock)
    @routes = []

  validateBasePath: (basePath) ->
    unless _.isString(basePath)
      throw new Error('Routable expects basePath to be a string')

  validateRouterBlock: (routerBlock) ->
    unless _.isFunction(routerBlock)
      throw new Error('Routable expects routerBlock to be a function')

  doBlockIfAvailable: ->
    @routerBlock.call(@) if @routerBlock && _.isFunction(@routerBlock)

  rootTo: (callback) ->
    @match '/', callback

  match: (path, callback) ->
    @addRoute new Route(@, Routable.normalize([@basePath, path]), callback)

  notFound: (callback) ->
    @addRoute new RouteNotFound(@, callback)

  addRoute: (route) ->
    unless route instanceof Route
      throw new Error('addRoute expects `route` to be of type Route')
    @routes.push route

  toRoutes: ->
    routes = {}
    _.each @, (route) ->
      mappedRoute = route.toMappedRoute()
      routes = _.extend {}, routes, mappedRoute
    routes


class SubRouter extends Routable
  @extend Route

  constructor: (@parent, path, callback) ->
    super(path.join(@parent.baseUrl, path), callback)
    @routes = new RouteCollection()

    @doBlockIfAvailable()

  toMappedRoute: ->
    routes = {}


class Router extends Routable
  constructor: (basePath, block) ->
    super(basePath, block)
    @mixins = []
    @props = history: true
    @routes = new RouteCollection()

    @doBlockIfAvailable()

  buildRouterComponent: ->
    specs = {
      displayName: 'ApplicationRoot'
      mixins: _.uniq([RouterMini.RouterMixin].concat(@mixins))
      routes: @routes.toRoutes()
      render: -> @renderCurrentRoute()
    }

    @_mapRoutesTo specs, @routes

    specs

  setProp: (field, value) ->
    @props[field] = value

  getProp: (field) ->
    @props[field]

  addMixins: (mixin) ->
    @mixins = @mixins.concat(mixin)

  mount: (domTarget) ->
    specs = @buildRouterComponent()
    console.log 'ReactRouterWrapper.mount', specs
    app = React.createClass specs
    React.render(React.createElement(app, @props), domTarget)


module.exports =
  Router: Router
  SubRouter: SubRouter

