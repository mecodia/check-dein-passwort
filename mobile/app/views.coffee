cdplib = require('cdplib')

class PasswordInputView extends Backbone.View

  el: "#password"

  events:
    "input": "changed"
    "focus": "focus"
    "blur": "blur"

  changed: ->
    @model.set "password", @$el.val()

  focus: ->
    if not @$el.is(':focus')
      $("#title").hide()
      @$el.css("padding-left", 60)
      window.scrollTo(0, 0)


  blur: ->
    if !@$el.val()
      $("#title").show()
      @$el.css("padding-left", 12)

class ShareView extends Backbone.View

  el: "#share"
  
  events:
    "click": "onClick"

  initialize: ->
    @readableGenerator = new cdplib.ReadableStrengthGenerator

  onClick: (e) ->
    e.stopImmediatePropagation()
    if @model.get 'instantly'
      status = """Ein herkömmlicher PC kann mein Passwort sofort knacken!\n\nhttp://checkdeinpasswort.de"""
    else
      status = """Ein herkömmlicher PC kann mein Passwort innerhalb von #{@readableGenerator.get @model.get 'timeSeconds'} knacken!\n\nhttp://checkdeinpasswort.de"""

    if window.plugins
      window.plugins.socialsharing.share(status)
    else
      alert(status)


module.exports =
  ShareView: ShareView
  PasswordInputView: PasswordInputView
