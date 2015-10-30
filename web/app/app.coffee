cdplib = require('cdplib')

class PasswordInputView extends Backbone.View

  el: "#password"

  events: #
    "keyup": "changed"

  changed: ->
    @model.set "password", @$el.val()
    # show and hide badge and guide
    if @model.get("password").length > 0
      $(".autohide").hide()
      $(".autohide-animate").hide({duration: 100, easing: "linear"}).parent().hide({duration: 100, easing: "linear"})
      $("#guide-promo").show()
    else
      $(".autohide").show()
      $(".autohide-animate").show({duration: 100, easing: "linear"}).parent().show()
      $("#guide-promo").hide()


class DetailsView extends Backbone.View

  template: _.template """
    <div id="details" style="padding-top: 10px;">
        <p><strong>Passwortlänge:</strong> <span id="length"><%= length %></span></p>
        <p><strong>Zeichenraumgröße:</strong> <span id="charset-size"><%= charsetSize %></span></p>
        <p>
            <strong>Mögliche Kombinationen:</strong><br>
            <span id="possible-combinations"><%= possibleCombinations %></span>
        </p>
        <p>
            <strong>Berechnungen pro Sekunde:</strong><br>
            <span id="calculations-second"><%= calculationsSecond %></span>
        </p>
    </div>"""

  initialize: ->
    @readablizer = new cdplib.LargeGermanNumberReadablizer "Eine", "Unendlich"
    @model.on "update", =>
      $("#details-toggle").popover "destroy"
      $("#details-toggle").popover
        html: true
        container: "body"
        placement: "bottom"
        trigger: "hover"
        content: @template
          length: @model.get("password").length
          charsetSize: @model.get("charsetSize")
          possibleCombinations: @readablizer.readablize @model.get("possibleCombinations")
          calculationsSecond: @readablizer.readablize @model.get("calculationsSecond")


module.exports.run = ->
  passwordModel = new cdplib.PasswordModel
  new cdplib.ColorStrengthView model: passwordModel
  new cdplib.ReadableStrengthView model: passwordModel
  new cdplib.RisksView model: passwordModel
  new PasswordInputView model: passwordModel
  new DetailsView model: passwordModel
  true
