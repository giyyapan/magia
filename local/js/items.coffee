class window.Things extends EventEmitter
  constructor:(name,data,type)->
    super()
    @originData = data
    @price = @originData.price
    @name = name
    @dspName = data.name
    @type = type
    @img = @originData.img or Res.imgs["#{type}_#{name}"]
  getDate:->
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
    @traitLevel = @_getTraitLevel()
    @traits[originData.traitName] = @traitValue
    @price = @_getPrice()
  _getTraitLevel:->
    for level,traits of Dict.TraitLevel
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
    originData = db.things.equipments.get name
    super name,originData,"equipment"
    @statusValue = originData.statusValue
  getData:->
    super
