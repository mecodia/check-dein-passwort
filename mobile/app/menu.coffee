class Router extends Backbone.Router

  routes:
    ":page": "showPage"

  showPage: (page) ->
    $('.container.view').hide()
    if page isnt 'check'
      $("#check").hide()
    $("#" + page).show()
    window.app.menuView.setActive(page)


class MenuView extends Backbone.View

  el: "#menu"

  events:
    "click a.nav-link": "showSection"
    "click i.fa": "showSection"

  menuToggle: ->
    #Hide or show menu when toggle button is pressed
    $("#menuToggle").toggleClass "active"
    $("body").toggleClass "body-push-toleft"
    $("#menu").toggleClass "menu-open"

    # get device height and set this absolute value for menu-object
    deviceHeight = $(window).height()
    $(".menu").height(deviceHeight)

  menuClose: ->
    #Hide menu when clicked in content
    $("#menuToggle").removeClass "active"
    $("body").removeClass "body-push-toleft"
    $("#menu").removeClass "menu-open"

  initialize: (options) =>

    @$el.find("#menuToggle").on "click", (e) =>
      e.stopImmediatePropagation()
      @menuToggle()

    # Prevent weird double-clicks
    @$el.on "click", (e) ->
      e.stopPropagation()

    # Close on outside click
    $("html").on "click", (e) =>
      if not event.target.tagName.toLowerCase() is "i"
        @menuClose(e)


  showSection: (e) =>
    # get id of object, which should be display, make it visible and hide all other objects.
    e.preventDefault()

    # get id of subpage, which should be showed
    if event.target.tagName.toLowerCase() is "i"
      idClicked = $(e.target).parent().data("id")
    else
      idClicked = e.target.dataset.id

    window.app.router.navigate("/#{idClicked}", {trigger: true})

    @model.set 'password', ''
    $('#password').val('')
    $("#title").show()

    @menuClose()

  setActive: (page) =>
    # set current page in navigation to active, and remove old active state
    @$el.find('li.active').removeClass("active")
    @$el.find("[data-id=#{page}]").parent().addClass("active")

  resize: (delay=5) =>
    setTimeout(
      (=> @$el.height($(window).height())),
      delay
    )

module.exports =
  MenuView: MenuView
  Router: Router
