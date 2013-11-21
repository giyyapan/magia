class window.TraitsItem extends Widget
  constructor:(name,value)->
    super Res.tpls['traits-item']
    @traitsName = name
    @traitsValue = value
    @lv = 1
    @UI.name.J.text Dict.TraitsName[@traitsName]
    @UI.name.J.addClass @traitsName
    @changeValue @traitsValue
  changeValue:(value)->
    @traitsValue = value
    levelData = Dict.QualityLevel
    for v,index in levelData
      break if value < v
    @lv = parseInt(index + 1)
    @UI['traits-holder'].J.removeClass "lv1","lv2","lv3","lv4","lv5","lv6"
    @UI['traits-holder'].J.addClass "lv#{@lv}"
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
    @UI['content'].J.hide()
    @currentItem.J.removeClass "selected" if @currentItem
    @currentItem = item
    item.J.addClass "selected"
    @UI.name.J.text item.originData.name
    @UI.img.src = item.originData.img.src if item.originData.img
    @UI.description.J.text item.originData.description
    @initTraits item.playerItem
    @J.fadeIn "fast"
    @UI['content'].J.fadeIn 100
  initTraits:(itemData)->
    return if not itemData.traits
    @UI['traits-list'].J.html ""
    for name,value of itemData.traits
      new TraitsItem(name,value).appendTo @UI['traits-list']
