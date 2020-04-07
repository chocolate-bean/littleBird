using UnityEngine;
using System.Collections;
using LuaInterface;
using System;
using UnityEngine.SceneManagement;
using System.Collections.Generic;
using System.IO;

namespace LuaFramework {
    public class LuaManager : Manager {
        private LuaState lua;
        private LuaLoader loader;
        private LuaLooper loop = null;

        private LuaFunction main;
        private LuaFunction onInitOK;
        private LuaFunction onActiveSceneChanged;
        private LuaFunction onSceneLoaded;
        private LuaFunction onApplicationQuit;
        private LuaFunction onApplicationFocus;
        private LuaFunction onApplicationPause;
        private LuaFunction onReturnKeyClick;
        private LuaFunction nativeErrorCallback;
        private LuaFunction playSound;
        private LuaFunction topTips;
        private LuaFunction receiveCallBack;
        private LuaFunction connected;
        private LuaFunction networkErrorCallBack;

        static Queue<ByteArray> mEvents = new Queue<ByteArray>();

        static Queue<KeyValuePair<int, byte[]>> mServerEvent = new Queue<KeyValuePair<int, byte[]>>();

        static readonly object m_lockObject = new object();
        public static void AddEvent(ByteArray data)
        {
            lock(m_lockObject)
            {
                mEvents.Enqueue(data);
            }
        }

        public static void AddEvent(int cmd, byte[] byteArray)
        {
            lock(m_lockObject)
            {
                KeyValuePair<int, byte[]> fuck = new KeyValuePair<int, byte[]>(key:cmd, value:byteArray);
                mServerEvent.Enqueue(fuck);
            }
        }

        // Use this for initialization
        void Awake() {
            loader = new LuaLoader();
            lua = new LuaState();
            this.OpenLibs();
            lua.LuaSetTop(0);

            LuaBinder.Bind(lua);
            DelegateFactory.Init();
            LuaCoroutine.Register(lua, this);
        }

        public void InitStart() {
            InitLuaPath();
            InitLuaBundle();
            this.lua.Start();    //启动LUAVM
            this.StartMain();
            this.StartLooper();

            //this.StartGame();
        }

        public void Update()
        {
            if (Input.GetKeyDown(KeyCode.Escape))
            {
                if(onReturnKeyClick != null)
                {
                    onReturnKeyClick.Call();
                }
            }

            if (mEvents.Count > 0)
            {
                while (mEvents.Count > 0)
                {
                    ByteArray data = mEvents.Dequeue();
                    CallReceiveCallBack(data);
                }
            }

            if (mServerEvent.Count > 0)
            {
                while (mServerEvent.Count > 0)
                {
                    
                    KeyValuePair<int, byte[]> data = mServerEvent.Dequeue();
                    // CallReceiveCallBack(data);
                    // 该死的代码
                    // if (FishingGameControl.Instance)
                    // {
                    //     FishingGameControl.Instance.addServerLister(data.Key, data.Value);
                    // }
                }
            }
        }

        private void OnApplicationFocus(bool focus)
        {
#if !UNITY_EDITOR
            if(onApplicationFocus != null)
            {
                onApplicationFocus.Call(focus);
            }
#endif
        }

        void OnApplicationPause(bool pause) {
            if (onApplicationPause != null)
            {
                onApplicationPause.Call(pause);
            }
        }

        public void StartGame()
        {
            SceneManager.activeSceneChanged += delegate { onActiveSceneChanged.Call(SceneManager.GetActiveScene().name); };
            SceneManager.sceneLoaded        += delegate { onSceneLoaded.Call(SceneManager.GetActiveScene().name); };
            Application.quitting            += delegate { onApplicationQuit.Call(); };
            onInitOK.Call();
        }

        public void CallConnected()
        {
            connected.Call();
        }

        public void CallNetworkErrorCallBack()
        {
            networkErrorCallBack.Call();
        }

        public void CallShowToptips(string message)
        {
            topTips.Call(message);
        }

        public void CallReceiveCallBack(ByteArray receiveValue)
        {
            receiveCallBack.BeginPCall();
            receiveCallBack.Push(receiveValue);
            receiveCallBack.PCall();
            receiveCallBack.EndPCall();
        }

        public void CallLuaNativeErrorCallback(string error)
        {
            nativeErrorCallback.Call(error);
        }

        public void CallLuaPlaySound(string type, string param = "")
        {
            playSound.Call(type, param);
        }

        void StartLooper() {
            loop = gameObject.AddComponent<LuaLooper>();
            loop.luaState = lua;
        }

