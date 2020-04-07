using UnityEngine;
using System;
using System.Reflection;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.Assertions;
// using System.Random;

namespace LuaFramework {
    public enum ChannelType {
        [ChannelType("王炸捕鱼测试", "wzby",  "wxb770ef68e2cf9c18", "5c24a2e2f1f5569d14000052", "3", "192.168.31.200/website", baseCode:"fishing", IsOnline:false)]
        TEST,
        [ChannelType("拇指捕鱼测试", "muzhipai",  "wxf8a883c97f1e2ab0", "5c9b6ecf3fc195c420000b61", "6", "192.168.31.200/website", baseCode:"muzhi", IsOnline:false)]
        TEST_MZBY,
        [ChannelType("3D捕鱼",       "3dby",  "wx82955ae4a8c005be", "5d3813494ca357f8040000df", "9", "192.168.31.200/website", baseCode:"fishing3d", IsOnline:false)]
        TDBY,
        [ChannelType("王炸捕鱼",     "wzby",  "wxb770ef68e2cf9c18", "5c24a2e2f1f5569d14000052", "3", "119.23.111.34/fishing")]
        WZBY,
        [ChannelType("拇指千炮捕鱼", "muzhipai",  "wxf8a883c97f1e2ab0", "5c9b6ecf3fc195c420000b61", "6", "47.112.196.143/muzhi")]
        MZBY,
        [ChannelType("夺宝捕鱼",     "dbby",  "wx82955ae4a8c005be", "5ce8c0243fc195bf180012da", "7", "47.112.196.143/zhenren", companyName:"zxq")]
        DBBY,
        [ChannelType("巅峰捕鱼",     "dfby",  "wxd995eb3fd0402ea4", "5d3813494ca357f8040000df", "8", "119.23.111.34/dianfengfishing")]
        DFBY,
        [ChannelType("巅峰捕鱼测试",  "dfby",  "wxd995eb3fd0402ea4", "5d3813494ca357f8040000df", "8", "192.168.31.200/website", baseCode:"dianfengfishing", IsOnline:false)]
        TEST_DFBY,
        [ChannelType("疯狂捕鱼",     "fkby",  "wxff56ce5dfe6a9842", "5e1052eacb23d2c9bb00018f", "10", "game.thumbgames.cn/fengkuang")]//http://game.thumbgames.cn/fengkuang/platform/fengkuang/checkVersion.php?server=10&sid=1&gid=1
        FKBY,
    }

    public class ChannelTypeAttribute : Attribute {
        public string ShowName;
        public string CompanyName;
        public string ShortName;
        public string BundleId;
        public string ChannelFolder;
        public string WXAppId;
        public string UMengAppKey;
        public string ServerId;
        public string BaseUrl;
        public string BaseCode;
        public string HotFixUrl;
        public string CheckUrl;
        public bool IsOnline;
        public ChannelTypeAttribute(
            string showName, 
            string shortName,
            string wxAppId, 
            string umengAppKey,
            string serverId,
            string baseUrl,
            string baseCode    = null,
            string companyName = "thumbp",
            bool   IsOnline    = true
        ) {
            
            this.ShowName    = showName;
            this.ShortName   = shortName;
            this.WXAppId     = wxAppId;
            this.UMengAppKey = umengAppKey;
            this.CompanyName = companyName;
            this.ServerId    = serverId;

            this.BundleId      = string.Format("{0}.{1}.{2}", "com", companyName, shortName);
            this.ChannelFolder = string.Format("{0}/{1}/", "ChannelSwitch", shortName.ToUpper());

            baseUrl        = string.Format("{0}{1}", "http://", baseUrl);
            baseCode       = baseCode != null ? baseCode : baseUrl.Substring(baseUrl.LastIndexOf("/") + 1);
            this.BaseUrl   = baseUrl;
            this.BaseCode  = baseCode;
            this.IsOnline  = IsOnline;
            this.HotFixUrl = string.Format("{0}/{1}", baseUrl, "cdn/update/fishing/update{0}/{1}/");
            this.CheckUrl  = string.Format("{0}/{1}/{2}/{3}{4}", baseUrl, "platform", baseCode, "checkVersion.php?", IsOnline ? "" : "demo=1");
        }

