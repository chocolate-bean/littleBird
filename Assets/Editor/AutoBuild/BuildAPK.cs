using System.Collections.Generic;
using UnityEngine;
using System.Collections;
using UnityEditor;
using System;
using System.Xml;
using System.IO;
using UnityEditor.Build.Reporting;
using LuaFramework;

public class BuildAPK: EditorWindow
{
    static int channelWidth = 230;

    [MenuItem("BuildChannel/打开工具窗口")]
    static void OpenWindow() {
        Debug.Log("先打开窗口然后");
        // EditorWindow.GetWindow(typeof(BuildAPK)).minSize = new Vector2(Enum.GetValues(typeof(ChannelType)).Length * channelWidth, 500);
        EditorWindow.GetWindowWithRect(typeof(BuildAPK), new Rect(0, 0, Enum.GetValues(typeof(ChannelType)).Length * channelWidth, 500));
    }

    SidConfig chooseSID = AppConst.sidConfig;
    ChannelType chooseChannelType = AppConst.channelType;
    Dictionary<ChannelType, bool> channelTypes;
    Dictionary<ChannelType, Dictionary<SidConfig, bool>> sidConfigs;
    Dictionary<ChannelType, Vector2> typeScrpllPos;
    Dictionary<ChannelType, List<SidConfig>> willBuildConfigs;
    bool isHotfix = AppConst.UpdateMode;
    void GetToggle(ChannelType type) {
        Array configs = Enum.GetValues(typeof(SidConfig));
        using (var h = new EditorGUILayout.VerticalScope(GUILayout.Width(channelWidth))) {
            using (var scrollView = new EditorGUILayout.ScrollViewScope(typeScrpllPos[type], false, false, GUILayout.Height(200))) {
                typeScrpllPos[type] = scrollView.scrollPosition;
                channelTypes[type] = EditorGUILayout.BeginToggleGroup(EnumExtension.GetChannelTypeAttribute(type).ShowName, channelTypes[type]);
                for (int i = 0; i < configs.Length; i++) {
                    SidConfig config = (SidConfig)configs.GetValue(i);
                    sidConfigs[type][config] = EditorGUILayout.ToggleLeft(config.GetDesc(), sidConfigs[type][config], GUILayout.Width(channelWidth - 30));
                }
                EditorGUILayout.EndToggleGroup();
            }
        }
    }

    void OnEnable() {
        Debug.Log("初始化");
        Array types   = Enum.GetValues(typeof(ChannelType));
        Array configs = Enum.GetValues(typeof(SidConfig));
        channelTypes     = new Dictionary<ChannelType, bool>();
        typeScrpllPos    = new Dictionary<ChannelType, Vector2>();
        sidConfigs       = new Dictionary<ChannelType, Dictionary<SidConfig, bool>>();
        willBuildConfigs = new Dictionary<ChannelType, List<SidConfig>>();
        for (int i = 0; i < types.Length; i++) {
            ChannelType type = (ChannelType)types.GetValue(i);
            channelTypes[type] = false;
            typeScrpllPos[type] = Vector2.zero;
            sidConfigs[type] = new Dictionary<SidConfig, bool>();
            for (int j = 0; j < configs.Length; j++) {
                SidConfig config = (SidConfig)configs.GetValue(j);
                sidConfigs[type][config] = false;
            }
        }
    }

    void OnGUI() {
        GUILayout.Space(20);
        isHotfix = EditorGUILayout.Toggle(isHotfix ? "热更新模式" : "非热更新模式", isHotfix);
        if (isHotfix != AppConst.UpdateMode) {
            if (GUILayout.Button("确认切换")) {
                ChangHotfix(isHotfix);
                // 代码更改代码要调用刷新
                AssetDatabase.Refresh();
            }
        }
        EditorGUILayout.LabelField("更换当前Sid");
        chooseSID = (SidConfig)EditorGUILayout.EnumPopup(chooseSID.GetDesc(), chooseSID);
        if (chooseSID != AppConst.sidConfig) {
            if (GUILayout.Button("确认切换")) {
                ChangeChannel(chooseChannelType, chooseSID);
                AssetDatabase.Refresh();
            }
        }
        GUILayout.Space(20);
        EditorGUILayout.LabelField("更换当前渠道 但不替换资源");
        chooseChannelType = (ChannelType)EditorGUILayout.EnumPopup(chooseChannelType.GetChannelString(), chooseChannelType);
        if (chooseChannelType != AppConst.channelType) {
            if (GUILayout.Button("确认切换")) {
                ChangeChannel(chooseChannelType, chooseSID);
                AssetDatabase.Refresh();
            }
        }
        GUILayout.Space(20);
        EditorGUILayout.LabelField("打包所选渠道");
        using (new EditorGUILayout.HorizontalScope()) {
            for (int i = 0; i < channelTypes.Count; i++) {
                GetToggle((ChannelType)i);
            }
        }

        if (GUILayout.Button("打包所选")) {
            string allSid = "打包所选\n";
            // 首先判断包类型  然后在判断不同的 sid
            foreach (KeyValuePair<ChannelType, Dictionary<SidConfig, bool>> channelConfigs in sidConfigs) {
                willBuildConfigs[channelConfigs.Key] = new List<SidConfig>();
                foreach (KeyValuePair<SidConfig, bool> config in channelConfigs.Value) {
                    if (config.Value) {
                        allSid += config.Key.GetDesc() + "\n";
                        willBuildConfigs[channelConfigs.Key].Add(config.Key);
                    }
                }
            }
            Debug.Log(allSid);
        }
        if (willBuildConfigs.Count > 0) {
            if (GUILayout.Button("确定打包")) {
                Build();
            }
        }
    }

