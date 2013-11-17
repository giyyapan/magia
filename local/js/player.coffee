playerData =
  name:"Nola"
  lastStage:"home"
  level:1
  assert:
    money:4000
    gem:300
    backpack:[{name:"healPotion",traitValue:300,type:"supplies"},{name:"firePotion",traitValue:300,type:"supplies"}]
    storage:[]
    currentEquipment:
      hat:null
      clothes:null
      belt:null
      shose:null
  ability:
    hp:300
    mp:300
    atk:20
    def:30
    spd:8
    luk:10
    
class window.Player
  constructor:(data,db)->
    @db = db
    @data = data
    @data = playerData if not data
    @backpack = []
    @storage = []
    @initData()
    for name of @data
      this[name] = @data[name]
  initData:()->
    @initThingsFrom "backpack",@data.assert.backpack
    @initThingsFrom "storage",@data.assert.storage
  initThingsFrom:(originType,data)->
    switch originType
      when "backpack"
        origin = @data.assert.backpack
        target = @backpack
      when "storage"
        origin = @data.assert.storage
        target = @storage
    for data in origin
      switch data.type
        when "item" then @getItem target,data
        when "supplies" then @getSupplies target,data
    console.log @backpack
  getItem:(target="backpack",dataObj)-> #target= backpack/storage 只有item是可堆叠的
    name = dataObj.name
    originData = dataObj.originData or @db.things.items.get name
    number = dataObj.number
    item = new PlayerItem(name,originData,number)
    switch target
      when "backpack" then target = @backpack
      when "storage" then target = @storage
    for theItem in target when theItem.type is "item" and theItem.name is item.name
      return theItem.number += 1
    target.push item
    console.log this
  getSupplies:(target="backpack",dataObj)->
    name = dataObj.name
    originData = dataObj.originData or @db.things.supplies.get name
    item = new PlayerItem(name,originData)
    switch target
      when "backpack" then target = @backpack
      when "storage" then target = @storage
    target.push item
    console.log this
  getEquipment:()->
  checkFreeSpace:(target,things)->
    return true
  saveData:->
      
