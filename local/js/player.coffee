playerData =
  name:"Nola"
  lastStage:"home"
  money:4000
  energy:50
  backpack:[
    {name:"healPotion",traitValue:300,type:"supplies"}
    {name:"firePotion",traitValue:300,type:"supplies"}
    {name:"scree",number:10,type:"item"}
    {name:"lakeWater",number:10,type:"item"}
    {name:"herbs",number:10,type:"item"}
    {name:"caveMashroom",number:10,type:"item"}
    ]
  storage:[]
  equipments:[]
  currentEquipments:
    hat:"bigginerHat"#hp
    weapon:"begginerStaff"#atk
    clothes:"bigginerRobe"#def
    shose:"bigginerShose"#spd
    other:null
  basicStatusValue:
    hp:300
    mp:300
    atk:20
    normalDef:30
    fireDef:0
    waterDef:0
    earthDef:0
    airDef:0
    spiritDef:0
    minusDef:0
    luk:0
    spd:8
    
class window.Player
  constructor:(db)->
    @db = db
    @data = Utils.localData "get","playerData"
    dataKey = Utils.localData "get","dataKey"
    if not @data or Utils.getKey(JSON.stringify(@data)) isnt parseInt(dataKey)
      @data = playerData
      @initData()
      @saveData()
    else
      @initData()
  initData:()->
    @statusValue = @data.basicData
    @money = @data.money
    @energy = @data.energy
    @lastStage = @data.lastStage
    @equipments = []
    for name in @data.equipments
      @equipments.push new PlayerEquipment @db,name
    @currentEquipments = {}
    for part,equipmentName in @data.currentEquipments 
      @currentEquipments[part] = new PlayerEquipment equipmentName
    @backpack = []
    @storage = []
    @initThingsFrom "backpack",@data.backpack
    @initThingsFrom "storage",@data.storage
    @updateStatusValue()
  updateStatusValue:->
    for name,value of @basicStatusValue
      @statusValue[name] = value
    for part,equip in @currentEquipments
      for name of @statusValue
        @statusValue[name] += equip.statusValue[name] if equip.statusValue[name]
  initThingsFrom:(originType,data)->
    switch originType
      when "backpack"
        origin = @data.backpack
        target = @backpack
      when "storage"
        origin = @data.storage
        target = @storage
    for data in origin
      switch data.type
        when "item" then @getItem target,data
        when "supplies" then @getSupplies target,data
    console.log @backpack
  removeThing:(playerItem,from)->
    if not from
      return if @removeThing playerItem,"backpack"
      return @removeThing playerItem,"storage"
    found = false
    arr = []
    switch from
      when "backpack"
        length = @backpack.length
        arr.push i for i in @backpack when playerItem isnt i
        @backpack = arr
        return arr.length isnt length
      when "storage"
        length = @storage.length
        arr.push i for i in @storage when playerItem isnt i
        @storage = arr
        return arr.length isnt length
  getItem:(target="backpack",dataObj)-> #target= backpack/storage 只有item是可堆叠的
    name = dataObj.name
    number = dataObj.number
    item = new PlayerItem @db,name,number
    switch target
      when "backpack" then target = @backpack
      when "storage" then target = @storage
    for theItem in target when theItem.type is "item" and theItem.name is item.name
      return theItem.number += 1
    target.push item
    @saveData()
    console.log this
  getSupplies:(target="backpack",data)->
    if data instanceof PlayerSupplies
      supplies = data
    else
      name = data.name
      traitValue = data.traitValue
      remainCount = data.remainCount
      supplies = new PlayerSupplies @db,name,traitValue,remainCount
    switch target
      when "backpack" then target = @backpack
      when "storage" then target = @storage
    target.push supplies
    @saveData()
    console.log this
  getEquipment:()->
  checkFreeSpace:(target,things)->
    return true
  saveData:->
    backpack = []
    for thing in @backpack
      backpack.push thing.getData()
    storage = []
    for thing in @storage
      storage.push thing.getData()
    equipments = []
    for e in @equipments
      equipments.push e.getData()
    currentEquipments = {}
    for part,equip of @currentEquipments
      currentEquipments[part] = equip.getData()
    data =
      lastStage:"home"
      money:@money
      energy:@energy
      statusValue:@basicData
      lastStage:@lastStage
      basicStatusValue:@basicStatusValue
      backpack:backpack
      storage:storage
      equipments:equipments
      currentEquipments:currentEquipments
    Utils.localData "save","playerData",data
    Utils.localData "save","dataKey",Utils.getKey(JSON.stringify(data))
