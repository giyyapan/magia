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
    @sprites = new SpritesDB()
    @monsters = new MonstersDB()
    @rules = new SubDB "rules"
    @characters = new SubDB "characters"
    for name of ["AreasDB","ThingsDB","MissionsDB","ShopsDB"]
      delete window[name]
    @initCharacters()
    @initRules()
  initRules:->
    @rules.data.reaction = [
      "fire:2,air:1->burn" #点燃
      "burn:3,fire:2,air:1->explode" #爆炸
      "fire:1,earth:2->iron" #钢
      "water:1,earth:1->muddy" #泥泞
      "water:2,fire:1,air:1->fog" #
      "ice:2,water:2,air:2->snow"
      "life:1,earth:1->heal"
      "life:2,water:1->clean"
      "life:2,fire:1->brave"
      "iron:3,minus:2->corrosion"#腐蚀
      "life:3,spirit:2,air:2->boost"
      "minus:2,life:2->poison"
      "spirit:3,poison:2->stun"
    ]
    arr = Utils.clone Dict.QualityLevel
    @rules.data.qualityLevel = arr
  initCharacters:->
    @characters.data =
      nobody:
        name:""
        dialogPic:""
      player:
        name:"艾丽西亚"
        dialogPic:"playerDialog"
      cat:
        name:"奇奇"
        dialogPic:"catDialog"
      luna:
        name:"露娜"
        description:"绯红魔法店的掌柜"
        dialogPic:"lunaDialog"
      nataria:
        name:"娜塔莉娅"
        description:"奇迹裁缝的掌柜"
        dialogPic:"natariDialog"
      dirak:
        name:"狄拉克"
        description:"冒险者公会的管理员"
        dialogPic:"dirakDialog"
          
