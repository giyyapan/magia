class ShopItemDetailsBox extends ItemDetailsBox
  constructor:(menu)->
    super()
    @menu = menu
    @shop = @menu.shop
    @UI['cancel-btn'].onclick = =>
      @J.fadeOut "fast"
      w.J.removeClass "selected" for w in @menu.listItems
  showItemDetails:(mode,item)->
    super item
    basicPrice = item.playerThing.price
    switch mode
      when "playerBuy"
        price = basicPrice * parseFloat(@shop.getDataByRelationship "playerBuyPrice") >> 0
        @UI.price.J.text "$#{price}"
        if price > @shop.player.money then @css3Animate.call @UI.price,"animate-warning"
        @UI['use-btn'].J.text "购买"
        @UI['use-btn'].onclick = =>
          @playerBuyItem item,price
      when "playerSell"
        console.log basicPrice,@shop.getDataByRelationship "playerSellPrice"
        price = basicPrice * parseFloat(@shop.getDataByRelationship "playerSellPrice") >> 0
        @UI.price.J.text "$#{price}"
        @UI['use-btn'].J.text "出售"
        @UI['use-btn'].onclick = =>
          @playerSellItem item,price
  playerBuyItem:(item,price)->
    player = @shop.player
    if price > player.money
      @css3Animate.call @UI.price,"animate-warning"
      return new MsgBox "购买失败","我的钱好像不够.."
    player.money -= price
    @menu.updateMoney()
    switch item.type
      when "item" then player.getItem "backpack",item.playerItem
      when "supplies" then player.getSupplies "backpack",item.playerSupplies
      when "equipment" then player.getEquipment "backpack",item.playerEquipment
      else console.error "invailid type",item.type
    player.saveData()
    new MsgBox "购买成功","获得了一个 #{item.dspName}",600
  playerSellItem:(item,price)->
    player = @shop.player
    player.money += price
    @menu.updateMoney()
    if item.playerItem and item.playerItem.number > 1
      item.playerItem.number -= 1
    else
      player.removeThing item.playerThing
      @hide()
      @menu.removeListItem item
    player.saveData()
    new MsgBox "出售成功","卖出了一个 #{item.dspName} </br> 获得金钱：#{price} G",600
            
class ShopListItem extends ListItem
  constructor:(tpl,mode,playerThing,menu)->
    super tpl,playerThing
    @menu = menu
    @mode = mode
    @UI.name.J.text @dspName
  active:->
    @menu.detailsBox.showItemDetails @mode,this
    
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
  removeListItem:(item)->
    newArr = []
    for i in @listItems 
      if i isnt item
        newArr.push i
      else
        i.J.slideUp "fast",->
          $(this).remove()
    @listItems = newArr
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
    @detailsBox.J.fadeOut "fast"
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
    @detailsBox.J.fadeOut "fast"
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
    if typeof from is "string"
      from = @originData[from]
    if not from then return console.error "invailid from",from
    found = null
    for required,data of from
      if parseInt(required) <= @relationship
        found = data
      else
        break
    return found
  showServiceDialog:()->
    @dialogBox.display text:Utils.random(@originData.waitText),nostop:true
  initWelcomDialog:->
    @dialogBox = new DialogBox @game
    @dialogBox.show()
    text = @getDataByRelationship @originData.welcomeText
    console.log text,@originData.npcName
    @dialogBox.display text:text,speaker:@originData.npcName,nostop:true,=>
      @menu.showServiceOptions()
        
