class window.DB extends Suzaku.EventEmitter
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
    @tasks = null
    @storys = null
    @initAreas()
    @initItems()
    @initRules()
  initAreas:->
    s = Utils.getSize()
    @areas.forest = 
      name:"森林"
      x:0,y:0
      subAreas:
        entry:
          bg:[Res.imgs.homeDown] #day,night
          resPoints:["1,1","20,20","30,30","50,50"] #start from 1
          movePoints:["exit","west","east"]
        east:
          bg:Res.imgs.homeDown
          resPoints:["1,1","20,80"]
          movePoints:["entry"]
        west:
          bg:Res.imgs.homeDown
          resPoints:["1,1","20,80"]
          movePoints:["entry"]
  initThings:->
    #quality 1:0-30 2:30-100 3:100-200 4:300-500 5:500-
    @things.items =
      scree:
        name:"小石子"
        img:Res.imgs.item
        traits:["earth:10"]
        gather:["forest entry.1,west.2,east.1"]
        gatherRequire:null #要求包括时间，季节，技能，等级等
      flint:
        name:"燧石"
        traits:["fire:10","earth:5"]
        gather:["forest entry.2,entry.3"]
      lakeWater:
        name:"湖水"
        traits:["water:15","heal:3"]
        gather:["forest entry.5"]
      blueRose:
        name:"蓝玫瑰"
        traits:["water:8","life:8"]
        gather:["forest entry.1"]
      herbs:
        name:"药草"
        traits:["life:16"]
        gather:["forest entry.1"]
      caveMashroom:
        name:"洞穴菇"
        traits:["water:8","life:5"]
        arttribute:["plants"]
        gather:["forest entry.1"]
    @things.supplies =
      healPotion:
        name:"治疗药剂"
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
    
