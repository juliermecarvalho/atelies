define [
  'jquery'
  'backboneConfig'
  'handlebars'
  'text!./templates/userNotVerified.html'
], ($, Backbone, Handlebars, userNotVerifiedTemplate) ->
  class UserNotVerifiedView extends Backbone.Open.View
    template: userNotVerifiedTemplate
    initialize: (opt) ->
      @user = opt.user
    render: ->
      @$el.empty()
      context = Handlebars.compile @template
      @$el.html context user: @user
