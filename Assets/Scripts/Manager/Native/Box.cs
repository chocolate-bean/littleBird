using System.Collections.Generic;
using UnityEngine;
using System;

namespace  LuaFramework {
    // 两层嵌套的json 这个Box类要和Android里面的Box同步
    [System.Serializable]
    public class Box {
        public string[] sends;
        public string remand;
        public string method;   // 调用 Android 的哪个方法
        public string error;    // 具体内容
        public string setError(string error) {
            this.error = error;
            return JsonUtility.ToJson(this);
        }
    }
}