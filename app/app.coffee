class PasswordModel extends Backbone.Model

  initialize: ->
    @charsets = [
      name: "ASCII Lowercase"
      regex: /[a-z]/
      size: 26
    ,
      name: "ASCII Uppercase"
      regex: /[A-Z]/
      size: 26
    ,
      name: "ASCII Numbers"
      regex: /\d/
      size: 10
    ,
      name: "ASCII Symbols"
      regex: /[ !"#$%&'()*\+,-./:;<=>?@[\\\]^_`{|}~]/
      size: 33
    ,
      name: "Unicode Latin 1 Supplement"
      regex: /[\u00A1-\u00FF]/
      size: 94
    ,
      name: "Unicode Currency Symbols"
      regex: /[\u20A0-\u20BA]/
      size: 27
    ]

    @commonPasswords = require('passwords/common')
    @names = require('passwords/names')
    @words = require('passwords/words')

    # Generate common german keyboard patterns:
    horizontal = "^1234567890ß´qwertzuiopü+asdfghjklöä#<yxcvbnm,.-"
    horizontal += horizontal.split("").reverse().join ""

    verticalLeftRight = "<1qay2wsx3edc4rfv5tgb6zhn7ujm8ik,9ol.0pö-ßüä´+#"
    verticalLeftRight += verticalLeftRight.split("").reverse().join ""

    verticalRightLeft = "#+ä-´üö.ßpl,0okm9ijn8uhb7zgv6tfc5rdx4esy3wa<2q1"
    verticalRightLeft += verticalRightLeft.split("").reverse().join ""

    @keyboardPatterns = horizontal + verticalLeftRight + verticalRightLeft

    # Generate alphabet patterns:
    @alphabetPatterns = "abcdefghijklmnopqrstuvwxyz"
    @alphabetPatterns += @alphabetPatterns.split("").reverse().join ""

    @set "calculationsSecond", 4000000000
    @set "maxCharsetSize", _.reduce @charsets, (x, y) ->
      (x.size or x) + y.size

    @on "change:password", @update

  update: =>
    pw = @get("password")
    pw_ = pw.toLowerCase()

    # Strength calculations:
    if pw.length
      charsetSize = 0
      for charset in @charsets
        if charset.regex.test @get "password"
          charsetSize += charset.size

      @set "charsetSize", charsetSize
      @set "possibleCombinations", Math.pow charsetSize, pw.length
      @set "timeSeconds", @get("possibleCombinations") / @get("calculationsSecond")
    else
      @set "charsetSize", 0
      @set "possibleCombinations", 0
      @set "timeSeconds", 0

    # Basic checks:
    @set "check-red-common", pw_ in @commonPasswords
    @set "check-red-veryshort", 0 < pw.length < 5
    @set "check-yellow-short", 4 < pw.length < 8
    @set "check-yellow-charsetsize", pw.length > 0 and @get("charsetSize") < 62
    @set "check-yellow-keyboardpattern", pw.length > 3 and -1 < @keyboardPatterns.indexOf pw_, 0
    @set "check-yellow-alphabetpattern", pw.length > 3 and -1 < @alphabetPatterns.indexOf pw_, 0
    @set "check-yellow-dateorphone", pw.length > 3 and /^[0-9.-/\\]+$/.test pw
    @set "check-yellow-wordnumber", pw.length > 3 and /^[0-9]+[a-z]+$|^[a-z]+[0-9]+$/.test pw_
    @set "check-green-long", 15 < pw.length

    # Complex checks:
    containsName = false
    for name in @names
      if -1 < pw_.indexOf name, 0
        containsName = true
        break
    @set "check-yellow-name", containsName

    containsPattern = false
    if pw_.length > 5
      for n in [2..pw_.length/2]
        ngram = pw_[0..n - 1]
        # Multiply ngram to cover password length:
        ngrams = Array(parseInt((pw_.length / n) + 2)).join ngram
        # Trim ngrams to match password length:
        ngrams = ngrams[0..pw_.length - 1]
        containsPattern = containsPattern or pw_ == ngrams
    @set "check-yellow-pattern", containsPattern

    containsWord = false
    for word in @words
      if -1 < pw_.indexOf word, 0
        containsWord = true
        break
    @set "check-yellow-word", containsWord


class PasswordInputView extends Backbone.View

  el: "#password"

  events: #
    "keyup": "changed"

  changed: ->
    @model.set "password", @$el.val()


class ColorStrengthView extends Backbone.View

  el: "body"

  initialize: ->
    @model.on "change:timeSeconds", =>
      # Limit the color space according to insecurities:
      [red, yellow] = false
      for check in @model.pairs()
        red = red or check[1] if /^check-red/.test check[0]
        yellow = yellow or check[1] if /^check-yellow/.test check[0]

      # Calculate gradient position:
      frac = Math.log(@model.get("possibleCombinations")) / Math.log(@model.get("maxCharsetSize"))

      if frac < 0
        # blue
        @$el.css "background-color", "#6AA3A4"
      else if red
        @$el.css "background-color", "#CE1836"
      else if frac < 5
        # gradient red -> yellow
        r = 206 + (237 - 206) * frac / 5
        g = 24 + (185 - 24) * frac / 5
        b = 54 + (46 - 54) * frac / 5
        @$el.css "background-color", "rgb(#{r.toFixed(0)}, #{g.toFixed(0)}, #{b.toFixed(0)})"
      else if yellow
        @$el.css "background-color", "#EDB92E"
      else if frac < 10
        # gradient yellow -> green
        r = 237 + (106 - 237) * (frac - 5) / 5
        g = 185 + (164 - 185) * (frac - 5) / 5
        b = 46 + (107 - 46) * (frac - 5) / 5
        @$el.css "background-color", "rgb(#{r.toFixed(0)}, #{g.toFixed(0)}, #{b.toFixed(0)})"
      else
        # green
        @$el.css "background-color", "#6AA46B"


class ReadableStrengthGenerator

  constructor: ->
    @readablizer = new LargeGermanNumberReadablizer "einer", "unendlich"

  get: (seconds) ->
    # Seconds:
    if seconds < 1
      return "#{seconds.toFixed(10)} Sekunden"

    if seconds.toFixed(0) == "1"
      return "einer Sekunde"

    if seconds < 60
      return "#{seconds.toFixed(0)} Sekunden"

    # Minutes:
    minutes = seconds / 60

    if minutes.toFixed(0) == "1"
      return "einer Minute"

    if minutes < 60
      return "#{minutes.toFixed(0)} Minuten"

    # Hours:
    hours = minutes / 60

    if hours.toFixed(0) == "1"
      return "einer Stunde"

    if hours < 24
      return "#{hours.toFixed(0)} Stunden"

    # Days:
    days = hours / 24

    if days.toFixed(0) == "1"
      return "einem Tag"

    if days < 365
      return "#{days.toFixed(0)} Tagen"

    # Years:
    years = days / 365

    if years.toFixed(0) == "1"
      return "einem Jahr"

    return "#{@readablizer.readablize(years)} Jahren"


class ReadableStrengthView extends Backbone.View

  el: "#result"

  initialize: ->
    @readableGenerator = new ReadableStrengthGenerator

    @model.on "change:timeSeconds", =>
      if @model.get("timeSeconds")
        @$el.show()
        @$el.find("#time").text @readableGenerator.get @model.get "timeSeconds"
      else
        @$el.hide()


class RisksView extends Backbone.View

  el: "#checks"

  initialize: ->
    @model.on "all", (eventName) =>
      if eventName == "change"
        if @$el.children(":not([style*='display: none'])").length
          @$el.show()
        else
          @$el.hide()
      else if eventName[0..11] == "change:check"
        risk = eventName[7..]
        if @model.get risk
          @$el.find("##{risk}").show()
        else
          @$el.find("##{risk}").hide()


class DetailsView extends Backbone.View

  el: "#details"

  initialize: ->
    @readablizer = new LargeGermanNumberReadablizer "Eine", "Unendlich"
    @$el.find("#calculations-second").text @readablizer.readablize @model.get("calculationsSecond")

    @model.on "change", =>
      @$el.find("#length").text @model.get("password").length
      @$el.find("#charset-size").text @model.get("charsetSize")
      @$el.find("#possible-combinations").text @readablizer.readablize @model.get("possibleCombinations")


class LargeGermanNumberReadablizer

  constructor: (@article, @tooLarge) ->
    # http://de.wikipedia.org/wiki/Zahlennamen#Billion.2C_Billiarde_und_dar.C3.BCber_hinaus
    @numberNames =
      ["", "Tausend", "Million", "Milliarde", "Billion", "Billiarde", "Trillion", "Trilliarde", "Quadrillion",
       "Quadrilliarde", "Quintillion", "Quintilliarde", "Sextillion", "Sextilliarde", "Septillion", "Septilliarde",
       "Oktillion", "Oktilliarde", "Nonillion", "Nonilliarde", "Dezillion", "Dezilliarde", "Undezillion",
       "Undezilliarde", "Dodezillion", "Dodezilliarde", "Tredezillion", "Tredezilliarde", "Quattuordezillion",
       "Quattuordezilliarde", "Quindezillion", "Quindezilliarde", "Sedezillion", "Sedezilliarde", "Septendezillion",
       "Septendezilliarde", "Dodevigintillion", "Dodevigintilliarde", "Undevigintillion", "Undevigintilliarde",
       "Vigintillion", "Vigintilliarde"]

  readablize: (number) ->
    if not number then return "0"

    exponent = Math.floor(Math.log(number) / Math.log(1000))

    if exponent > @numberNames.length - 1
      readable = @tooLarge
    else
      factor = parseInt(number / Math.pow(1000, exponent))

      if factor == 1
        if exponent == 1
          readable = @numberNames[exponent]
        else
          readable = "#{@article} #{@numberNames[exponent]}"
      else
        readable = "#{factor} #{@numberNames[exponent]}"

        # Append correct suffix:
        if exponent > 1
          if exponent % 2
            readable += "n"
          else
            readable += "en"

    return readable


class ResultSharer extends Backbone.View

  el: "#share-result"
  template: _.template """
    <p>Teile dein Ergebnis!</p>
    <p>
      <a class="btn btn-xs btn-default" href="<%= fb_link %>" target="_blank">Facebook</a>
      <a class="btn btn-xs btn-default" href="<%= twitter_link %>" target="_blank">Twitter</a>
    </p>
  """

  initialize: ->
    @readableGenerator = new ReadableStrengthGenerator

    @model.on "change", =>

      fb_link = "https://www.facebook.com/dialog/feed?" + $.param
        app_id: 460997397341722
        redirect_uri: 'http://checkdeinpasswort.de'
        link: 'http://checkdeinpasswort.de'
        name: "Wie sicher ist mein Passwort?"
        description: "Ein herkömmlicher PC kann mein Passwort innerhalb von #{@readableGenerator.get @model.get 'timeSeconds'} knacken!"
      twitter_link = "http://twitter.com/home/?" + $.param
        status: """Ein herkömmlicher PC kann mein Passwort innerhalb von #{@readableGenerator.get @model.get 'timeSeconds'} knacken!\n\nhttp://checkdeinpasswort.de"""
      @$el.html @template {fb_link, twitter_link}


module.exports.run = ->
  passwordModel = new PasswordModel
  new PasswordInputView model: passwordModel
  new ReadableStrengthView model: passwordModel
  new ColorStrengthView model: passwordModel
  new RisksView model: passwordModel
  new DetailsView model: passwordModel
  new ResultSharer model: passwordModel
  true