
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


class RouteNotFound extends Route
  constructor: (router, callback) ->
    throw new Error('Callback is not a function') unless _.isFunction(callback)

    @identifier = 'notFound'
    @callback = _.bind(callback, router)


class Router
  constructor: ->
    @parent = null
    @basePath = null

    @mixins = []
    @props = history: true
    @routes = []

    @processArguments(arguments)


  processArguments: (args) ->
    if args.length == 3 then @processThreeArgs(args)
    else if args.length == 2 then @processTwoArgs(args)
    else if args.length == 1 then @processOneArg(args)
    else throw new Error('Invalid arguments given for class Router')

  processThreeArgs: (args) ->
    @validateAndSetParent(args[0])
    @validateAndSetBasePath(args[1])
    @validateAndCallCallback(args[2])

  processTwoArgs: (args) ->
    @validateAndSetBasePath(args[0])
    @validateAndCallCallback(args[1])

  processOneArg: (args) ->
    @basePath = ''
    @validateAndCallCallback(args[0])


  validateAndSetParent: (parent) ->
    unless parent instanceof Router
      throw new Error('Parent is not class Router')
    @parent = parent

  validateAndSetBasePath: (basePath) ->
    unless basePath instanceof String
      throw new Error('Basepath is not a string')
    @basePath = basePath

  validateAndCallCallback: (callback) ->
    unless callback instanceof Function
      throw new Error('Callback is not a function')
    callback.call(@)


  getPath: ->
    @basePath


  buildRouterComponent: ->
    specs = {
      displayName: 'ApplicationRoot'
      mixins: _.uniq([RouterMini.RouterMixin].concat(@mixins))
      routes: @_routesArray()
      render: -> @renderCurrentRoute()
    }

    @_mapRoutesTo specs, @routes

    specs

  _routesArray: ->
    routesWithAPath = _.select @routes, (route) -> !!route.path

    _.reduce routesWithAPath, ((routes, route) ->
      routes[route.path] = route.identifier
      routes
    ), {}

  _mapRoutesTo: (specs, routes) ->
    _.each routes, (route) =>
      specs = @_mapRouteRenderMethodTo specs, route
    specs

  _mapRouteRenderMethodTo: (specs, route) ->
    specs[route.identifier] = _.bind(route.callback, @)
    specs


  setProp: (field, value) ->
    @props[field] = value

  getProp: (field) ->
    @props[field]


  rootTo: (callback) ->
    @match '/', callback

  match: (path, callback) ->
    @addRoute new Route(@, path, callback)

  notFound: (callback) ->
    @addRoute new RouteNotFound(@, callback)

  namespace: (namespacePath, callback) ->
    new Router(
      @
      path.join(@basePath, namespacePath)
      callback
    )

  addRoute: (route) ->
    unless route instanceof Route
      throw new Error('addRoute expects `route` to be of type Route')
    @routes.push route

  addMixins: (mixin) ->
    @mixins = @mixins.concat(mixin)

  mount: (domTarget) ->
    specs = @buildRouterComponent()
    console.log 'ReactRouterWrapper.mount', specs
    app = React.createClass specs
    React.render(React.createElement(app, @props), domTarget)


module.exports =
  Route: Route
  RouteNotFound: RouteNotFound
  RouteNamespace: RouteNamespace
  Router: Router

