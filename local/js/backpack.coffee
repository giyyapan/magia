class ThingListItem extends Widget
  constructor:(playerThing)->
    console.log playerThing
    super Res.tpls['thing-list-item']
    originData = playerThing.originData
    @UI.img.src = originData.img.src if originData.img
    @UI.name.J.text originData.name
    @UI.quatity.J.text playerThing.number if playerThing.number
    @originData = originData
    switch playerThing.type
      when "item" then @playerItem = playerThing
      when "supplies" then @playerSupplies = playerThing
      when "equipment" then @playerEquipment = playerThing
      else console.error "invailid playerThing type:#{playerThing.type}"
    @dom.onclick = =>
      @emit "select"
      
class DetailsBox extends ItemDetailsBox
  constructor:(backpack)->
    super
    @dom.id = "item-details-box"
    @bp = backpack
    @UI['cancel-btn'].J.hide()

class window.Backpack extends Menu
  constructor:(game)->
    super Res.tpls["backpack"]
    @J.hide()
    @player = game.player
    @detailsBox = new DetailsBox(this).appendTo @UI['item-details-box-wrapper']
    @currentTabName = "item"
    @initThings()
    @items = null
    @supplies = null
    @materials = null
    @equipments = null
    @initButtons()
  initButtons:->
    self = this
    @UI['exit-btn'].onclick = =>
      @emit "close"
      @hide()
    @UI['type-switch'].J.find(".tab").on "click",->
      return if not $(this).attr "value"
      self.switchTab $(this).attr "value"
  initThings:(type="gatherArea")->
    @freeThings()
    tabName = @currentTabName
    if type is "gatherArea"
      source = @player.backpack
    for thing in @player.backpack
      console.log thing
      switch thing.type
        when "item" then @items.push thing
        when "supplies" then @supplies.push thing
        when "material" then @materials.push thing
        when "equipment" then @equipments.push thing
    @switchTab tabName
  switchTab:(tabName)->
    @UI['item-list'].J.html ""
    @detailsBox.J.fadeOut "fast"
    self = this
    @UI['type-switch'].J.find(".tab").removeClass "selected"
    switch tabName
      when "item"
        arr = @items
        @UI['item-tab'].J.addClass "selected"
      when "supplies"
        arr = @supplies
        @UI['supplies-tab'].J.addClass "selected"
      when "equipment"
        arr = @equipments
        @UI['equipments-tab'].J.addClass "selected"
      else console.error "wrong type",tabName
    console.log arr
    return if not arr
    for thing in arr
      item = new ThingListItem thing
      item.appendTo @UI['item-list']
      item.on "select",->
        self.selectThing this
  selectThing:(item)->
    @J.find("thing-list-item").removeClass "selected"
    console.log item
    @detailsBox.showItemDetails item
  freeThings:->
    Utils.free @items,@supplies,@materials,@equipments
    @items = []
    @supplies = []
    @materials = []
    @equipments = []
  show:(callback)->
    @init()
    @initThings()
    @UILayer.J.fadeIn "fast",callback
    @J.slideDown "fast",=>
      @emit "show"
      callback() if callback
  hide:(callback)->
    super()
    @J.slideUp "fast",=>
      @emit "hide"
      callback() if callback
      
class window.BackpackBtn extends Widget
  constructor:(game,parentMenu)->
    tpl = "	<a data-id='backpack' class='backpack-btn'><img src='/img/menu/area-backpack-btn.png'></img></a>"
    super tpl
    @game = game
    @parentMenu = parentMenu
    @backpack = new Backpack @game
    @appendTo @parentMenu
    @backpack.on "hide",=>
      @parentMenu.show()
    @dom.onclick = =>
      @active()
  active:()->
    @backpack.show()
    
    
