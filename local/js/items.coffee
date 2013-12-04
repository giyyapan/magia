class window.Things extends EventEmitter
  constructor:(name,data,type)->
    super()
    @originData = data
    @price = @originData.price
    @name = name
    @dspName = data.name
    @type = type
    @img = @originData.img or Res.imgs["#{type}_#{name}"]
  getData:->
    return name:@name,type:@type
      
class window.PlayerItem extends Things
  constructor:(db,name,data)->
    if not data
      data = number:1
    originData = db.things.items.get name
    super name,originData,"item"
    @number = data.number
    @traits = {}
    for t in originData.traits
      arr = t.split ":"
      @traits[arr[0]] = parseInt arr[1]
  getData:->
    return name:@name,type:@type,number:@number
      
class window.PlayerSupplies extends Things
  constructor:(db,name,data)->
    if not data.traitValue then console.error "need trait value"
    originData = db.things.supplies.get name
    super name,originData,"supplies"
    if not @img then @img = Res.imgs['supplies_icon']
    @maxRemainCount = 5
    @remainCount = data.remainCount or @maxRemainCount
    @traitValue = data.traitValue
    @traitName = originData.traitName
    @traits = {}
    @traitLevel = @_getTraitLevel db
    @traitValueLevel = @_getTraitValueLevel db
    @traits[originData.traitName] = @traitValue
    @price = @_getPrice()
  _getTraitValueLevel:(db)->
    for v,index in db.rules.get "qualityLevel"
      break if @traitValue < v
    return parseInt(index + 1)
  _getTraitLevel:(db)->
    for level,traits of db.rules.get "traitLevel"
      for name in traits.split ","
        if @traitName is name
          return parseInt level
    return 1
  _getPrice:->
    p = @traitValue * 3
    for i in [1..@traitLevel]
      p *= 1.5
    return p
  getData:->
    return name:@name,type:@type,remainCount:@remainCount,traitValue:@traitValue
        
class window.PlayerEquipment extends Things
  constructor:(db,name,data)->
    originDataStr = db.things.equipments.get name
    parts = originDataStr.split " "
    originData =
      name:name
      part:parts[0]
      price:parseInt(parts[1])
      dspName:parts[2]
      statusValue:parts[3]
    super name,originData,"equipment"
    switch originData.part
      when "h" then @part = "hat"
      when "r" then @part = "robe"
      when "s" then @part = "shose"
      when "w" then @part = "weapon"
    @initStatusValue()
  initStatusValue:()->
    @statusValue = {}
    for data in @originData.statusValue.split ","
      name = data.split(":")[0]
      value = parseInt data.split(":")[1]
      @statusValue[name] = value
    console.log "equipment",@originData.name,@statusValue,@originData.statusValue
  getData:()->
    return @originData.name
