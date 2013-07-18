define [
  'backbone'
  'areas/admin/routes'
],
(Backbone, routes) ->
  class Router extends Backbone.Open.Router
    _routes: routes
    routes:
      '': routes.admin
      'createStore': routes.createStore
      'manageStore/:storeId': routes.manageStore
      'store/:storeSlug': routes.store
      'manageProduct/:storeSlug/:productId': routes.manageProduct
      'createProduct/:storeSlug': routes.createProduct
      'orders': routes.orders
      'orders/:orderId': routes.order
