#some often-use widgets hear
class window.PopupBox extends Widget
  constructor:(title,content,acceptCallbcak)->
    super Res.tpls['popup-box']
    @box = @UI.box
    @J.hide()
    @box.J.hide()
    @UI.title.J.html title if title
    @UI.content.J.html content if content
    @UILayer = $ GameConfig.UILayerId
    self = this
    @UI['close'].onclick = ->
        self.close()
    @UI['accept'].onclick = ->
        self.accept()
    if acceptCallbcak
      @on "accept",acceptCallbcak
      @show()
  hideCloseBtn:()->
    @UI.close.J.hide()
  setCloseText:(t)->
    @UI.close.J.text t
  setAcceptText:(t)->
    @UI.accept.J.text t
  show:->
    @appendTo @UILayer
    @J.fadeIn "fast"
    @box.J.show()
    @box.J.addClass "animate-popup"
  close:->
    @emit "close"
    self = this
    @J.fadeOut "fast"
    @box.J.animate {top:"-=30px",opacity:0},"fast",->
      self.box.J.css "top",0
      self.box.J.removeClass "animate-popup"
      self.J.remove()
      self = null
  accept:->
    console.log this,"accept"
    @emit "accept"
    @close()
    
class window.MsgBox extends PopupBox
  constructor:(title,content,autoRemove=false)->
    super
    if autoRemove
      if autoRemove is true then autoRemove = 1000
      @UI.footer.J.hide()
      window.setTimeout (=>
        @close()
        ),autoRemove
    else
      @UI.accept.J.hide()
    @show()
    
class window.TraitItem extends Widget
  constructor:(name,value)->
    super Res.tpls['trait-item']
    @traitName = name
    @traitValue = value
    @lv = 1
    @UI.name.J.text Dict.TraitName[@traitName]
    @UI.name.J.addClass @traitName
    @changeValue @traitValue
  changeValue:(value)->
    @traitValue = value
    levelData = Dict.QualityLevel
    for v,index in levelData
      break if value < v
    @lv = parseInt(index + 1)
    @UI['trait-holder'].J.removeClass "lv1","lv2","lv3","lv4","lv5","lv6"
    @UI['trait-holder'].J.addClass "lv#{@lv}"
    @J.find(".lv").removeClass "active"
    @J.find(".filled").css "width","100%"
    activeDom = @UI["lv#{@lv}"]
    activeDom.J.addClass "active"
    width = (value - (levelData[index-1] or 0))/(levelData[index]-(levelData[index-1] or 0))*100
    activeDom.J.find(".filled").css "width","#{parseInt width}%"
    @UI.cursor.J.appendTo activeDom
    @UI.cursor.J.animate left:"#{parseInt(width)-1}%",10
    
class window.ItemDetailsBox extends Widget
  constructor:(tpl)->
    super Res.tpls['item-details-box'] 
    @currentItem = null
  showItemDetails:(item)->
    #item used to be item
    if item.playerSupplies
      @UI['remain-count-hint'].J.show()
      t = "#{item.playerSupplies.remainCount}/#{item.playerSupplies.maxRemainCount}"
      @UI['remain-count'].J.text t
    else
      @UI['remain-count-hint'].J.hide()
    @UI['content'].J.hide()
    @currentItem.J.removeClass "selected" if @currentItem
    @currentItem = item
    item.J.addClass "selected"
    @UI.name.J.text item.originData.name
    @UI.img.src = item.originData.img.src if item.originData.img
    @UI.description.J.text item.originData.description
    @initTraits item.playerItem
    @initTraits item.playerSupplies
    @J.fadeIn "fast"
    @UI['content'].J.fadeIn 100
  initTraits:(thingData)->
    return if not thingData or not thingData.traits
    @UI['traits-list'].J.html ""
    for name,value of thingData.traits
      new TraitItem(name,value).appendTo @UI['traits-list']
  hide:->
    @J.fadeOut "fast"
    @currentItem.J.removeClass "selected"
    
