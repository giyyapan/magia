class SubDB extends Suzaku.EventEmitter
  constructor:(name)->
    @dbName = name
    @data = {}
  get:(name)->
    if typeof @data[name] is "undefined"
      console.error "Cannot find data name : #{name} in database #{@dbName}"
    else
      return @data[name]
  
class window.Database extends Suzaku.EventEmitter
  constructor:->
    @areas = new SubDB "areas"
    @towns = new SubDB "towns"
    @things = 
      items:new SubDB "things-items"
      materials:new SubDB "things-meterials"
      supplies: new SubDB "things-supplies"
    @rules = new SubDB "rules"
    #rules.reaction:[]
    #rules.combination:[]
    @monsters = new SubDB "sprites-monsters"
    @spriteItems = new SubDB "sprites-items"
    @tasks = new SubDB "tasks"
    @storys = new SubDB "storys"
    @initAreas()
    @initThings()
    @initRules()
    @initSprites()
  initAreas:->
    s = Utils.getSize()
    @areas.data =
      forest:
        name:"森林"
        x:0,y:0
        battlefieldBg:
          bfForestMain:
            z:1000
            main:true
          bfForestFloat:
            z:1
            fixToBottom:true
        places:
          entry:
            defaultX:300
            name:"森林入口"
            bg:
              forestEntry:
                z:1000
            floatBg:
              forestEntryFloat1:
                z:600
                y:-50
                scale:1.05
              forestEntryFloat2:
                z:1
                x:300
                scale:2
                fixToBottom:true
            resPoints:["0,80","400,500","800,300","1000,300"] #start from 1
            resources:[ #每个对应一个资源点
              "scree"
              "scree,flint"
              "lakeWater"
              "herbs,mouseTailHerbs"
              "caveMashroom"]
            monsters:
              certain:['1:qq,qq,qq']
              random:['2:qq','3:qq']
            movePoints:["exit","west","east"]
          east:
            name:"东部森林"
            bg:
              forest2:
                z:1000
            resPoints:["1,1","20,80"]
            movePoints:["entry"]
          west:
            name:"西部森林"
            bg:
              forest3:
                z:1000
            resPoints:["1,1","20,80"]
            movePoints:["entry"]
      snowmountain:
        name:"雪山"
        x:0,y:0
        places:
          entry:
            name:"雪山山顶"
            bg:
              snowmountainEntryMain:
                z:1000
              snowmountainEntryBg:
                z:10000
            floatBg:
              snowmountainEntryFloat:
                z:300
                x:200
                fixToBottom:true
            resPoints:["0,80","400,500","800,300","1000,300"] #start from 1
            resources:[ #每个对应一个资源点
              "scree"
              "scree,flint"
              "lakeWater"
              "herbs,mouseTailHerbs"
              "caveMashroom"
              ]
            monsters:
              certain:['1:qq,qq,qq']
              random:['2:qq','3:qq']
            movePoints:["exit","west","east"]
          east:
            name:"东部雪山"
            bg:
              snowmountainEntryMain:
                z:1000
              snowmountainEntryBg:
                fixed:true
            floatBg:
              snowountainEntryFloat:
                z:600
                x:200
                fixToBottom:true
            resPoints:["1,1","20,80"]
            movePoints:["entry"]
          west:
            name:"西部雪山"
            bg:["forest3"]
            resPoints:["1,1","20,80"]
            movePoints:["entry"]
  initThings:->
    #quality 1:0-30 2:30-100 3:100-200 4:300-500 5:500-
    @things.qualityLevel = [30,100,300,600,1000,2000]
    @things.items.data = 
      scree:
        name:"小石子"
        img:Res.imgs.item
        description:"随处可见的石头，但是要采集的话还是得去森林吧"
        traits:["earth:10"]
        gatherRequire:null #要求包括时间，季节，技能，等级等
      flint:
        name:"燧石"
        description:"可以打火的石头，能够感受到微弱的火属性魔力"
        traits:["fire:10","earth:5"]
      lakeWater:
        name:"湖水"
        description:"清澈的湖水，含有少量净化所需的元素"
        traits:["water:15","clear:3"]
      blueRose:
        name:"蓝玫瑰"
        description:"蓝色的玫瑰，在森林里的背光面会长。得小心它的刺"
        traits:["water:8","life:8"]
      herbs:
        name:"药草"
        description:"有治疗效果的药草，很多药物里都有它的成分"
        traits:["life:16"]
      mouseTailHerbs:
        name:"鼠尾草"
        description:"长在路边很常见的一种小草，为什么叫鼠尾草而不叫狗尾草呢？这还真是奇怪啊，据说晚上会有闪光的鼠尾草出现…"
        traits:["life:5","earth:20"]
      caveMashroom:
        name:"洞穴菇"
        description:"潮湿的山洞里面才会长的蘑菇，随便吃掉的话会中毒"
        traits:["poinson:8","life:5"]
        arttribute:["plants"]
    @things.supplies.data =
      healPotion:
        name:"治疗药剂"
        description:"有治疗效果的药剂"
        img:null
      firePotion:
        name:"火焰药剂"
        img:null
    @things.materials.data =
      magicLiquid:
        name:"魔法溶液"
      magicPowder:
        name:"魔法粉尘"
  initRules:->
    @rules.data.reaction =
      {from:["fire:5"],to:"",cond:[]}
  initSprites:->
    @monsters.data =
      qq:
        name:"QQ"
        sprite:Res.sprites.test
        basicData:
          hp:1000
          def:30
          attack:
            damage:
              normal:30
              water:10
          magic:
            waterball:
              turn:2
              damage:
                water:100
        anchor:"321,398"
        movements:
          normal:"0,8"
          move:"0,8"
          #attack:"0,8:5"
          attack:"0,8"
          cast:"0,8"
        drop:
          certain:["bluerose"]
          random:null
    @spriteItems.data =
      waterball:
        name:"水球术"
        movements:
          normal:""
          active:""
          
