class MissionListItem extends Widget
  constructor:(tpl,missionData,menu)->
    super tpl
    @menu = menu

class MissionDetailsBox extends Widget
  constructor:(tpl,menu)->
    super tpl
    @menu = menu
  showMissionDetails:(widget)->
    data = widget.missionData
    @UI.title.J.text data.title
    @UI.description.J.text data.title
    
class GuildMenu extends Menu
  constructor:(guild)->
    @guild = guild
    super Res.tpls['guild-menu']
    @detailsBox = new MissionDetailsBox @UI['mission-details-box'],this
    @listItems = []
    @UI['service-mission'].onclick = => @initMissions()
    @UI['service-conversation'].onclick = -> guild.conversation()
    @UI['exit'].onclick = -> guild.exit()
    @UI['completed-mission'].onclick = => @completedMissionMode()
    @UI['current-mission'].onclick = => @currentMissionMode()
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
    @UI['mission-details-box'].J.hide()
    @UI['mission-box'].J.fadeIn "fast"
  showServiceOptions:->
    @UI['mission-box'].J.fadeOut "fast"
    @UI['service-options'].J.fadeIn "fast"
  hideServiceOptions:->
    @UI['service-options'].J.fadeOut "fast"
  currentMissionMode:->
    missions = @guild.missionManager.getMissions "current"
    @addItems missions
  completedMissionMode:->
    missions = @guild.missionManager.getMissions "completed"
    @addItems missions
  addItems:(items)->
    console.log items
    @listItems = []
    @UI['item-list'].J.html ""
    for playerThing in items
      w = new MissionListItem @UI['list-item-tpl'].innerHTML,playerThing,this
      w.appendTo @UI['item-list']
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

