testPlayerData = 
  name:"Nola"
  lastStage:"home"
  money:4000
  energy:50
  backpack:[
    {name:"healPotion",traitValue:30,type:"supplies"}
    {name:"firePotion",traitValue:50,type:"supplies"}
    {name:"firePotion",traitValue:100,type:"supplies"}
    {name:"fogPotion",traitValue:30,type:"supplies"}
    {name:"corrosionPotion",traitValue:100,type:"supplies"}
    {name:"burnPotion",traitValue:30,type:"supplies"}
    {name:"ironPotion",traitValue:30,type:"supplies"}
    {name:"explodePotion",traitValue:50,type:"supplies"}
    {name:"muddyPotion",traitValue:50,type:"supplies"}
    {name:"bravePotion",traitValue:50,type:"supplies"}
    {name:"stunPotion",traitValue:50,type:"supplies"}
    {name:"earthLow",number:10,type:"item"}
    {name:"earthMid",number:10,type:"item"}
    {name:"lifeLow",number:10,type:"item"}
    {name:"iceLow",number:10,type:"item"}
    {name:"waterLow",number:10,type:"item"}
    {name:"fireLow",number:10,type:"item"}
    {name:"fireMid",number:10,type:"item"}
    {name:"minusLow",number:10,type:"item"}
    {name:"spiritLow",number:10,type:"item"}
    {name:"iceMid",number:10,type:"item"}
    {name:"iceHigh",number:10,type:"item"}
    {name:"timeLow",number:10,type:"item"}
    {name:"spaceLow",number:10,type:"item"}
    ]
  unlockedAreas:
    all:true
  missions:
    current:{}
    completed:{}#completed but not reported
    finished:{}#completed and areported
  storys:
    current:null
    completed:{}
  relationships:
    luna:0
    dirak:0
    nataria:0
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
    precision:95
    resistance:10
    spd:40

playerData =
  name:"Nola"
  lastStage:"home"
  money:0
  energy:30
  backpack:[]
  missions:
    current:{}
    completed:{}#completed but not reported
    finished:{}#completed and areported
  storys:
    current:null
    completed:{}
  relationships:
    luna:0
    dirak:0
    nataria:0
  unlockedAreas:{}
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
    precision:95
    resistance:10
    spd:40

class window.Player extends EventEmitter
  constructor:(db)->
    super null
    @saveLock = true
    @db = db
    if not @loadData()
      @newData()
    @maxEnergy = 30
    @energy = @maxEnergy
    @saveLock = false
    window.fuckmylife = =>
      @newData testPlayerData
    window.fuckmylife()
  loadData:->
    dataKey = Utils.localData "get","dataKey"
    data = Utils.localData "get","playerData"
    console.log "load data",data
    if not data or Utils.getKey(JSON.stringify(data)) isnt parseInt(dataKey)
      return false
    @data = data
    try
      @initData()
    catch err
      @newData()
    return true
  newData:(data)->
    @data = data or playerData
    console.log "new data",@data
    @initData()
    return true
  initData:()->
    @money = @data.money
    @energy = @data.energy
    @relationships = @data.relationships
    @unlockedAreas = @data.unlockedAreas
    @lastStage = @data.lastStage
    @storys = @data.storys
    @missions = @data.missions
    @equipments = []
    for name in @data.equipments
      @equipments.push new PlayerEquipment @db,name
    @currentEquipments = {}
    for part,equipmentName in @data.currentEquipments 
      @currentEquipments[part] = new PlayerEquipment equipmentName
    @backpack = []
    @storage = []
    @initThingsFrom "backpack"
    @initThingsFrom "storage"
    @updateStatusValue()
    @hp = @statusValue.hp
  updateStatusValue:->
    @basicStatusValue = @data.basicStatusValue
    @statusValue = {}
    for name,value of @basicStatusValue
      @statusValue[name] = value
    for part,equip in @currentEquipments
      for name of @statusValue
        @statusValue[name] += equip.statusValue[name] if equip.statusValue[name]
  initThingsFrom:(originType)->
    switch originType
      when "backpack"
        origin = @data.backpack
        target = @backpack
      when "storage"
        origin = @data.storage
        target = @storage
    for itemData in origin
      switch itemData.type
        when "item" then @getItem target,itemData
        when "supplies" then @getSupplies target,itemData
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
  hasThing:(name)->
    number = 0
    for thing in @backpack
      if thing.name is name then number += (thing.number or 1)
    for thing in @storage
      if thing.name is name then number += (thing.number or 1)
    return number
  getItem:(target="backpack",dataObj)-> #target= backpack/storage 只有item是可堆叠的
    if dataObj instanceof PlayerItem
      item = dataObj
    else
      name = dataObj.name
      number = dataObj.number
      item = new PlayerItem @db,name,number:number
    switch target
      when "backpack" then target = @backpack
      when "storage" then target = @storage
    for theItem in target when theItem.type is "item" and theItem.name is item.name
      return theItem.number += 1
    target.push item
    @emit "getThing","item",item
    @saveData()
  getSupplies:(target="backpack",data)->
    if data instanceof PlayerSupplies
      supplies = data
    else
      name = data.name
      supplies = new PlayerSupplies @db,name,data
    switch target
      when "backpack" then target = @backpack
      when "storage" then target = @storage
    target.push supplies
    @emit "getThing","supplies",supplies
    @saveData()
  getEquipment:()->
    @emit "getThing","equipment",supplies
  saveData:->
    return if @saveLock
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
      storys:@storys
      missions:@missions
      unlockedAreas:@unlockedAreas
      basicStatusValue:@basicStatusValue
      relationships:@relationships
      backpack:backpack
      storage:storage
      equipments:equipments
      currentEquipments:currentEquipments
    Utils.localData "save","playerData",data
    Utils.localData "save","dataKey",Utils.getKey(JSON.stringify(data))
    return true
