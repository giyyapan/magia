class Mission extends EventEmitter
  constructor:(manager,name,data)->
    super null
    @name = name
    @data = data
    @manager = manager
    @player = manager.game.player
    @dspName = data.name
    @status = @getStatus()
  getStatus:->
    player = @player
    for name of player.currentMissions
      if name is @name then @status = "current"
    for name of player.completedMissions
      if name is @name then @status = "completed"
    if @avail then @status = "avail"
    else @status = "disable"
    return @status
  avail:->
    if @data.after
      if not @player.completedMissions[@data.after]
        return no
    return yes
  checkComplete:()->
    
    
class window.MissionManager extends EventEmitter
  constructor:(game)->
    super null
    @game = game
    @player = game
    @missions = {}
    for name,data of @game.db.missions.getAll()
      @missions[name] = new Mission this,name,data
  startMission:(mission)->
  completeMission:(mission)->
  getMissions:(type)->
    # all completed current
    res = []
    switch type
      when "all"
        res = @missions
      when "completed"
        for m in @missions when m.getStatus is "completed"
          res.push m 
      when "current" 
        for m in @missions when m.getStatus is "current"
          res.push m
      when "avail"
        for m in @missions when m.getStatus is "avail"
          res.push m
    return res