        public ChannelTypeAttribute(string a, string b) {

        }

    }
    public enum SidConfig {
        [SidConfig(1, "内网测试")]
        TEST,
        [SidConfig(999, "主包")]
        MAIN,
        [SidConfig(1000, "闲玩")]
        XW,
        [SidConfig(1001, "米赚")]
        MZ,
        [SidConfig(1002, "手游赚")]
        SYZ,
        [SidConfig(1003, "掌赚宝")]
        ZZB,
        [SidConfig(1004, "PC蛋蛋移动")]
        PCDD_M,
        [SidConfig(1005, "PC蛋蛋PC")]
        PCDD_P,
        [SidConfig(1006, "聚聚玩")]
        JJW,
        [SidConfig(1007, "赚客")]
        ZK,
        [SidConfig(1008, "蛋蛋赚-安卓")]
        DDZ,
        [SidConfig(1009, "聚享游")]
        JXY,
        [SidConfig(1010, "聚享玩")]
        JXW,
        [SidConfig(1011, "点财")]
        DC,
        [SidConfig(1012, "蹦蹦网PC")]
        BBW_PC,
        [SidConfig(1013, "蹦蹦网移动")]
        BBW_M,
        [SidConfig(1014, "有乐")]
        YL,
        [SidConfig(1015, "券妈妈")]
        QMM,
        [SidConfig(1016, "每日赚点")]
        MRZD,
        [SidConfig(1017, "小啄科技")]
        XZKJ,
        [SidConfig(1018, "石头村")]
        STC,
        [SidConfig(1019, "橙赚")]
        CZ,
        [SidConfig(1020, "葫芦赚")]
        HLZ,
        [SidConfig(1021, "天天赚")]
        TTZ_PC,
        [SidConfig(1022, "乐快赚")]
        LKZ,
        [SidConfig(1023, "泡泡赚")]
        PPZ,
        [SidConfig(1024, "有福了")]
        YFL,
        [SidConfig(1025, "麦子赚")]
        MZZ,
        [SidConfig(1027, "叮当赚")]
        DINGDZ,
        [SidConfig(1028, "豆豆趣玩")]
        DDQW,
        [SidConfig(1029, "友赚")]
        YZ,
        [SidConfig(1030, "嘻趣")]
        XQ,
        [SidConfig(2000, "高贵的iOS")]
        APPLE,
        [SidConfig(2001, "原生的iOS")]
        APPLE_OFFICIAL, 
        [SidConfig(2010, "蛋蛋赚iOS")]
        APPLE_DDZ,
        [SidConfig(2011, "蹦蹦网iOS")]
        APPLE_BBW,
        [SidConfig(3000, "OPPO", "com.thumbp.hlzrby.nearme.gamecenter", "ChannelSwitch/OPPO")]
        OPPO,
        [SidConfig(3001, "VIVO", "com.thumbp.hlzrby.vivo", "ChannelSwitch/VIVO")]
        VIVO,
        [SidConfig(3100, "皮皮捕鱼机")]
        PPBYJ,
    };
    public class SidConfigAttribute : Attribute {
        public string Name;
        public int Sid;
        public string BundleId;
        public string ChannelFolder;
        public SidConfigAttribute(int sid, string name, string bundleId = "", string channelFolder = "") {
            this.Name          = name;
            this.Sid           = sid;
            this.BundleId      = bundleId;
            this.ChannelFolder = channelFolder;
        }
    }

    public static class EnumExtension {
        public static SidConfigAttribute GetSidConfigAttribute(this SidConfig value) {
            FieldInfo info = value.GetType().GetField(value.ToString());
            Assert.IsNotNull(info, "找不到info");
            object[] attributes = info.GetCustomAttributes(typeof(SidConfigAttribute), true);
            Assert.IsTrue(attributes.Length > 0, "没有attributes");
            SidConfigAttribute sidConfigAttribute = (SidConfigAttribute)attributes[0];
            return sidConfigAttribute;
        }

        public static string GetName(this SidConfig value) {
            return GetSidConfigAttribute(value).Name;
        }

        public static string GetSid(this SidConfig value) {
            return GetSidConfigAttribute(value).Sid.ToString();
        }

        public static string GetDesc(this SidConfig value) {
            return string.Format("{0}:{1}", GetSid(value), GetName(value));
        }


        /**
            ChannelType
         */
        public static ChannelTypeAttribute GetChannelTypeAttribute(this ChannelType value) {
           FieldInfo info = value.GetType().GetField(value.ToString());
            Assert.IsNotNull(info, "找不到info");
            object[] attributes = info.GetCustomAttributes(typeof(ChannelTypeAttribute), true);
            Assert.IsTrue(attributes.Length > 0, "没有attributes");
            ChannelTypeAttribute channelTypeAttribute = (ChannelTypeAttribute)attributes[0]; 
            return channelTypeAttribute;
        }
        public static string GetChannelString(this ChannelType value) {
            return Enum.GetName(typeof(ChannelType), value);
        }

        /**
            ChannelType && Sid
         */
        public static string GetBundleId(this SidConfig value, ChannelType type) {
            SidConfigAttribute sidConfigAttribute = GetSidConfigAttribute(value);
            if (!string.IsNullOrEmpty(sidConfigAttribute.BundleId)) {
                return sidConfigAttribute.BundleId;
            }
            ChannelTypeAttribute channelTypeAttribute = GetChannelTypeAttribute(type);
            return channelTypeAttribute.BundleId;
        }

        public static string GetChannelFolder(this SidConfig value, ChannelType type) {
            SidConfigAttribute sidConfigAttribute = GetSidConfigAttribute(value);
            if (!string.IsNullOrEmpty(sidConfigAttribute.BundleId)) {
                return sidConfigAttribute.ChannelFolder;
            }
            ChannelTypeAttribute channelTypeAttribute = GetChannelTypeAttribute(type);
            return channelTypeAttribute.ChannelFolder;
        }

    }
}
