class window.ThingListWidget extends Suzaku.Widget
  constructor:(originData,number)->
    super Res.tpls['thing-list-item']
    @UI.img.src = originData.img.src if originData.img
    @UI.name.J.text originData.name
    @UI.quatity.J.text number
    
class window.Things extends Suzaku.EventEmitter
  constructor:(name,data,type)->
    super()
    @data = @originData = data
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
  constructor:(name,originData,specificData)->
    super name,data,"supplies"
    @specificData = specificData
    
class window.PlayerMaterial extends Things
  constructor:(name,originData,specificData)->
    super name,data,"material"
    @specificData = specificData
    
class window.PlayerEquipment extends Things
  constructor:->
      
class window.GatherItem extends Things
  constructor:(name,data)->
    super name,data,"item"
  getGatherDataByPlace:(area,place)->
    for gatherData in @data.gather
      arr = gatherData.split " "
      theArea = arr[0]
      continue if theArea isnt area
      for placeGatherData in arr[1].split(",")
        arr2 = placeGatherData.split(".")
        continue if arr2[0] isnt place
        return resPoint:parseInt(arr2[1])
    return false
  tryGather:(data)->
    #check condition
    return 1
