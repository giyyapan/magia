class MissionListItem extends Widget
  constructor:(tpl,missionData,menu)->
    super tpl
    @menu = menu
    @missionData = missionData
    @mission = missionData
    @UI.name.J.text missionData.dspName
    @dom.onclick = =>
      @menu.detailsBox.showMissionDetails this
      @menu.detailsBox.on "activeMission",(mission)=>
        if mission is @mission then @updateStatus()
    @updateStatus()
  updateStatus:->
    switch @missionData.status
      when "current"
        @type = "进行中"
      when "finished"
        @type = "已结束"
        @J.slideUp "fast",=>
          @remove()
        return
      when "avail"
        @type = "可接受"
      when "disable"
        @type = "条件不足"
    @UI.status.J.text @type

class GuildMenu extends Menu
  constructor:(guild)->
    @guild = guild
    @game = guild.game
    super Res.tpls['guild-menu']
    @detailsBox = new MissionDetailsBox(@game).appendTo @UI['mission-box']
    @listItems = []
    @UI['service-mission'].onclick = => @initMissions()
    @UI['service-conversation'].onclick = -> guild.conversation()
    @UI['exit'].onclick = -> guild.exit()
    @UI['end-mission'].onclick = =>
      @guild.showServiceDialog()
      @showServiceOptions()
    @show()
  removeListItem:(item)->
    newArr = []
    for i in @listItems 
      if i isnt item
        newArr.push i
      else
        i.J.slideUp "fast",->
          $(this).remove()
    @listItems = newArr
  initMissions:->
    @hideServiceOptions()
    @guild.dialogBox.hide()
    @detailsBox.J.hide()
    @UI['mission-box'].J.fadeIn "fast"
    mm = @guild.game.missionManager
    a1 = mm.getMissions "current"
    a2 = mm.getMissions "avail"
    console.log a1,a2
    @addMissions a1.concat(a2)
  showServiceOptions:->
    @UI['mission-box'].J.fadeOut "fast"
    @UI['service-options'].J.fadeIn "fast"
  hideServiceOptions:->
    @UI['service-options'].J.fadeOut "fast"
  addMissions:(missions)->
    console.log "guild add missions",missions
    @listItems = []
    @UI['mission-list'].J.html ""
    for m in missions
      w = new MissionListItem @UI['mission-list-item-tpl'].innerHTML,m,this
      w.appendTo @UI['mission-list']
      @listItems.push w
    
class window.Guild extends Shop
  constructor:(game)->
    Stage.call this,game
    @db = game.db
    @originData = @db.shops.get "adventurerGuild"
    @player = @game.player
    @relationship = @player.relationships[@originData.npc]
    @bg = new Layer Res.imgs[@originData.bg]
    @drawQueueAdd @bg
    @menu = new GuildMenu this
    @initWelcomDialog()

