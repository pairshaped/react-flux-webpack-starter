
normalizeUrl = require('normalizeurl')

module.exports = class Route
  @normalizePath: (path) ->
    newPath = normalizeUrl("/#{path}")
    if newPath.slice(0, 2) == "//"
      newPath = newPath.slice(1)
    newPath

  @nestedRoute: (path) ->
    segments = path.split('/')
    segments = [path] unless segments.length > 0
    lastRoute = null
    for segment in segments
      lastRoute = new Route(lastRoute, segment)

    lastRoute

  constructor: (@parent = null, relativePath = '', @onPathHitCallback = null) ->
    typeOfPath = typeof(relativePath)
    if ['number', 'object', 'function'].indexOf(typeOfPath) >= 0
      throw new Error(
        "Route.new: expected relativePath to be a string, got a #{typeOfPath}: #{relativePath}."
      )

    if relativePath.indexOf("/") >= 0
      throw new Error(
        "Route.new: expected relativePath not contain any slashes ("/"), got a \"#{relativePath}\"."
      )

    @relativePath = Route.normalizePath(relativePath)

    @children = []

    if @parent?
      newPath = @parent._add(@)
      if newPath
        @path = newPath
      else
        @parent = null
    else
      @path = @relativePath

  hasMatchingRoute: (matchRoute) ->
    unless matchRoute instanceof Route
      throw new Error(
        "Route.hasMatchingRoute: expected matchRoute to be a Route, got a #{typeof(matchRoute)}."
      )

    for route in @children
      isRoute = matchRoute == route
      isRoutePathUsed = matchRoute.relativePath == route.relativePath
      return true if isRoute || isRoutePathUsed

    false

  hasMatchingPath: (path) ->
    return false unless path
    normalized = Route.normalizePath(path)
    for route in @children
      isPathSame = normalized == route.path
      isRelativePathSame = normalized == route.relativePath
      return true if isPathSame || isRelativePathSame

    false

  toRenderMethodName: ->
    pathSegments = @path.split('/').map (segment) ->
      return segment if segment.length == 0
      segment[0].toUpperCase() + segment.slice(1)

    'render' + pathSegments.join('')

  toRoutesLookup: (routes = {}) ->
    @_routesIsAnObject(routes)
    routes[@path] = @toRenderMethodName()
    for route in @children
      routes = route.toRoutesLookup(routes)
    routes

  _routesIsAnObject: (routes) ->
    isntAnObject = typeof(routes) != 'object'
    isAnArray = routes instanceof Array
    if isntAnObject || isAnArray
      throw new Error("Route.toRoutesLookup: expected routes to be an object, was a #{typeof(routes)}.")

  # private ---

  _add: (childRoute) ->
    unless childRoute instanceof Route
      throw new Error("Route.add: expected childRoute be a class Route, was a #{typeof(childRoute)}.")

    childRoute.path = @path + childRoute.relativePath

    if childRoute.path == '//'
      throw new Error("Route.add: expected childRoute to have a path, cannot nest a \"/\" into a \"/\" Route.")

    return false if @hasMatchingPath(childRoute.path)
    return false if @hasMatchingRoute(childRoute)

    @children.push childRoute

    childRoute.path


