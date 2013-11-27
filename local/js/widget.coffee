#some often-use widgets hear
class window.PopupBox extends Widget
  constructor:(title,content)->
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
  show:->
    @appendTo @UILayer
    @J.fadeIn "fast"
    @box.J.show()
    @box.J.addClass "animate-popup"
  close:->
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
