// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.MissionsDB = (function(_super) {
    __extends(MissionsDB, _super);

    function MissionsDB() {
      MissionsDB.__super__.constructor.call(this, "missions");
      this.data = {
        theGuild: {
          name: "冒险者公会",
          from: null,
          autoComplete: true,
          description: "（在森林救了我们的大叔好像自称是冒险者公会的管理员？虽然不知道那是什么玩意，但是还是先去看看再说吧～）",
          catHint: "",
          end: {
            story: "theGuild"
          },
          start: {
            unlockarea: "guild"
          },
          requests: {
            visit: "guild"
          }
        },
        firstMission: {
          after: "theGuild",
          name: "作为冒险者出道！",
          from: "dirak",
          description: "想让村里的各位愿意和你交流，首先要证明自己！|用雾之森的外围的素材制作一些药剂看看吧！让我们知道你是个真正的魔法师！",
          catHint: "",
          start: {
            unlockarea: "forest",
            story: "firstMission"
          },
          end: {
            story: "firstMissionComplete"
          },
          reward: {
            money: 100
          },
          requests: {
            get: "firePotion,muddyPotion"
          }
        },
        luna1: {
          name: "魔法物品店老板娘？",
          from: "luna",
          description: "哎呀，你就是那个新来的魔女吧～？|我是在镇上开店的露娜～来我的店里看看",
          after: "firstMission",
          start: {
            unlockarea: "magicItemShop"
          },
          requests: {
            visit: "magicItemShop",
            text: "到露娜的商店里去拜会她"
          },
          reward: {
            money: 50
          },
          end: {
            story: "meetLuna"
          },
          autoComplete: true,
          catHint: ""
        },
        luna2: {
          after: "luna1",
          name: "药剂是需要素材的！",
          from: "luna",
          description: "最近史莱姆泛滥，搞得货车进不来，我的货源也没法保证了。本来这些家伙是很弱的怪物，可是大家都觉得它们粘粘的太恶心，没一个愿意清理的，你想办法帮帮我吧～|放心，虽然说是帮忙，但是我会付给你报酬的！",
          requests: {
            kill: "qq*2"
          },
          reward: {
            money: 200
          }
        }
      };
    }

    return MissionsDB;

  })(SubDB);

}).call(this);
