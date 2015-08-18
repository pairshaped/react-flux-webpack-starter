
{ Router } = RouterWrapper

router = new Router ->
  @setProp('history', true)

  @rootTo ->
    React.DOM.div {}, 'Parent Route'

  @match 'test/:id', (id) ->
    React.DOM.div {},
      'Test page with id'
      id.toString()

  @notFound (path) ->
    React.DOM.div {},
      '404 File Not Found'
      path

router.mount(document.getElementById('react__entry'))

