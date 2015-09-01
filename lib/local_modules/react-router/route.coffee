
normalizeUrl = require('normalizeurl')

module.exports = class Route
  @normalizePath: (path) ->
    return path if path == ''
    path = "/#{path}" if (path.length > 0) && path[0] != '/'
    normalizeUrl(path)

  @generateRenderMethodName: (path) ->
    pathSegments = path.split('/').map (segment) ->
      segment[0].toUpperCase() + segment.slice(1)

    'render' + pathSegments.join('')

  constructor: (@parent = null, relativePath = '/', @onPathHitCallback = null) ->
    typeOfPath = typeof(relativePath)
    if ['number', 'object', 'function'].indexOf(typeOfPath) >= 0
      throw new Error(
        "Route.new: expected relativePath to be a string, got a #{typeOfPath}: #{relativePath}."
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


