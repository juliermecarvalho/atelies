define [
  'jquery'
  'underscore'
  'backboneConfig'
  'handlebars'
  'showdown'
  'md5'
  '../models/products'
  'text!./templates/product.html'
  '../models/cart'
], ($, _, Backbone, Handlebars, Showdown, md5, Products, productTemplate, Cart) ->
  class ProductView extends Backbone.Open.View
    template: productTemplate
    initialize: (opt) ->
      @markdown = new Showdown.converter()
      @store = opt.store
      @product = opt.product
      @user = opt.user
      if @product?.get('hasInventory')
        @canPurchase = @product?.get('inventory') > 0
      else
        @canPurchase = true
    events:
      "click #product > #purchaseItem": 'purchase'
      "click #createComment": "_createComment"
    purchase: ->
      return unless @canPurchase
      @cart = Cart.get(@store.slug)
      @cart.addItem _id: @product.get('_id'), name: @product.get('name'), picture: @product.get('picture'), url: @product.get('url'), price: @product.get('price'), shippingApplies: @product.get('shippingApplies')
      Backbone.history.navigate '#cart', trigger: true
    render: ->
      @$el.empty()
      context = Handlebars.compile @template
      @delegateEvents()
      attr = _.extend {}, @product.attributes
      attr.tags = attr.tags.split(', ')
      description = @markdown.makeHtml attr.description if attr.description?
      if attr.comments?
        for c in attr.comments
          c.niceDate = @createNiceDate c.date
          c.gravatarUrl = "https://secure.gravatar.com/avatar/#{md5(c.userEmail.toLowerCase())}?d=mm&r=pg&s=50"
          c.body = @markdown.makeHtml c.body
      @$el.html context product: attr, store: @store, canPurchase: @canPurchase, description: description, hasComments: attr.comments?.length > 0, user: @user, encodedUrl: encodeURIComponent attr.url
    createNiceDate: (date) ->
      date = new Date(date) if typeof date is 'string'
      date = date.getTime() unless typeof date is 'number'
      diffInMils = new Date().getTime() - date
      diffInMins = diffInMils / 1000 / 60
      diffInHours = diffInMins / 60
      diffInDays = diffInHours / 24
      switch
        when diffInMins < 0 then 'no futuro'
        when diffInMins < 1 then 'agorinha'
        when diffInMins < 2 then 'a um minuto'
        when diffInMins < 16 then 'a quinze minutos'
        when diffInMins < 45 then 'a meia hora'
        when diffInMins < 75 then 'a uma hora'
        when diffInMins < 140 then 'a duas horas'
        when diffInHours < 24 then "a #{Math.floor diffInHours, 0} horas"
        else "a #{Math.floor diffInDays, 0} dias"
    _createComment: ->
      $("#createComment", @$el).attr 'disabled', 'disabled'
      body = $("#newCommentBody", @$el).val()
      jqxhr = $.post "/products/#{@product.get '_id'}/comments", body:body, =>
        @product.get('comments').push date: new Date(), userEmail: @user.email, userName: @user.name, body: body
        $("#createComment", @$el).removeAttr 'disabled'
        $("#newCommentBody", @$el).val ''
        @render()
        @showDialog "<strong>Obrigado!</strong>
          O seu comentário foi criado com sucesso e já está disponível na página do produto. A loja também foi notificada que você comentou.<br /><br />
          Apreciamos muito o seu feedback. Fique a vontade para fazer comentários em outros produtos. O vendedor poderá lhe responder aqui mesmo na página do
          produto ou diretamente."
          , "Comentário criado"
      jqxhr.error =>
        $("#createComment", @$el).removeAttr 'disabled'
        @logError 'store', 'Error sending comment'
        @showDialogError 'Não foi possível realizar o comentário. Tente novamente mais tarde. Se o problema
          persistir envie um e-mail contato@atelies.com.br.'
