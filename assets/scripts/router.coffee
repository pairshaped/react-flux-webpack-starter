
{ Router, Route, RouteNotFound, RouteNamespace } = RouterWrapper

router = new Router '/', ->
  @setProp('history', true)

  @addDefaultRoute ->
    React.DOM.div {}, 'Parent Route'

  @addRoute new Route 'test/:id', (id) ->
    React.DOM.div {}, "Test page with id #{id}"

  @addRoute new RouteNotFound ->
    React.DOM.div {}, '404 Page Not Found'

  @addRoute new RouteNamespace 'namespace', ->
    @addRoute new Route 'test/:id', (id) ->
      React.DOM.div {}, "Namespaced test papge with id #{id}"

router.mount('#react__entry')