class window.MissionDetailsBox extends Widget
  constructor:(game)->
    super Res.tpls['mission-details-box']
    @game = game
    @UI['active-btn'].onclick = =>
      @emit "activeMission",@currentWidget.mission,@currentWidget
  setBtnText:(text)->
    if not text then @UI['active-btn'].J.fadeOut "fast"
    @UI['active-btn'].J.text text
  hide:(callback)->
    @J.fadeOut "fast",callback
  updateStatusText:->
    text = ""
    mission = @currentMission or @currentWidget.mission
    @UI.status.J.removeClass()
    switch mission.status
      when "current"
        text = "进行中"
      when "finished"
        text = "已结束"
      when "avail"
        text = "可接受"
      when "disable"
        text = "条件不足"
      else console.error "invailid status",mission
    if mission.status is "current" and mission.completed
      text = "可完成"
      @UI.status.J.addClass "completed"
    else
      @UI.status.J.addClass mission.status
    @UI.status.J.text text
  initMissionData:(mission)->
    @UI.title.J.text mission.dspName
    @UI.description.J.html mission.data.description.replace /\|/g,"</br>"
    @UI['details-content-list'].J.html ""
    data = mission.data
    if data.from
      character = @game.db.characters.get data.from
      @addContentListItem "委托人",character.name
    rewardText = ""
    for name,value of data.reward
      switch name
        when "money" then rewardText += "#{value}G "
    @addContentListItem "奖励",rewardText if rewardText
    @requestCount = 0
    if data.requests.text
      @addContentListItem "要求",data.requests.text
    else
      for name,value of data.requests
        switch name
          when "kill"
            for monster,index in value.split(",")
              sum = monster.split('*')[1] or 1
              monsterName = monster.split("*")[0]
              dspName = @game.db.monsters.get(monsterName).name
              finished = sum - (mission.incompletedRequests.kill[monsterName] or 0)
              @addContentListItem "要求","打败#{sum}只#{dspName} #{finished}/#{sum}",(finished >= sum)
          when "visit"
            dspName = @game.db.areas.get(value).name
            if mission.incompletedRequests.visit[value]
              @addContentListItem "要求","去往 #{dspName}",false
            else
              @addContentListItem "要求","去往 #{dspName}",true
          when "get"
            for thing,index in value.split(",")
              dspName = @game.db.things.get(thing).name
              if mission.incompletedRequests.get[thing]
                @addContentListItem "要求","获得 #{dspName}",false
              else
                @addContentListItem "要求","获得 #{dspName}",true
  addContentListItem:(type,content,completed=false)->
    if type is "要求"
      @requestCount += 1
      if @requestCount isnt 1 then type = ""
    tpl = @UI['content-list-item-tpl' ].innerHTML
    w = new Widget tpl
    w.UI.type.J.text type if type
    w.UI.content.J.text content if content
    if not completed
      w.UI.completed.J.hide()
    w.appendTo @UI['details-content-list']
  showMissionDetails:(widget,callback)->
    if widget.J
      console.log "show mission",widget
      if @currentWidget then @currentWidget.J.removeClass "selected"
      @currentWidget = widget
      @currentWidget.J.addClass "selected"
      @currentMission = null
      mission = widget.missionData
    else
      mission = widget
      @currentWidget = null
      @currentMission = mission
    mission.checkComplete()
    @initMissionData mission
    @updateStatus mission
    @J.fadeIn "fast"
  updateStatus:(mission)->
    @updateStatusText()
    switch mission.status
      when "current"
        if mission.completed
          @setBtnText "完成"
          @UI['active-btn'].onclick = =>
            mission.finish()
            new MsgBox "成功","任务 #{mission.dspName} 完成，任务奖励已经获得"
            @updateStatus mission
            @emit "activeMission",mission
        else
          @setBtnText "关闭"
          @UI['active-btn'].onclick = =>
            @hide callback
      when "avail"
        @setBtnText "接受"
        @UI['active-btn'].onclick = =>
          if not mission.start()
            console.error "mission start faild"
          new MsgBox "成功","接受任务 #{mission.dspName} 。"
          @updateStatus mission
          @emit "activeMission",mission
      when "finished"
        @setBtnText "关闭"
        @UI['active-btn'].onclick = =>
          @updateStatus mission
          @hide callback
          
class window.ListItem extends Widget
  constructor:(tpl,playerThing)->
    super tpl
    return if not playerThing
    @name = playerThing.name
    @dspName = playerThing.dspName
    @originData = playerThing.originData
    @playerThing = playerThing
    @type = playerThing.type
    switch playerThing.type
      when "item" then @playerItem = playerThing
      when "supplies" then @playerSupplies = playerThing
      when "equipment" then @playerEquipment = playerThing
      else console.error "invailid type",playerThing.type
    @dom.onclick = =>
      #AudioManager.play "startClick"
      @active() if @active
  active:null
