class window.Database extends Suzaku.EventEmitter
  constructor:->
    @areas = {}
    @towns = {}
    @things =
      items:{}
      materials:{}
      supplies:{}
    @rules =
      reaction:[]
      combination:[]
    @sprites =
      characters:[]
      items:[]
    @tasks = null
    @storys = null
    @initAreas()
    @initThings()
    @initRules()
    @initSprites()
  initAreas:->
    s = Utils.getSize()
    @areas.forest = 
      name:"森林"
      x:0,y:0
      places:
        entry:
          name:"森林入口"
          bg:["forestEntry","forestEntryFloat","forestEntryFloat2"] #day,night
          resPoints:["1,1","20,20","30,30","50,50"] #start from 1
          movePoints:["exit","west","east"]
        east:
          name:"东部森林"
          bg:["forest2"]
          resPoints:["1,1","20,80"]
          movePoints:["entry"]
        west:
          name:"西部森林"
          bg:["forest3"]
          resPoints:["1,1","20,80"]
          movePoints:["entry"]
  initThings:->
    #quality 1:0-30 2:30-100 3:100-200 4:300-500 5:500-
    @things.qualityLevel = [30,100,300,600,1000,2000]
    @things.items =
      scree:
        name:"小石子"
        img:Res.imgs.item
        description:"随处可见的石头，但是要采集的话还是得去森林吧"
        traits:["earth:10"]
        gather:["forest entry.1,west.2,east.1"]
        gatherRequire:null #要求包括时间，季节，技能，等级等
      flint:
        name:"燧石"
        description:"可以打火的石头，能够感受到微弱的火属性魔力"
        traits:["fire:10","earth:5"]
        gather:["forest entry.2,entry.3"]
      lakeWater:
        name:"湖水"
        description:"清澈的湖水，含有少量净化所需的元素"
        traits:["water:15","clear:3"]
        gather:["forest entry.3"]
      blueRose:
        name:"蓝玫瑰"
        description:"蓝色的玫瑰，在森林里的背光面会长。得小心它的刺"
        traits:["water:8","life:8"]
        gather:["forest entry.1"]
      herbs:
        name:"药草"
        description:"有治疗效果的药草，很多药物里都有它的成分"
        traits:["life:16"]
        gather:["forest entry.1"]
      mouseTailHerbs:
        name:"鼠尾草"
        description:"长在路边很常见的一种小草，为什么叫鼠尾草而不叫狗尾草呢？这还真是奇怪啊，据说晚上会有闪光的鼠尾草出现…"
        traits:["life:5","earth:20"]
        gather:["forest entry.1"]
      caveMashroom:
        name:"洞穴菇"
        description:"潮湿的山洞里面才会长的蘑菇，随便吃掉的话会中毒"
        traits:["poinson:8","life:5"]
        arttribute:["plants"]
        gather:["forest entry.1"]
    @things.supplies =
      healPotion:
        name:"治疗药剂"
        description:"有治疗效果的药剂"
        img:null
      firePotion:
        name:"火焰药剂"
        img:null
    @things.materials =
      magicLiquid:
        name:"魔法溶液"
      magicPowder:
        name:"魔法粉尘"
  initRules:->
    @rules.reaction =
      {from:["fire:5"],to:"",cond:[]}
  initSprites:->
    @sprites.characters =
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
        anchor:"100,100"
        movements:
          normal:"0,8"
          move:"0,8"
          #attack:"0,8:5"
          attack:"0,8"
          cast:"0,8"
        drop:
          certain:["bluerose"]
          random:null
    @sprites.items =
      waterball:
        name:"水球术"
        movements:
          normal:""
          active:""
          
