class sc.ript.ui.Anchor extends sc.ript.ui.UserInterface

  name: 'Anchor'

  constructor: (el, {@duration, @easing}) ->
    super el
    @el.on 'click', @_clicked

  _clicked: (e) =>
    href = @el.attr 'href'
    return if href.charAt(0) isnt "#" or not $.scrollTo(href, @duration, @easing)
    e.preventDefault()
