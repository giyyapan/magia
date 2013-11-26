class ShopMenu extends Menu
  constructor:(shop)->
    @shop = shop
    super Res.tpls['shop-menu']
    @detailsBox = new ItemDetailsBox().appendTo @UI['right-section']
    @UI['welcome-traid'].onclick = -> shop.traid()
    @UI['welcome-conversation'].onclick = -> shop.conversation()
    @UI['welcome-exit'].onclick = -> shop.exit()
    @show()
  showWelcomOptions:->
    @UI['welcome-options'].J.fadeIn "fast"

class window.Shop extends Stage
  constructor:(game,name)->
    super game
    @db = game.db
    @originData = @db.shops.get name
    @relationship = @game.player.relationships[@originData.npc]
    @bg = new Layer Res.imgs[@originData.bg]
    @drawQueueAdd @bg
    @menu = new ShopMenu this
    @initWelcomDialog()
  exit:->
    @menu.J.fadeOut "fast"
    @dialogBox.display text:@originData.exitText,nostop:true,=>
      @dialogBox.hide =>
        @bg.fadeOut "fast",=>
          @game.switchStage "worldMap"
  conversation:->
  traid:->
  getDataByRelationship:(from)->
    found = null
    for required,data of from
      if parseInt(required) <= @relationship
        found = data
      else
        break
    return found
  initWelcomDialog:->
    @dialogBox = new DialogBox()
    @dialogBox.show()
    text = @getDataByRelationship @originData.welcomeText
    @dialogBox.display text:text,speaker:@originData.npcName,nostop:true,=>
      @menu.showWelcomOptions()
        
