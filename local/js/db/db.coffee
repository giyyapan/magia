class window.SubDB extends Suzaku.EventEmitter
  constructor:(name)->
    @dbName = name
    @data = {}
  getAll:->
    return @data
  get:(name)->
    if typeof @data[name] is "undefined"
      console.warn "Cannot find data name : #{name} in database #{@dbName}"
    else
      return @data[name]
  
class window.Database extends Suzaku.EventEmitter
  constructor:->
    @areas = new AreasDB()
    @things = new ThingsDB()
    @shops = new ShopsDB()
    @missions = new MissionsDB()
    @rules = new SubDB "rules"
    @monsters = new SubDB "sprites-monsters"
    @spriteItems = new SubDB "sprites-items"
    @characters = new SubDB "characters"
    for name of ["AreasDB","ThingsDB","MissionsDB","ShopsDB"]
      delete window[name]
    @initCharacters()
    @initSprites()
    @initRules()
  initRules:->
    @rules.data.reaction = [
      "fire:2,air:1->burn" #点燃
      "burn:3,fire:2,air:1->explode" #爆炸
      "fire:1,earth:2->iron" #钢
      "water:1,earth:1->muddy" #泥泞
      "water:2,fire:1,air:1->fog" #
      "ice:2,water:2,air:2->snow"
      "life:2,earth:1->heal"
      "life:2,water:1->clean"
      "life:2,fire:1->brave"
      "iron:3,minus:2->corrosion"#腐蚀
      "life:3,spirit:2,air:2->boost"
      "minus:2,life:2->poison"
      "spirit:3,poison:2->stun"
    ]
    @rules.data.qualityLevel = [30,100,200,300,500,800]
  initCharacters:->
    @characters.data =
      nobody:
        name:""
        dialogPic:""
      player:
        name:"艾丽西亚"
        dialogPic:"playerDialog"
      cat:
        description:""
        name:"奇奇"
        dialogPic:"catDialog"
      luna:
        name:"露娜"
        description:"绯红魔法店的掌柜"
        dialogPic:"lunaDialog"
      lilith:
        name:"莉莉丝"
        description:"奇迹裁缝的掌柜"
        dialogPic:"lilithDialog"
      dirak:
        name:"狄拉克"
        description:"冒险者公会的管理员"
        dialogPic:"diracDialog"
  initSprites:->
    @monsters.data =
      qq:
        name:"企鹅"
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
          certain:[]
          random:null
      pig:
        name:"布塔猪"
        sprite:Res.sprites.pig
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
        anchor:"180,240"
        movements:
          normal:"0,0"
          move:"0,7"
          attack:"8,16:11"
          onattack:"17,17"
          cast:"0,6"
        drop:
          certain:[]
          random:null
      slime:
        name:"史莱姆"
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
          