    public static void ChangeChannel(ChannelType channelType, SidConfig sidConfig) {
        //修改C# APPCONST渠道号
        ChangeScripts(Enum.GetName(typeof(ChannelType), channelType), Enum.GetName(typeof(SidConfig), sidConfig));
        //修改Android Mainfest渠道号
        ChangeMainfest(sidConfig.GetSid().ToString());
        //特殊渠道要替换文件
        ChannelType type = channelType;
        if (!(type == ChannelType.MZBY 
        || type == ChannelType.WZBY 
        || type == ChannelType.TEST 
        || type == ChannelType.DBBY
        || type == ChannelType.DFBY
        || type == ChannelType.TEST_DFBY
        || type == ChannelType.FKBY)) {
            CopyFolder(sidConfig.GetChannelFolder(channelType), "Assets");
        } else {
            Debug.Log("Window下 手动移动资源 (需要将源资源删除后移除)");
        }
    }

    void StartBuildAndroidResource() {
        //首先要移动.vscode文件夹
        MoveFolder("Assets/LuaFramework/Lua/.vscode", "Assets/Editor/AutoBuild/.vscode");
    }

    void EndBuildAndroidResource() {
        //然后要build android resource
        Packager.BuildAndroidResource();
        //最后要把.vscode文件夹移回来
        MoveFolder("Assets/Editor/AutoBuild/.vscode", "Assets/LuaFramework/Lua/.vscode");
    }

    static BuildConfig CreateBuildConfig(ChannelType channelType, SidConfig sidConfig) {
        BuildConfig buildConfig = new BuildConfig();
        buildConfig.id                = sidConfig.GetSid();
        buildConfig.bundleVersionCode = AppConst.VersionCode;
        buildConfig.bundleIdentifier  = sidConfig.GetBundleId(channelType);
        buildConfig.bundleVersion     = AppConst.OsVersion;
        buildConfig.companyName       = EnumExtension.GetChannelTypeAttribute(channelType).CompanyName;
        buildConfig.productName       = EnumExtension.GetChannelTypeAttribute(channelType).ShowName;
        buildConfig.keystorePath      = "Tools/KeyStore/Ninek.jks";
        buildConfig.keystorePass      = "thumbp";
        buildConfig.keyaliasName      = "ninek";
        buildConfig.keyaliasPass      = "thumbp";
        buildConfig.apkName           = string.Format("{0}-{1}-latest", EnumExtension.GetChannelTypeAttribute(channelType).ShortName, sidConfig.GetSid());

        return buildConfig;
    }

    public static void BuildChannel(ChannelType channelType, SidConfig sidConfig) {
        BuildChannelApk(CreateBuildConfig(channelType, sidConfig));
    }

