cdplib = require('cdplib')
views = require('views')
menu = require('menu')

class Application
  initialize: () ->
    this.bindEvents()

  # Bind Event Listeners
  #
  # Bind any events that are required on startup. Common events are:
  # 'load', 'deviceready', 'offline', and 'online'.
  bindEvents: () ->
    document.addEventListener('deviceready', this.onDeviceReady, false)
    if /https?:\/\/localhost(.*)/.test(location.href)
      @onDeviceReady()

    window.addEventListener 'load', ->
      FastClick.attach(document.body)
    , false

  # deviceready Event Handler
  #
  # The scope of 'this' is the event. In order to call the 'receivedEvent'
  # function, we must explicitly call 'app.receivedEvent(...);'
  onDeviceReady: () =>

    # init models, views and router
    passwordModel = new cdplib.PasswordModel()
    bodyColorView = new cdplib.ColorStrengthView model: passwordModel
    readableStrengthView = new cdplib.ReadableStrengthView model: passwordModel
    risksView = new cdplib.RisksView model: passwordModel
    passwordInputView = new views.PasswordInputView model: passwordModel
    shareView = new views.ShareView model: passwordModel

    @menuView = menuView = new menu.MenuView model: passwordModel
    @router = new menu.Router()

    Backbone.history.start({pushState: false})

    # listen to PhoneGap events
    document.addEventListener 'backbutton', ->
      if window.location.hash is '#check'
        navigator.app.exitApp()
      else
        window.app.router.navigate('check', {trigger: true})
      # This would be nice, but is really buggy.
      # window.history.back()
    , false

    document.addEventListener "showkeyboard", ->
      menuView.resize()
      menuView.menuClose()
    , false

    document.addEventListener "hidekeyboard", ->
      menuView.resize()
    , false

    window.addEventListener 'orientationchange', ->
      menuView.resize(0)
    , false

    @router.navigate('check', {trigger: true})


module.exports = new Application()