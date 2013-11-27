class ShopItemDetailsBox extends ItemDetailsBox
  constructor:(menu)->
    super()
    @menu = menu
    @shop = @menu.shop
    @UI['cancel-btn'].onclick = =>
      @J.fadeOut "fast"
      w.J.removeClass "selected" for w in @menu.listItems
  showItemDetails:(type,item)->
    console.log item
    super item
    @UI['price'].J.text "$ 100"
    switch type
      when "playerBuy"
        @UI['use-btn'].J.text "购买"
        @UI['use-btn'].onclick = =>
          @playerBuyItem item
      when "playerSell"
        @UI['use-btn'].J.text "出售"
        @UI['use-btn'].onclick = =>
          @playerSellItem item
  playerBuyItem:(item)->
  playerSellItem:(item)->
            
class ShopListItem extends ListItem
  constructor:(tpl,type,playerThing,menu)->
    super tpl,playerThing
    @menu = menu
    @type = type
    @UI.name.J.text @dspName
  active:->
    @menu.detailsBox.showItemDetails @type,this
    
class ShopMenu extends Menu
  constructor:(shop)->
    @shop = shop
    super Res.tpls['shop-menu']
    @detailsBox = new ShopItemDetailsBox(this).appendTo @UI['right-section']
    @listItems = []
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
    @detailsBox.J.fadeOut "fast"
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
    items = []
    sellableType = @shop.originData.sellableType
    for playerThing in @shop.player.backpack when playerThing.type is sellableType
      items.push playerThing
    @addItems "playerSell",items
  playerBuyMode:->
    console.log "fuck"
    @UI['left-section'].J.fadeIn "fast"
    @UI['player-buy-mode'].J.addClass "selected"
    @UI['player-sell-mode'].J.removeClass "selected"
    data = @shop.originData
    items = []
    switch data.buyableType
      when "supplies" then ItemClass = PlayerSupplies
      when "equipment" then ItemClass = PlayerEquipment
      when "item" then ItemClass = PlayerItem
    for itemData in @shop.getDataByRelationship data.buyableItems
      items.push new ItemClass @shop.db,itemData.name,itemData
    @addItems "playerBuy",items
  addItems:(type,items)->
    console.log items
    @listItems = []
    @UI['item-list'].J.html ""
    for playerThing in items
      w = new ShopListItem @UI['list-item-tpl'].innerHTML,type,playerThing,this
      w.appendTo @UI['item-list']
      @listItems.push w
    
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
        
