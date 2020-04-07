using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;
using LuaInterface;

namespace  LuaFramework {
    public class NativeManager: Manager {
        [DllImport("__Internal")]
        private static extern void FromUnity(string plugin, string boxString);
        private Dictionary<string, AndroidJavaObject> javaObjects;
        private Dictionary<string, LuaFunction> luaCallbacks;
        public void Awake() {
            luaCallbacks = new Dictionary<string, LuaFunction>();
#if UNITY_ANDROID && !UNITY_EDITOR
            InitAndroid();
#endif
        }
        void InitAndroid() {
            Debug.Log("TEST->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> InitAndroid");
            javaObjects = new Dictionary<string, AndroidJavaObject>();
            string[] names = {"plugin_base","plugin_identify"};
            foreach (var name in names) {
                string className = "com.thumbp." + name + ".HelperFragment";
                AndroidJavaClass javaClass = new AndroidJavaClass(className);
                AndroidJavaObject javaObject = javaClass.CallStatic<AndroidJavaObject>("GetInstance", className);
                if (javaObject != null) {
                    javaObjects.Add(name, javaObject);
                } else {
                    Debug.LogWarning("没有找到对应的插件:" + className);
                }
            }
        }
        public void FromLua(string plugin, string boxString, LuaFunction luaFunc = null) {
            Debug.Log("TEST->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> FromLua");
#if UNITY_ANDROID && !UNITY_EDITOR
            FromLuaThenToAndroid(plugin, boxString, luaFunc);
#elif UNITY_IPHONE && !UNITY_EDITOR
            FromLuaThenToIPhone(plugin, boxString, luaFunc);
#else
            Box sendBox = JsonUtility.FromJson<Box>(boxString);
            if (sendBox == null) {
                ErrorToLua("目前该平台无法加载 plugin 并且 Lua 传入的 boxString 有误!", null, luaFunc);
            } else {
                ErrorToLua("目前该平台无法加载 plugin!", sendBox, luaFunc);
            }
#endif
        }
        void ErrorToLua(string error, Box box = null, LuaFunction luaFunc = null){
            if (luaFunc != null) {
                if (box == null) {
                    box = new Box();
                }
                luaFunc.Call(box.setError(error));
            } else {
                if (box != null && (!string.IsNullOrEmpty(box.method)) && luaCallbacks.ContainsKey(box.method)) {
                    LuaFunction findLuaFunc = luaCallbacks[box.method];
                    luaCallbacks.Remove(box.method);
                    ErrorToLua(error, box, findLuaFunc);
                }
            }
        }
        void FromLuaThenToAndroid(string plugin, string boxString, LuaFunction luaFunc = null) {
            Box sendBox = JsonUtility.FromJson<Box>(boxString);
            if (sendBox == null) {
                ErrorToLua("Lua 传入的 boxString 有误!", null, luaFunc);
                return;
            }
            if (string.IsNullOrEmpty(plugin) || !javaObjects.ContainsKey(plugin)) {
                ErrorToLua("Lua 传入的 plugin 有误!", sendBox, luaFunc);
                return;
            } 
            if (luaFunc != null) {
                if (luaCallbacks.ContainsKey(sendBox.method)) {
                    luaCallbacks.Remove(sendBox.method);
                }
                luaCallbacks.Add(sendBox.method, luaFunc);
            }
            if (javaObjects[plugin] != null) {
                javaObjects[plugin].Call("FromUnity", boxString);
            }
        }
        public void FromAndroid(string boxString) {
            Box remandBox = JsonUtility.FromJson<Box>(boxString);
            if (remandBox == null) {
                ErrorToLua("Android 传入的 boxString 有误!", remandBox);
                return;
            }
            if (luaCallbacks.ContainsKey(remandBox.method)) {
                LuaFunction luaFunc = luaCallbacks[remandBox.method];
                luaFunc.Call(boxString);
                luaCallbacks.Remove(remandBox.method);
            }
        }

        void FromLuaThenToIPhone(string plugin, string boxString, LuaFunction luaFunc = null) {
            Box sendBox = JsonUtility.FromJson<Box>(boxString);
            if (sendBox == null) {
                ErrorToLua("Lua 传入的 boxString 有误!", null, luaFunc);
                return;
            }
            if (luaFunc != null) {
                if (luaCallbacks.ContainsKey(sendBox.method)) {
                    luaCallbacks.Remove(sendBox.method);
                }
                luaCallbacks.Add(sendBox.method, luaFunc);
            }
            /**
             * plugin_wechat => WechatHelperFragment
             */ 
            plugin = plugin.Replace("plugin_", "");
            plugin = plugin[0].ToString().ToUpper() + plugin.Substring(1) + "HelperFragment";
            FromUnity(plugin, boxString);
        } 

        public void FromIPhone(string boxString) {
            Box remandBox = JsonUtility.FromJson<Box>(boxString);
            if (remandBox == null) {
                ErrorToLua("IPhone 传入的 boxString 有误!", remandBox);
                return;
            }
            if (luaCallbacks.ContainsKey(remandBox.method)) {
                LuaFunction luaFunc = luaCallbacks[remandBox.method];
                luaFunc.Call(boxString);
                luaCallbacks.Remove(remandBox.method);
            }
        }

        public static string getsid() {
#if UNITY_ANDROID && !UNITY_EDITOR
            // for
#endif

        return "11";
        }
    }
}