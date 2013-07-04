define [
  'jquery'
  'underscore'
  'backbone'
  'handlebars'
  '../models/products'
  '../models/cart'
  '../models/orders'
  'text!./templates/finishOrderPayment.html'
  './cartItem'
  '../../../converters'
], ($, _, Backbone, Handlebars, Products, Cart, Orders, finishOrderPaymentTemplate, CartItemView, converters) ->
  class FinishOrderPayment extends Backbone.View
    events:
      'click #selectPaymentType':'_selectPaymentType'
    template: finishOrderPaymentTemplate
    initialize: (opt) =>
      @store = opt.store
      @cart = opt.cart
      @user = opt.user
    render: =>
      context = Handlebars.compile @template
      @$el.html context pagseguro:@store.pagseguro
    _selectPaymentType: ->
      selected = $('#paymentTypesHolder input[type=radio][checked]', @$el)
      paymentType = switch selected.val()
        when "pagseguro" then type:'pagseguro', name:'PagSeguro'
        when "directSell" then type:'directSell', name:'Pagamento direto ao fornecedor'
      @cart.choosePaymentType paymentType
      Backbone.history.navigate 'finishOrder/summary', trigger: true
