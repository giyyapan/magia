class window.SubDB extends Suzaku.EventEmitter
  constructor:(name)->
    @dbName = name
    @data = {}
  get:(name)->
    if typeof @data[name] is "undefined"
      console.warn "Cannot find data name : #{name} in database #{@dbName}"
    else
      return @data[name]
  
class window.Database extends Suzaku.EventEmitter
  constructor:->
    @areas = new AreasDB()
    @things = new ThingsDB()
    console.log @things
    @rules = new SubDB "rules"
    @monsters = new SubDB "sprites-monsters"
    @spriteItems = new SubDB "sprites-items"
    @characters = new SubDB "characters"
    @tasks = new SubDB "tasks"
    @storys = new SubDB "storys"
    @initCharacters()
    @initSprites()
    @initRules()
  initRules:->
    @rules.data.reaction = [
      "fire:2,air:1->burn"
      "burn:3,fire:2,air:1->explode"
      "fire:1,earth:2->iron"
      "water:1,earth:1->muddy"
      "water:2,fire:1,air:1->fog"
      "cold:2,air:2->freeze"
      "freeze:2,water:2,air:2->snow"
      "life:2,earth:1->heal"
      "life:2,water:1->clean"
      "life:2,fire:1->brave"
      "iron:3,minus:2->corrosion"#腐蚀
      "life:3,spirit:2,air:2->boost"
      "minus:2,life:2->poison"
    ]
  initCharacters:->
    @characters.data =
      player:
        name:"艾丽西亚"
        dialogPic:""
      cat:
        name:"琪琪"
        dialogPic:""
  initSprites:->
    @monsters.data =
      qq:
        name:"QQ"
        sprite:Res.sprites.qq
        icon:null
        statusValue:
          hp:1000
          def:30
          spd:30
        skills:
          attack:
            damage:
              normal:30
              water:10
          waterball:
            turn:2
            damage:
              water:100
        anchor:"270,240"
        movements:
          normal:"0,6"
          move:"7,15"
          attack:"16,23:4,6"
          cast:"0,6"
        drop:
          certain:["bluerose"]
          random:null
    @spriteItems.data =
      waterball:
        name:"水球术"
        movements:
          normal:""
          active:""
          
