Dispatcher = require('../dispatcher.coffee')
BaseStore = require('./base_store')

class DemoStore extends BaseStore
  constructor: ->
    super()

    Dispatcher.register(@handleDemoAction)

  handleDemoAction: (payload) ->
    return unless payload.actionType == 'demo-action'

module.exports = new DemoStore()

