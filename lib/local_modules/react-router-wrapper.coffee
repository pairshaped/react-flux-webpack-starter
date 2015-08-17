
class Route
  constructor: (@path, @callback) ->
    @identifier = _.kebabCase(
      path
        .replace(':', '_')
        .replace('/', '_')
        .replace('-', '_')
    ) + "#{Date.now()}"

class RouteNotFound extends Route
  constructor: (callback) ->
    super(null, callback)

    @identifier = 'notFound'

class Router
  constructor: (basePath) ->
    @mixins = []
    @props = {
      history: true
    }
    @routes = []

  buildRouterComponent: ->
    specs = {
      displayName: 'ApplicationRoot'

      mixins: [ReactMiniRouter.RouterMixin].concat(@mixins)

      routes: @_routesArray()

      render: ->
        @renderCurrentRoute()
    }

    @_mapRoutesTo specs, @routes

    specs

  _routesArray: ->
    routesWithAPath = _.select @routes, (route) ->
      !!route.path

    _.reduce routesWithAPath, ((routes, route) ->
      routes[route.path] = route.identifier
      routes
    ), {}

  _mapRoutesTo: (specs, routes) ->
    _.each routes, (route) =>
      specs = @_mapRouteRenderMethodTo specs, route
    specs

  _mapRouteRenderMethodTo: (specs, route) ->
    spec[route.identifier] = _.bind(route.callback, @)
    spec

  setProp: (field, value) ->
    @props[field] = value

  getProp: (field) ->
    @props[field]

  addDefaultRoute: (callback) ->
    @addRoute new Route '', callback

  addRoute: (route) ->
    throw new Error() unless route instanceof Route
    @routes.push route

  addMixins: (mixin) ->
    @mixins = @mixins.concat(mixin)

  mount: (domTarget) ->
    specs = @buildRouterComponent()
    React.render(specs, domTarget)


module.exports =
  Route: Route
  RouteNotFound: RouteNotFound
  Router: Router