    void Build() {
        StartBuildAndroidResource();
        foreach (KeyValuePair<ChannelType, List<SidConfig>> channelConfigs in willBuildConfigs) {
            foreach (SidConfig config in channelConfigs.Value) {
                Debug.Log(config.GetDesc());
                ChangeChannel(channelConfigs.Key, config);
                BuildChannel(channelConfigs.Key, config);
            }
        }
        EndBuildAndroidResource();
    }
    public static void CopyFolder(string sourcePath, string destPath, string[] outSidePath = null)
    {
        if (Directory.Exists(sourcePath))
        {
            if (!Directory.Exists(destPath))
            {
                //目标目录不存在则创建
                try
                {
                    Directory.CreateDirectory(destPath);
                }
                catch (Exception ex)
                {
                    throw new Exception("创建目标目录失败：" + ex.Message);
                }
            }
            //获得源文件下所有文件
            List<string> files = new List<string>(Directory.GetFiles(sourcePath));
            files.ForEach(c =>
            {
                // if (!c.Contains(".meta")) {
                    string destFile = Path.Combine(destPath, Path.GetFileName(c));
                    c = c.Replace('/', '\\');
                    File.Copy(c, destFile, true);//覆盖模式
                // }
            });
            //获得源文件下所有目录文件
            List<string> folders = new List<string>(Directory.GetDirectories(sourcePath));
            folders.ForEach(c =>
            {
                bool isOutSide = false;
                if(outSidePath != null)
                {
                    foreach (string item in outSidePath)
                    {
                        if (c.Contains(item))
                        {
                            isOutSide = true;
                            break;
                        }
                    }
                }
                
                if (!isOutSide)
                {
                    string destDir = Path.Combine(destPath, Path.GetFileName(c));
                    //采用递归的方法实现
                    CopyFolder(c, destDir, outSidePath);
                }
            });
        } else {
            Debug.Log(sourcePath + "---" + destPath);
            throw new DirectoryNotFoundException("源目录不存在！");
        }
    }

    public static void DeleteFolder(string sourcePath, string[] outSidePath = null)
    {
        if (Directory.Exists(sourcePath))
        {
            //获得源文件下所有文件
            List<string> files = new List<string>(Directory.GetFiles(sourcePath));
            files.ForEach(c =>
            {
                File.Delete(c);//删除文件
            });
            //获得源文件下所有目录文件
            List<string> folders = new List<string>(Directory.GetDirectories(sourcePath));
            folders.ForEach(c =>
            {
                bool isOutSide = false;
                if(outSidePath != null)
                {
                    foreach (string item in outSidePath)
                    {
                        if (c.Contains(item))
                        {
                            isOutSide = true;
                            break;
                        }
                    }
                }

                if (!isOutSide)
                {
                    //采用递归的方法实现
                    DeleteFolder(c, outSidePath);
                }
            });
        }
        else
        {
            throw new DirectoryNotFoundException("源目录不存在！");
        }
    }

    public static void MoveFolder(string srcPath, string tarPath)
    {
        if (!Directory.Exists(srcPath))
        {
            Debug.Log("Move vscode文件夹不存在");
        }
        else
        {
            Directory.Move(srcPath, tarPath);
        }
    }

    static void ChangHotfix(bool needHotfix)
    {
        if (AppConst.UpdateMode == needHotfix && AppConst.LuaBundleMode == needHotfix) {
            return;
        }
        string path = "Assets/LuaFramework/Scripts/ConstDefine/AppConst.cs";
        if (File.Exists(path))
        {
            string[] str = File.ReadAllLines(path);
            for (int i = 0; i < str.Length; i++)
            {
                if (str[i].Contains("/////Hotfix模式修改位置"))
                {
                    str[i] = "        public const bool UpdateMode = " + needHotfix.ToString().ToLower() + ";/////Hotfix模式修改位置";
                }

                if (str[i].Contains("/////AssetBundle模式修改位置"))
                {
                    str[i] = "        public const bool LuaBundleMode = " + needHotfix.ToString().ToLower() + ";/////AssetBundle模式修改位置";
                }
            }
            File.WriteAllLines(path, str);
        }
        AssetDatabase.Refresh();
    }

    static void ChangeScripts(string ChannelName, string SidName)
    {
        string path = "Assets/LuaFramework/Scripts/ConstDefine/AppConst.cs";
        if (File.Exists(path))
        {
            string[] str = File.ReadAllLines(path);
            for (int i = 0; i < str.Length; i++)
            {
                if(str[i].Contains("/////BuildAPK修改位置(CHANNEL)"))
                {
                    str[i] = "        public static ChannelType channelType = ChannelType." + ChannelName + ";/////BuildAPK修改位置(CHANNEL)";
                }
                if(str[i].Contains("/////BuildAPK修改位置(sidConfig)"))
                {
                    str[i] = "        public static SidConfig sidConfig = SidConfig." + SidName + ";/////BuildAPK修改位置(sidConfig)";
                }
            }
            File.WriteAllLines(path, str);
        }
    }
    
