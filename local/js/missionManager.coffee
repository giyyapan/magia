class Mission extends EventEmitter
  constructor:(manager,name,data)->
    super null
    @name = name
    @data = data
    @manager = manager
    @game = manager.game
    @player = @game.player
    @dspName = data.name
    @completed = false
    @requests = {}
    @status = @getStatus()
    @incompletedRequests = {}
    @initRequests()
  initRequests:()->
    for name,value of @data.requests
      switch name
        when "get"
          @requests.get = {}
          things = value.split ","
          for t in things
            if t.indexOf("*") > -1
              name = t.split("*")[0]
              number = parseInt(t.split("*")[1])
            else
              name = t
              number = 1
            @requests.get[name] = parseInt(number)
        when "visit"
          @requests.visit = {}
          places = value.split ","
          for p in places
            @requests.visit[p] = true
        when "kill"
          @requests.kill = {}
          monsters = value.split ","
          for t in monsters
            if t.indexOf("*") > -1
              name = t.split("*")[0]
              number = parseInt(t.split("*")[1])
            else
              name = t
              number = 1
            @requests.kill[name] = parseInt(number)
    if @status is "current" or @status is "avail"
      @incompletedRequests = Utils.clone @requests,true
      console.log "init requests",@requests
      @initIncompletedRequests()
    else
      @incompletedRequests = {}
  initIncompletedRequests:->
    # 遍历玩家的完成任务数据，将当前任务中的要求
    pcr = @player.missions.current[@name]
    if not pcr then return false 
    for type,obj of @incompletedRequests
      if pcr[type]
        for name,value of pcr[type]
          if value is true
            delete obj[name]
          if typeof value is "number"
            obj[name] -= value
            if obj[name] <= 0 then delete obj[name]
    if @incompletedRequests.get
      for name,number of @incompletedRequests.get
        hasNumber = @player.hasThing(name)
        @update "get",name:name,number:hasNumber if hasNumber
    console.log @incompletedRequests
  update:(type,data)->
    ir = @incompletedRequests
    pcr = @player.missions.current[@name] #player completed requests
    if not pcr then return console.error "player no request data",@name
    if not ir[type] then return false
    switch type
      when "kill"
        console.log "enter kill"
        for monsterName in data
          continue if not ir.kill[monsterName]
          ir.kill[monsterName] -= 1
          delete ir.kill[monsterName] if ir.kill[monsterName] <= 0
          pcr.kill[monsterName] += 1
      when "get"
        thingName = data.name
        number = data.number or 1
        if ir.get[thingName]
          ir.get[thingName] -= 1
          delete ir.get[thingName] if ir.get[thingName] <= 0
          pcr.get[thingName] += 1
      when "visit"
        placeName = data
        delete ir.visit[placeName]
        pcr.visit[placeName] = true
        console.log ir
    return @checkComplete()
  checkComplete:->
    return yes if @completed is true
    for type,data of @incompletedRequests
      for name,value of data
        return false
    @completed = true
    if @data.autoComplete then @autoFinish()
    return true
  getStatus:->
    player = @player
    if player.missions.current[@name] isnt undefined then return @status = "current"
    if player.missions.finished[@name] isnt undefined then return @status = "finished" #completed and areported
    if @isAvailable() then return @status = "avail"
    else return @status = "disable"
  autoFinish:->
    console.log "autofinish"
    box = new PopupBox "任务信息","任务 #{@dspName} 已经完成",=>
      @finish()
    box.hideCloseBtn()
  start:->
    console.log "mission start"
    if not @isAvailable()
      console.error "not availe!",this
      return false
    @player.missions.current[@name] = @getNewMissionData()
    @status = "current"
    @handleStartData()
    @player.saveData()
    return true
  finish:->
    delete @player.missions.current[@name]
    @player.missions.finished[@name] = true
    @status = "finished"
    @handleEndData()
    @palyer.saveData()
    return true
  handleEndData:->
    return false if not @data.end
    for type,data of @data.end
      switch type
        when "story"
          @game.storyManager.showStory data
        when "onloackarea"
          @player.onloackedAreas[data] = true
  handleStartData:->
    return false if not @data.start
    for type,data of @data.start
      switch type
        when "story"
          @game.storyManager.showStory data
        when "onloackarea"
          @player.onloackedAreas[data] = true
  getNewMissionData:->
    obj = {}
    for type,data of @requests
      obj[type] = {}
      for name,value of @request
        if value is true
          obj[type][name] = false
          continue
        if not isNaN value
          obj[type][name] = 0
        else
          console.error "invailid request data : ",name,this
    return obj
  isAvailable:->
    if @data.after
      if not @player.missions.finished[@data.after]
        return no
    return yes
    
class window.MissionManager extends EventEmitter
  constructor:(game)->
    super null
    @game = game
    @player = game.player
    @missions = {}
    for name,data of @game.db.missions.getAll()
      @missions[name] = new Mission this,name,data
    console.log @missions
    @game.on "switchStage",(newStage)=>
      console.log "on switch stage fired"
      @handleSwitchStage newStage
    @game.player.on "getThing",(type,thing)=>
      @updateCurrentMissions "get",thing
  handleSwitchStage:(newStage)->
    switch newStage.stageName
      when "battle"
        newStage.on "win",(data)=>
          console.log "fuck win",data,data.monsters
          @updateCurrentMissions "kill",data.monsters
      when "area","shop"
        @updateCurrentMissions "visit",newStage.switchStageData
      when "home","guild"
        @updateCurrentMissions "visit",newStage.stageName
  updateCurrentMissions:(type,data)->
    for name,mission of @missions when mission.status is "current"
      mission.update type,data
    @player.saveData()
    console.log @player
  startMission:(mission)->
    if typeof mission is "string"
      name = mission
      mission = @missions[name]
    if not mission 
      return console.error "invailid mission :",mission
    return mission.start()
  getMissions:(type)->
    # all completed current
    res = []
    switch type
      when "all"
        for name,mission of @missions
          res.push mission
      when "finished"
        for name,mission of @missions when mission.getStatus() is "finished"
          res.push mission
      when "current" 
        for name,mission of @missions when mission.getStatus() is "current"
          res.push mission
      when "avail"
        for name,mission of @missions when mission.getStatus() is "avail"
          res.push mission
    return res
