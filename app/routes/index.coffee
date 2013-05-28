Product         = require '../models/product'
User            = require '../models/user'
Store           = require '../models/store'
_               = require 'underscore'
everyauth       = require 'everyauth'
AccessDenied    = require '../errors/accessDenied'

exports.changePasswordShow = (req, res) ->
  return res.redirect 'login' unless req.loggedIn
  res.render 'changePassword'

exports.changePassword = (req, res) ->
  return res.redirect 'login' unless req.loggedIn
  user = req.user
  email = user.email.toLowerCase()
  user.verifyPassword req.body.password, (err, succeeded) ->
    dealWith err
    if succeeded
      user.setPassword req.body.newPassword
      user.save (error, user) ->
        dealWith err
        res.redirect 'account/passwordChanged'
    else
      res.render 'changePassword', errors: [ 'Senha inválida.' ]

exports.passwordChanged = (req, res) ->
  return res.redirect 'login' unless req.loggedIn
  res.render 'passwordChanged'

exports.admin = (req, res) ->
  unless req.loggedIn
    return res.redirect 'login'
  unless req.user.isSeller
    return res.redirect 'notseller'
  req.user.populate 'stores', (err, user) ->
    res.render 'admin', stores: user.stores

exports.notSeller = (req, res) -> res.render 'notseller'

exports.adminStore = (req, res) ->
  unless req.loggedIn and req.user?.isSeller
    throw new AccessDenied()
  store = req.user.createStore()
  body = req.body
  store.name = body.name
  store.phoneNumber = body.phoneNumber
  store.city = body.city
  store.state = body.state
  store.otherUrl = body.otherUrl
  store.banner = body.banner
  store.flyer = body.flyer
  store.save (err) ->
    return res.json 400, err if err?
    req.user.save (err) ->
      if err?
        store.remove()
        return res.json 400
      res.json 201, store

exports.index = (req, res) ->
  Product.find (err, products) ->
    dealWith err
    viewModelProducts = _.map products, (p) -> p.toSimpleProduct()
    Store.findForHome (err, stores) ->
      dealWith err
      res.render "index", products: viewModelProducts, stores: stores

exports.store = (req, res) ->
  Store.findWithProductsBySlug req.params.storeSlug, (err, store, products) ->
    dealWith err
    return res.renderWithCode 404, 'store', store: null, products: [] if store is null
    viewModelProducts = _.map products, (p) -> p.toSimpleProduct()
    res.render "store", store: store, products: viewModelProducts, (err, html) ->
      #console.log html
      res.send html

exports.storeProducts = (req, res) ->
  Product.findByStoreSlug req.params.storeSlug, (err, products) ->
    dealWith err
    viewModelProducts = _.map products, (p) -> p.toSimpleProduct()
    res.json viewModelProducts

exports.adminProductUpdate = (req, res) ->
  unless req.loggedIn and req.user?.isSeller
    throw new AccessDenied()
  Product.findById req.params.productId, (err, product) ->
    dealWith err
    Store.findBySlug product.storeSlug, (err, store) ->
      dealWith err
      throw new AccessDenied() unless req.user.hasStore store
      product.updateFromSimpleProduct req.body
      product.save (err) ->
        res.send 204

exports.adminProductDelete = (req, res) ->
  unless req.loggedIn and req.user?.isSeller
    throw new AccessDenied()
  Product.findById req.params.productId, (err, product) ->
    dealWith err
    Store.findBySlug product.storeSlug, (err, store) ->
      dealWith err
      throw new AccessDenied() unless req.user.hasStore store
      product.remove (err) ->
        res.send 204

exports.adminProductCreate = (req, res) ->
  unless req.loggedIn and req.user?.isSeller
    throw new AccessDenied()
  Store.findBySlug req.params.storeSlug, (err, store) ->
    dealWith err
    throw new AccessDenied() unless req.user.hasStore store
    product = new Product()
    product.updateFromSimpleProduct req.body
    product.storeName = store.name
    product.storeSlug = store.slug
    product.save (err) ->
      res.send 201, product.toSimpleProduct()

exports.storeProduct = (req, res) ->
  Product.findById req.params.productId, (err, product) ->
    dealWith err
    if product?
      res.json product.toSimpleProduct()
    else
      res.send 404

exports.product = (req, res) ->
  Product.findByStoreSlugAndSlug req.params.storeSlug, req.params.productSlug, (err, product) ->
    dealWith err
    return res.send 404 if product is null
    res.json product.toSimpleProduct()

exports.storesSearch = (req, res) ->
  Store.searchByName req.params.searchTerm, (err, stores) ->
    dealWith err
    res.json stores

exports.productsSearch = (req, res) ->
  Product.searchByName req.params.searchTerm, (err, products) ->
    dealWith err
    viewModelProducts = _.map products, (p) -> p.toSimpleProduct()
    res.json viewModelProducts
