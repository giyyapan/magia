class window.SubDB extends EventEmitter
  constructor:(name)->
    @dbName = name
    @data = {}
  get:(name)->
    if typeof @data[name] is "undefined"
      console.warn "Cannot find data name : #{name} in database #{@dbName}"
    else
      return @data[name]
  
class window.Database extends EventEmitter
  constructor:->
    @areas = new SubDB "areas"
    @towns = new SubDB "towns"
    @things = 
      items:new SubDB "things-items"
      supplies: new SubDB "things-supplies"
    @rules = new SubDB "rules"
    @monsters = new SubDB "sprites-monsters"
    @spriteItems = new SubDB "sprites-items"
    @characters = new SubDB "characters"
    @tasks = new SubDB "tasks"
    @storys = new SubDB "storys"
    @initAreas()
    @initCharacters()
    @initThings()
    @initRules()
  initAreas:->
    s = Utils.getSize()
    @areas.data =
      forest:
        name:"森林"
        costEnergy:5
        description:"这是一个森林哈哈哈哈哈"
        summaryImg:"summaryForest"
        dangerLevel:'低'
        summaryBg:'forestEntry'
        x:0,y:0
        battlefieldBg:
          bfForestMain:
            z:1000
            anchor:
              x:150
              y:0
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
        costEnergy:10
        description:"雪山里面有雪人，雪人的名字叫耶提"
        summaryImg:'summarySnow'
        dangerLevel:  "中"
        summaryBg:'snowmountainEntryBg'
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
      home:
        name:"魔女宅邸"
        description:'传说中的魔女——艾丽西亚的祖母留下的大房子。有宽敞的客厅和完善的工作设施，在这个地方应该可以尽情施展自己的才能了吧！'
        costEnergy: 0
        dangerLevel:'安全'
        summaryImg:'summaryHome'
        summaryBg:''
      shop:
        name:'绯红魔法店'
        description:'这儿没什么好东西而且都很贵，不过附近好像也就只有这个地方愿意收购魔法物品了...真是太惨了'
        costEnergy: 0
        summaryImg: 'summaryShop'
        dangerLevel:'安全'
        summaryBg:''

  initThings:->
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
        traits:["water:90","clear:3"]
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
        description:"潮湿的山洞里面才会长的蘑菇，但是却异常的有火属性"
        traits:["fire:8","life:5"]
    @things.supplies.data =
      healPotion:
        name:"治疗药剂"
        description:"有治疗效果的药剂"
        traitName:"heal"
        active:
          name:"治疗术"
          description:"回复一定数量的生命值"
          type:"heal"
          sprite:null
          heal:100
        defense:
          name:"回复结界"
          description:"制造一个结界，在受到攻击时回复生命值"
          type:"flipOver"
          sprite:"null"
          turn:5
          heal:40
        img:null
      muddyPotion:
        name:"泥泞药剂"
        description:"会让人身上变得粘糊糊的药剂，看起来就很奇怪"
        traitName:"muddy"
        active:
          name:"泥泞术"
          description:"降低敌人的行动速度"
          type:"debuff"
          sprite:null
          debuff:
            spd:"*0.8"
        defense:
          name:"泥巴护体"
          description:"生成结界，被攻击到的时候敌人会减速"
          type:"flipOver"
          sprite:"null"
          turn:5
          heal:40
        img:null
      firePotion:
        name:"火焰药剂"
        img:null
        description:"有火焰效果的药剂"
        traitName:"fire"
        active:
          name:"火球术"
          description:"释放火球对单体目标进行攻击"
          type:"attack" # area attack
          sprite:null
          damage:
            normal:80
            fire:100
        defense:
          name:"火焰陷阱"
          description:"使用火焰包围身体，在受到攻击时对敌人造成火焰伤害"
          type:"flipOver"
          turn:5
          damage:
            fire:80
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
          
