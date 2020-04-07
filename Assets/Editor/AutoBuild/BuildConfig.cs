using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BuildConfig{
    /// <summary>
    ///编号
    /// <summary>
    public string id { get; set; }
    /// <summary>
    ///版本号
    /// <summary>
    public string bundleVersion { get; set; }
    /// <summary>
    ///版本号
    /// <summary>
    public string bundleVersionCode { get; set; }
    /// <summary>
    ///公司名
    /// <summary>
    public string companyName { get; set; }
    /// <summary>
    ///应用名
    /// <summary>
    public string productName { get; set; }
    /// <summary>
    ///包名
    /// <summary>
    public string bundleIdentifier { get; set; }
    /// <summary>
    ///keystore文件路径
    /// <summary>
    public string keystorePath { get; set; }
    /// <summary>
    ///keystore密码
    /// <summary>
    public string keystorePass { get; set; }
    /// <summary>
    ///别名
    /// <summary>
    public string keyaliasName { get; set; }
    /// <summary>
    ///别名密码
    /// <summary>
    public string keyaliasPass { get; set; }
    /// <summary>
    ///脚本宏定义
    /// <summary>
    public string scriptingDefine { get; set; }
    /// <summary>
    ///APK名
    /// <summary>
    public string apkName { get; set; }
}
