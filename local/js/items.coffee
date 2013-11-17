class window.ThingListWidget extends Widget
  constructor:(originData,number)->
    super Res.tpls['thing-list-item']
    @UI.img.src = originData.img.src if originData.img
    @UI.name.J.text originData.name
    @UI.quatity.J.text number
    
class window.Things extends EventEmitter
  constructor:(name,data,type)->
    super()
    @originData = data
    @name = name
    @dspName = data.name
    @type = type
    if data.img
      @img = Res.imgs[data.img]
    else
      @img = null
      
class window.PlayerItem extends Things
  constructor:(name,originData,number)->
    super name,originData,"item"
    @number = number
    
class window.PlayerSupplies extends Things
  constructor:(name,originData,traitValue)->
    super name,data,"supplies"
    @traitValue = traitValue
    
class window.PlayerEquipment extends Things
  constructor:->
      
class window.GatherItem extends Things
  constructor:(name,data)->
    super name,data,"item"
  getGatherData:()->
    return true
  tryGather:(data)->
    #check condition
    return 1
