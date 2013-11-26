class ShopMenu extends Menu
  constructor:(shop)->
    @shop = shop
    super Res.tpls['shop-menu']
    @detailsBox = new ItemDetailsBox().appendTo @UI['right-section']
    @UI['service-traid'].onclick = => @initTraid()
    @UI['service-conversation'].onclick = -> shop.conversation()
    @UI['exit'].onclick = -> shop.exit()
    @UI['player-buy-mode'].onclick = => @playerBuyMode()
    @UI['player-sell-mode'].onclick = => @playerSellMode()
    @UI['end-traid'].onclick = =>
      @shop.showServiceDialog()
      @showServiceOptions()
    @show()
  showServiceOptions:->
    @UI['left-section'].J.fadeOut "fast"
    @UI['service-options'].J.fadeIn "fast"
  hideServiceOptions:->
    @UI['service-options'].J.fadeOut "fast"
  initTraid:->
    @hideServiceOptions()
    @shop.dialogBox.hide()
    @updateMoney()
    @playerBuyMode()
  updateMoney:->
    @UI['player-money'].J.text @shop.player.money
  playerSellMode:->
    @UI['left-section'].J.fadeIn "fast"
    @UI['player-sell-mode'].J.addClass "selected"
    @UI['player-buy-mode'].J.removeClass "selected"
  playerBuyMode:->
    @UI['left-section'].J.fadeIn "fast"
    @UI['player-buy-mode'].J.addClass "selected"
    @UI['player-sell-mode'].J.removeClass "selected"
    
class window.Shop extends Stage
  constructor:(game,name)->
    super game
    @db = game.db
    @originData = @db.shops.get name
    @player = @game.player
    @relationship = @player.relationships[@originData.npc]
    @bg = new Layer Res.imgs[@originData.bg]
    @drawQueueAdd @bg
    @menu = new ShopMenu this
    @initWelcomDialog()
  exit:->
    @menu.hideServiceOptions()
    @dialogBox.display text:@originData.exitText,nostop:true,=>
      @dialogBox.hide =>
        @bg.fadeOut "fast",=>
          @game.switchStage "worldMap"
  conversation:->
    console.log "conversation"
    @menu.hideServiceOptions()
    text = @getDataByRelationship @originData.conversations
    @dialogBox.display text:text,=>
      @showServiceDialog()
      @menu.showServiceOptions()
  getDataByRelationship:(from)->
    found = null
    for required,data of from
      if parseInt(required) <= @relationship
        found = data
      else
        break
    return found
  showServiceDialog:->
    @dialogBox.display text:Utils.random @originData.waitText
  initWelcomDialog:->
    @dialogBox = new DialogBox()
    @dialogBox.show()
    text = @getDataByRelationship @originData.welcomeText
    @dialogBox.display text:text,speaker:@originData.npcName,nostop:true,=>
      @menu.showServiceOptions()
        
