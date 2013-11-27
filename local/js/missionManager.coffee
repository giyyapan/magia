class window.MissionManager extends EventEmitter
  constructor:(game)->
    super null
    @game = game
    @missions = []
