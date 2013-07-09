define [
  'backbone'
  'areas/admin/routes'
],
(Backbone, routes) ->
  class Router extends Backbone.Router
    routes:
      '': routes.admin
      'createStore': routes.createStore
      'manageStore/:storeId': routes.manageStore
      'store/:storeSlug': routes.store
      'manageProduct/:storeSlug/:productId': routes.manageProduct
      'createProduct/:storeSlug': routes.createProduct
      'orders': routes.orders
      'orders/:orderId': routes.order
    initialize: ->
      Backbone.history.start()
