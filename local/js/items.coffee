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
  getDate:->
    return name:@name,type:@type
      
class window.PlayerItem extends Things
  constructor:(db,name,number)->
    originData = db.things.items.get name
    super name,originData,"item"
    @number = number
    @traits = {}
    for t in originData.traits
      arr = t.split ":"
      @traits[arr[0]] = parseInt arr[1]
  getData:->
    return name:@name,type:@type,number:@number
      
class window.PlayerSupplies extends Things
  constructor:(db,name,traitValue,remainCount)->
    console.log db.things
    originData = db.things.supplies.get name
    super name,originData,"supplies"
    @remainCount = remainCount or 5
    @traitValue = traitValue
    @traitName = originData.traitName
    @traits = {}
    @traits[originData.traitName] = @traitValue
  getData:->
    return name:@name,type:@type,remainCount:@remainCount,traitValue:@traitValue
        
class window.PlayerEquipment extends Things
  constructor:(db,name)->
    originData = db.things.equipments.get name
    super name,originData,"equipment"
    @statusValue = originData.statusValue
  getData:->
    super
      
class window.GatherItem extends Things
  constructor:(name,data)->
    super name,data,"item"
  getGatherData:()->
    return true
  tryGather:(data)->
    #check condition
    return 1
