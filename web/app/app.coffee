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
    else
      $(".autohide").show()
      $(".autohide-animate").show({duration: 100, easing: "linear"}).parent().show()


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


class ResultSharer extends Backbone.View

  el: "#share-result"

  initialize: ->
    @readableGenerator = new cdplib.ReadableStrengthGenerator

    @model.on "change", =>

      if @model.get "instantly"
        description = "Ein herkömmlicher PC kann mein Passwort sofort knacken!"
      else
        description = "Ein herkömmlicher PC kann mein Passwort innerhalb von #{@readableGenerator.get @model.get 'timeSeconds'} knacken!"

      fb_link = "https://www.facebook.com/dialog/feed?" + $.param
        app_id: 460997397341722
        redirect_uri: 'http://checkdeinpasswort.de'
        link: 'http://checkdeinpasswort.de'
        name: "Wie sicher ist mein Passwort?"
        description: description

      twitter_link = "http://twitter.com/home/?" + $.param
        status: description + "\n\nhttp://checkdeinpasswort.de"

      @$el.find(".fb-link").attr "href", fb_link
      @$el.find(".tw-link").attr "href", twitter_link


module.exports.run = ->
  passwordModel = new cdplib.PasswordModel
  new cdplib.ColorStrengthView model: passwordModel
  new cdplib.ReadableStrengthView model: passwordModel
  new cdplib.RisksView model: passwordModel
  new PasswordInputView model: passwordModel
  new DetailsView model: passwordModel
  new ResultSharer model: passwordModel
  true