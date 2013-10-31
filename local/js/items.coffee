class window.Things extends Suzaku.EventEmitter
  constructor:(name,data)->
    super
    @data = data
    @name = name
    @dspName = data.name
    if data.img
      @img = Res.imgs[data.img]
    else
      @img = null
      
class window.GatherItem extends Things
  constructor:(name,data)->
    super name,data
  getGatherDataByPlace:(area,place)->
    for gatherData in itemData.gather
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
    return true
