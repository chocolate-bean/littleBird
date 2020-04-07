using UnityEngine;
using System;
using System.Reflection;
using System.Collections;
using System.Collections.Generic;

namespace LuaFramework {
    public class AppConst {
        //调试模式-用于内部测试
        public const bool DebugMode = false;                       
        //Lua字节码模式-默认关闭 
        public const bool LuaByteMode = false;                      
        //更新模式-默认关闭 
        public const bool UpdateMode = false;/////Hotfix模式修改位置
        //Lua代码AssetBundle模式
        public const bool LuaBundleMode = false;/////AssetBundle模式修改位置
        public static string VersionCode      = "302000";                                        //版本
        public static string Version          = "320";                                           //版本号
        public static string OsVersion        = "3.2.0";                                         //版本号小
        public const int TimerInterval        = 1;
        public const int GameFrameRate        = 60;                                              //游戏帧频
        public const string AppName           = "LuaFramework";                                  //应用程序名称
        public const string LuaTempDir        = "Lua/";                                          //临时目录
        public const string AppPrefix         = AppName + "_";                                   //应用程序前缀
        public const string ExtName           = ".unity3d";                                      //素材扩展名
        public const string AssetDir          = "StreamingAssets";                               //素材目录 
        public static SidConfig sidConfig = SidConfig.ZZB;/////BuildAPK修改位置(sidConfig)
        public static ChannelType channelType = ChannelType.MZBY;/////BuildAPK修改位置(CHANNEL)
        public static SidConfigAttribute sidConfigAttr = EnumExtension.GetSidConfigAttribute(sidConfig);
        public static ChannelTypeAttribute channelTypeAttr = EnumExtension.GetChannelTypeAttribute(channelType);
        public static string Sid = sidConfig.GetSid();
        public static string ServerId = channelTypeAttr.ServerId;
        public static string channel = Enum.GetName(typeof(SidConfig), sidConfig).ToLower();
        public static string FrameworkRoot { get { return Application.dataPath + "/" + AppName; } }
        public static string CheckUrl = channelTypeAttr.CheckUrl;
        public static string WebUrl = string.Format(channelTypeAttr.HotFixUrl, IsIPhone ? "_ios" : "", Version);
        public static string wxAppID = channelTypeAttr.WXAppId;
        public static string umengAppkey = channelTypeAttr.UMengAppKey;
        public const string alipayScheme = "thumbplandlordsalipay";
        public static bool IsIPhone {
            get {
#if UNITY_IPHONE || UNITY_EDITOR_OSX
                return true;
#else
                return false;
#endif
            }
        }
    }
}