        //cjson 比较特殊，只new了一个table，没有注册库，这里注册一下
        protected void OpenCJson() {
            lua.LuaGetField(LuaIndexes.LUA_REGISTRYINDEX, "_LOADED");
            lua.OpenLibs(LuaDLL.luaopen_cjson);
            lua.LuaSetField(-2, "cjson");

            lua.OpenLibs(LuaDLL.luaopen_cjson_safe);
            lua.LuaSetField(-2, "cjson.safe");
        }

        void StartMain() {
            lua.DoFile("Main.lua");

            main                 = lua.GetFunction("Main");
            onInitOK             = lua.GetFunction("OnInitOK");
            onActiveSceneChanged = lua.GetFunction("onActiveSceneChanged");
            onSceneLoaded        = lua.GetFunction("onSceneLoaded");
            onApplicationQuit    = lua.GetFunction("onApplicationQuit");
            onApplicationFocus   = lua.GetFunction("onApplicationFocus");
            onApplicationPause   = lua.GetFunction("onApplicationPause");
            onReturnKeyClick     = lua.GetFunction("onReturnKeyClick");
            nativeErrorCallback  = lua.GetFunction("nativeErrorCallback");
            playSound            = lua.GetFunction("playSound");
            receiveCallBack      = lua.GetFunction("receiveCallBack");
            connected            = lua.GetFunction("connected");
            networkErrorCallBack = lua.GetFunction("networkErrorCallBack");
            topTips              = lua.GetFunction("topTips");

            main.Call();
            main.Dispose();
            main = null;    
        }
        
        /// <summary>
        /// 初始化加载第三方库
        /// </summary>
        void OpenLibs() {
            lua.OpenLibs(LuaDLL.luaopen_pb);      
            lua.OpenLibs(LuaDLL.luaopen_sproto_core);
            lua.OpenLibs(LuaDLL.luaopen_protobuf_c);
            lua.OpenLibs(LuaDLL.luaopen_lpeg);
            lua.OpenLibs(LuaDLL.luaopen_bit);
            lua.OpenLibs(LuaDLL.luaopen_socket_core);

            if (LuaConst.openLuaSocket)
            {
                OpenLuaSocket();
            }

            this.OpenCJson();
        }

        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int LuaOpen_Socket_Core(IntPtr L)
        {
            return LuaDLL.luaopen_socket_core(L);
        }

        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int LuaOpen_Mime_Core(IntPtr L)
        {
            return LuaDLL.luaopen_mime_core(L);
        }

        protected void OpenLuaSocket()
        {
            LuaConst.openLuaSocket = true;
            lua.BeginPreLoad();
            lua.RegFunction("socket.core", LuaOpen_Socket_Core);
            lua.RegFunction("mime.core", LuaOpen_Mime_Core);
            lua.EndPreLoad();
        }

        /// <summary>
        /// 初始化Lua代码加载路径
        /// </summary>
        void InitLuaPath() {
            if (AppConst.DebugMode) {
                string rootPath = AppConst.FrameworkRoot;
                lua.AddSearchPath(rootPath + "/Lua");
                lua.AddSearchPath(rootPath + "/ToLua/Lua");
            }
            else
            {
                string rootPath = AppConst.FrameworkRoot;
                lua.AddSearchPath(rootPath + "/Lua");
                lua.AddSearchPath(Util.DataPath + "lua");
            }
        }

        /// <summary>
        /// 初始化LuaBundle
        /// </summary>
        void InitLuaBundle() {
            if (loader.beZip) {
                // 获取当前平台的 StreamingAssets 路径
                // 但是有个问题 安卓平台的 StreamingAssets 无法获取
                // 但又由于 StreamingAssets 会解包到对应的 DataPath 位置下 所以采用 DataPath 来读取 lua 文件 资源
                string path = Util.DataPath;
                Debug.Log("加载LuaBundle对应的路径" + path);
                string[] files = Directory.GetFiles(path + "/lua", "*.unity3d");
                for (int i = 0; i < files.Length; i++) {
                    loader.AddBundle(files[i].Replace(path + "/", "").Replace("\\", "/"));
                }
            }
        }

        public void DoFile(string filename) {
            lua.DoFile(filename);
        }

        // Update is called once per frame
        public object[] CallFunction(string funcName, params object[] args) {
            LuaFunction func = lua.GetFunction(funcName);
            if (func != null) {
                return func.LazyCall(args);
            }
            return null;
        }

        public void LuaGC() {
            lua.LuaGC(LuaGCOptions.LUA_GCCOLLECT);
        }

        public void Close() {
            loop.Destroy();
            loop = null;

            lua.Dispose();
            lua = null;
            loader = null;
        }
    }
}