class sc.ript.ui.UserInterface extends sc.ript.event.EventEmitter

  constructor: (el) ->
    console.log @name, @
    @el = $(el).data(@name, @)