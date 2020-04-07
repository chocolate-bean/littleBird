using UnityEngine;
using System.Collections.Generic;
using System.Reflection;
using LuaInterface;
using System;

namespace LuaFramework {
    public static class LuaHelper {

        /// <summary>
        /// getType
        /// </summary>
        /// <param name="classname"></param>
        /// <returns></returns>
        public static System.Type GetType(string classname) {
            Assembly assb = Assembly.GetExecutingAssembly();  //.GetExecutingAssembly();
            System.Type t = null;
            t = assb.GetType(classname); ;
            if (t == null) {
                t = assb.GetType(classname);
            }
            return t;
        }

        /// <summary>
        /// 资源管理器
        /// </summary>
        public static ResourceManager GetResManager() {
            return AppFacade.Instance.GetManager<ResourceManager>(ManagerName.Resource);
        }

        /// <summary>
        /// SDK管理器
        /// </summary>
        public static SDKManager GetSDKManager()
        {
            return AppFacade.Instance.GetManager<SDKManager>(ManagerName.SDK);
        }
        /// <summary>
        /// Native管理器
        /// </summary>
        public static NativeManager GetNativeManager()
        {
            return AppFacade.Instance.GetManager<NativeManager>(ManagerName.Native);
        }

        /// <summary>
        /// WWW管理器
        /// </summary>
        public static WWWManager GetWWWManager()
        {
            return AppFacade.Instance.GetManager<WWWManager>(ManagerName.WWW);
        }

        /// <summary>
        /// Sound管理器
        /// </summary>
        public static SoundManager GetSoundManager()
        {
            return AppFacade.Instance.GetManager<SoundManager>(ManagerName.Sound);
        }

        /// <summary>
        /// 商店管理器
        /// </summary>
        public static ShopManager GetShopManager()
        {
            return AppFacade.Instance.GetManager<ShopManager>(ManagerName.Shop);
        }


        /// <summary>
        /// pbc/pblua函数回调
        /// </summary>
        /// <param name="func"></param>
        public static void OnCallLuaFunc(LuaByteBuffer data, LuaFunction func) {
            if (func != null) func.Call(data);
            Debug.LogWarning("OnCallLuaFunc length:>>" + data.buffer.Length);
        }

        /// <summary>
        /// cjson函数回调
        /// </summary>
        /// <param name="data"></param>
        /// <param name="func"></param>
        public static void OnJsonCallFunc(string data, LuaFunction func) {
            Debug.LogWarning("OnJsonCallback data:>>" + data + " lenght:>>" + data.Length);
            if (func != null) func.Call(data);
        }
    }
}