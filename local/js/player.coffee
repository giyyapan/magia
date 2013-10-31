playerData =
  name:"Nola"
  lastStage:"home"
  level:1
  assert:
    money:4000
    gem:300
    packItem:[]
    storageItem:[]
    equipment:
      hat:
        id:10
      clothes:
        id:11
      belt:
        id:20
      shose:
        id:25
  ability:
    hp:300
    mp:300
    atk:20
    def:30
    spd:8
    luk:10
    
class window.Player
  constructor:(data)->
    @data = data
    @data = playerData if not data
    for name of @data
      this[name] = @data[name]
  getItems:->
    for item in arguments
      console.log "player get ",item
      
