define [
  'jquery'
  'backboneConfig'
  'handlebars'
  '../models/storePagseguro'
  'text!./templates/manageStorePagseguro.html'
  'backboneValidation'
], ($, Backbone, Handlebars, StorePagseguro, manageStorePagseguroTemplate, Validation) ->
  class ManageStorePagseguroView extends Backbone.Open.View
    id: 'manageStorePagseguroView'
    events:
      'click #confirmSetPagseguro':'_confirmSetPagSeguro'
      'click #confirmUnsetPagseguro':'_confirmUnsetPagSeguro'
    template: manageStorePagseguroTemplate
    initialize: (opt) ->
      @model = new StorePagseguro()
      context = Handlebars.compile @template
      @pagseguro = opt.pagseguro
      @storeId = opt.storeId
      @$el.html context pagseguro: @pagseguro, staticPath: @staticPath
      @bindings = @initializeBindings()
      Validation.bind @
      #@model.bind 'validated:invalid', (model, errors) -> console.log errors
    _confirmSetPagSeguro: -> @_setPagseguro on
    _confirmUnsetPagSeguro: -> @_setPagseguro off
    _setPagseguro: (set) ->
      opt =
        url: "/admin/store/#{@storeId}/setPagSeguro"
        type: 'PUT'
        error: (xhr, text, error) =>
          @logXhrError 'admin', xhr
          if xhr.status isnt 409
            return @showDialogError "Não foi possível alterar o PagSeguro. Tente novamente mais tarde."
          $('#modalConfirmPagseguro').one 'hidden.bs.modal', =>
            $('#modalCannotPagseguro', @el).modal 'show'
            $("#confirmSetPagseguro").prop "disabled", off
            $("#confirmUnsetPagseguro").prop "disabled", off
          $('#modalConfirmPagseguro', @el).modal 'hide'
        success: (data, text, xhr) =>
          @model.set 'pagseguro', set
          $('#modalConfirmPagseguro').one 'hidden.bs.modal', => @trigger 'changed', pagseguro:set
          $('#modalConfirmPagseguro', @el).modal 'hide'
      if set
        return unless @model.isValid true
        $("#confirmSetPagseguro").prop "disabled", on
        $("#confirmUnsetPagseguro").prop "disabled", on
        opt.url += "On"
        opt.data =
          email: $("#pagseguroEmail", @el).val()
          token: $("#pagseguroToken", @el).val()
      else
        opt.url += "Off"
      $.ajax opt