    static void ChangeMainfest(string ChannelID)
    {
        string path = "Assets/Plugins/Android/AndroidManifest.xml";
        if (File.Exists(path))
        {
            string[] str = File.ReadAllLines(path);
            for (int i = 0; i < str.Length; i++)
            {
                if (str[i].Contains("<meta-data android:name=\"channel_id\""))
                {
                    str[i] = "    <meta-data android:name=\"channel_id\" android:value=\"" + ChannelID + "\"></meta-data>";
                }
                if (str[i].Contains("<meta-data android:name=\"JPUSH_CHANNEL\""))
                {
                    str[i] = "    <meta-data android:name=\"JPUSH_CHANNEL\" android:value=\"" + ChannelID + "\"></meta-data>";
                }
            }
            File.WriteAllLines(path, str);
        }
    }

    // 移动文件夹中的所有文件夹与文件到另一个文件夹
    static void MoveLuaFolder(string sourcePath, string destPath)
    {
        if (Directory.Exists(sourcePath))
        {
            if (!Directory.Exists(destPath))
            {
                //目标目录不存在则创建
                try
                {
                    Directory.CreateDirectory(destPath);
                }
                catch (Exception ex)
                {
                    throw new Exception("创建目标目录失败：" + ex.Message);
                }
            }
            //获得源文件下所有文件
            List<string> files = new List<string>(Directory.GetFiles(sourcePath));
            files.ForEach(c =>
            {
                string destFile = Path.Combine(destPath, Path.GetFileName(c));
                //覆盖模式
                if (File.Exists(destFile))
                {
                    File.Delete(destFile);
                }
                File.Move(c, destFile);
            });
            //获得源文件下所有目录文件
            List<string> folders = new List<string>(Directory.GetDirectories(sourcePath));

            folders.ForEach(c =>
            {
                string destDir = Path.Combine(destPath, Path.GetFileName(c));
                //Directory.Move必须要在同一个根目录下移动才有效，不能在不同卷中移动。
                //Directory.Move(c, destDir);

                //采用递归的方法实现
                MoveLuaFolder(c, destDir);
            });
        } else {
            Debug.Log(sourcePath + "---" + destPath);
            throw new DirectoryNotFoundException("源目录不存在！");
        }
    }


    static void BuildChannelApk(BuildConfig buildConfig)
    {
        // 公司名
        PlayerSettings.companyName = buildConfig.companyName;
        // 产品名
        PlayerSettings.productName = buildConfig.productName;
        // 包名
        PlayerSettings.applicationIdentifier = buildConfig.bundleIdentifier;

        PlayerSettings.bundleVersion = buildConfig.bundleVersion;
        PlayerSettings.Android.bundleVersionCode = int.Parse(buildConfig.bundleVersionCode);

        PlayerSettings.strippingLevel = StrippingLevel.StripByteCode;
        PlayerSettings.SetApiCompatibilityLevel(BuildTargetGroup.Android,ApiCompatibilityLevel.NET_2_0_Subset);

        // keystore 路径, G:\keystore\one.keystore
        PlayerSettings.Android.keystoreName = buildConfig.keystorePath;
        // one.keystore 密码
        PlayerSettings.Android.keystorePass = buildConfig.keystorePass;

        // one.keystore 别名
        PlayerSettings.Android.keyaliasName = buildConfig.keyaliasName;
        // 别名密码
        PlayerSettings.Android.keyaliasPass = buildConfig.keyaliasPass;

        BuildTargetGroup buildTargetGroup = BuildTargetGroup.Android;
        // 设置宏定义
        PlayerSettings.SetScriptingDefineSymbolsForGroup(buildTargetGroup, "ASYNC_MODE"); // 宏定义

        List<string> levels = new List<string>();
        foreach (EditorBuildSettingsScene scene in EditorBuildSettings.scenes)
        {
            if (!scene.enabled) continue;
            // 获取有效的 Scene
            levels.Add(scene.path);
        }
        
        // 切换到 Android 平台
        EditorUserBuildSettings.SwitchActiveBuildTarget(BuildTargetGroup.Android, BuildTarget.Android);

        // 打包出 APK 名
        string apkName = string.Format("APK/{0}.apk", buildConfig.apkName);
        // 执行打包
        BuildReport report = BuildPipeline.BuildPlayer(levels.ToArray(), apkName, BuildTarget.Android, BuildOptions.None);

        BuildSummary summary = report.summary;

        if(summary.result == BuildResult.Succeeded)
        {
            Debug.Log("Build succeeded" + apkName);
        }

        if(summary.result == BuildResult.Failed)
        {
            Debug.Log("构建失败");
        }

        AssetDatabase.Refresh();
    }
}
