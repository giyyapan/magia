class ThingListItem extends ThingListWidget
  constructor:(thing)->
    super thing.originData,thing.number
    @thing = thing
    @dom.onclick = =>
      @emit "select"
      
class DetailsBox extends ItemDetailsBox
  constructor:(backpack)->
    super
    @bp = backpack
    @UI['cancel-btn'].J.hide()

class window.Backpack extends Menu
  constructor:(game,type)->
    super Res.tpls["backpack"]
    @J.hide()
    @player = game.player
    @currentTabName = "items"
    @initThings()
    @detailsBox = new DetailsBox this
    @detailsBox.appendTo @UI['item-details-box-wrapper']
    @items = null
    @supplies = null
    @materials = null
    @equipments = null
    @initButtons()
  initButtons:->
    self = this
    @UI['exit-btn'].onclick = =>
      @emit "close"
    @UI['type-switch'].J.find(".tab").on "click",->
      return if not $(this).attr "value"
      self.switchTab $(this).attr "value"
  initThings:(type="gatherArea")->
    @freeThings()
    #type = gatherArea or town
    tabName = @currentTabName
    if type is "gatherArea"
      source = @player.backpack
    for thing in @player.backpack
      switch thing.type
        when "item" then @items.push thing
        when "supplies" then @supplies.push thing
        when "material" then @materials.push thing
        when "equipment" then @equipments.push thing
    @switchTab tabName
  switchTab:(tabName)->
    @UI['item-list'].J.html ""
    self = this
    @UI['type-switch'].J.find(".tab").removeClass "active"
    switch tabName
      when "items"
        arr = @items
        @UI['item-tab'].J.addClass "active"
      when "supplies"
        arr = @supplies
        @UI['supplies-tab'].J.addClass "active"
      when "materials"
        arr = @materials
        @UI['materials-tab'].J.addClass "active"
      when "equipments"
        arr = @equipments
        @UI['equipments-tab'].J.addClass "active"
      else console.error "wrong type",tabName
    console.log arr
    return if not arr
    for thing in arr
      item = new ThingListItem thing
      item.appendTo @UI['item-list']
      item.on "select",->
        self.selectThing this
  selectThing:(w)->
    @J.find("thing-list-item").removeClass "active"
    w.J.addClass "active"
    @detailsBox.showItemDetails w.thing
  freeThings:->
    Utils.free @items,@supplies,@materials,@equipments
    @items = []
    @supplies = []
    @materials = []
    @equipments = []
  show:(callback)->
    @init()
    @initThings()
    @UILayer.fadeIn "fast",callback
    @J.slideDown "fast",->
      callback() if callback
  hide:(callback)->
    super()
    @J.slideUp "fast",->
      callback() if callback
      
