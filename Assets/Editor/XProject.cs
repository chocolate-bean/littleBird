using System.IO;
using UnityEngine;
#if UNITY_EDITOR_OSX
using UnityEditor;
using UnityEditor.iOS.Xcode;
using UnityEditor.Callbacks;
using UnityEditor.XCodeEditor;
using System.Collections;
using LuaFramework;

public class XProject
{
    //该属性是在build完成后，被调用的callback
    [PostProcessBuildAttribute(0)]
    public static void OnPostprocessBuild(BuildTarget buildTarget, string pathToBuiltProject)
    {

        // BuildTarget需为iOS
        if (buildTarget != BuildTarget.iOS)
            return;

        string wxAppID      = AppConst.wxAppID;
#if APPLE_OFFICIAL
#else
        string alipayScheme = AppConst.alipayScheme;
#endif

        // 初始化
        var projectPath = pathToBuiltProject + "/Unity-iPhone.xcodeproj/project.pbxproj";
        PBXProject pbxProject = new PBXProject();
        pbxProject.ReadFromFile(projectPath);
        string targetGuid = pbxProject.TargetGuidByName("Unity-iPhone");

        // 添加flag
        pbxProject.AddBuildProperty(targetGuid, "OTHER_LDFLAGS", "-ObjC");
        // 关闭Bitcode
        pbxProject.SetBuildProperty(targetGuid, "ENABLE_BITCODE", "NO");

        // 添加framwrok
        pbxProject.AddFrameworkToProject(targetGuid, "CoreTelephony.framework", false);
        pbxProject.AddFrameworkToProject(targetGuid, "CoreFoundation.framework", false);
        pbxProject.AddFrameworkToProject(targetGuid, "CFNetwork.framework", false);
        pbxProject.AddFrameworkToProject(targetGuid, "CoreTelephony.framework", false);
        pbxProject.AddFrameworkToProject(targetGuid, "AdSupport.framework", false);
        pbxProject.AddFrameworkToProject(targetGuid, "UserNotifications.framework", false);
#if APPLE_OFFICIAL
        pbxProject.AddFrameworkToProject(targetGuid, "StoreKit.framework", false);
#endif

        //添加lib
        AddLibToProject(pbxProject, targetGuid, "libsqlite3.tbd");
        AddLibToProject(pbxProject, targetGuid, "libc++.tbd");
        AddLibToProject(pbxProject, targetGuid, "libz.tbd");
        // AddLibToProject(pbxProject, targetGuid, "libresolv.tbd ");


#if APPLE_OFFICIAL
#else
        string alipaySdk = pbxProject.AddFile("Frameworks/Plugins/iOS/AliPay/AlipaySDK.framework", "Frameworks/Plugins/iOS/AliPay/AlipaySDK.framework"); 
        pbxProject.AddFileToBuild(targetGuid, alipaySdk); 
        // string copyFilesPhaseGuid = pbxProject.AddCopyFilesBuildPhase(targetGuid, "Link Binary With Libraries", "", "10"); 
        // pbxProject.AddFileToBuildSection(targetGuid, copyFilesPhaseGuid, alipaySdk); 
#endif
        // 应用修改
        File.WriteAllText(projectPath, pbxProject.WriteToString()); 

        // 修改Info.plist文件
        var plistPath = Path.Combine(pathToBuiltProject, "Info.plist");
        var plist = new PlistDocument();
        plist.ReadFromFile(plistPath);

        plist.root.SetString("NSPhotoLibraryUsageDescription", "需要您的同意，才能访问相册用以上传头像！");

        var appSchemes = plist.root.CreateArray("LSApplicationQueriesSchemes");
        appSchemes.AddString("weixin");

        // 插入URL Scheme到Info.plsit（理清结构）
        var array = plist.root.CreateArray("CFBundleURLTypes");
        //插入dict
        var urlDict = array.AddDict();
        urlDict.SetString("CFBundleURLName", "weixin");
        //插入array
        var urlInnerArray = urlDict.CreateArray("CFBundleURLSchemes");
        urlInnerArray.AddString(wxAppID);
#if APPLE_OFFICIAL
#else
        urlInnerArray.AddString(alipayScheme);

#endif
        // 应用修改
        plist.WriteToFile(plistPath);

        //插入代码
        //读取UnityAppController.mm文件
        string unityAppControllerPath = pathToBuiltProject + "/Classes/UnityAppController.mm";
        XClass UnityAppController = new XClass(unityAppControllerPath);

        //在指定代码后面增加一行代码
        string importCode = 
        "\n" +
#if APPLE_OFFICIAL
#else
        "#import <AlipaySDK/AlipaySDK.h>\n" +
#endif
        "#include \"WXApi.h\"\n" + 
        "#include \"WXApiObject.h\"\n";
        UnityAppController.WriteBelow("#include \"PluginBase/AppDelegateListener.h\"", importCode);

        string interfaceCode = 
        "@interface UnityAppController()<WXApiDelegate>\n" + 
        "@end\n" + 
        "\n" +
        "@implementation UnityAppController";
        UnityAppController.Replace("@implementation UnityAppController", interfaceCode);

        string openURLCode = 
        "\n" +
#if APPLE_OFFICIAL
#else
        "    if ([url.host isEqualToString:@\"safepay\"]) {\n" +
        "        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {\n" +
        "            NSLog(@\"支付宝支付结果：%@\", resultDic);\n" +
        "        }];\n" +
        "    }\n" +
#endif
        "    [WXApi handleOpenURL:url delegate:self];\n";
        UnityAppController.WriteBelow("- (BOOL)application:(UIApplication*)application openURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication annotation:(id)annotation\n{", openURLCode);

        string didFinishLaunchCode = 
        "    [WXApi registerApp:@\"" + wxAppID + "\"];";
        //在指定代码后面增加一大行代码
        UnityAppController.WriteBelow("// if you wont use keyboard you may comment it out at save some memory", didFinishLaunchCode);

        string wxAPIdelegateCode = 
        "- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options\n" + 
        "{\n" +
        "    [WXApi handleOpenURL:url delegate:self];\n" + 
#if APPLE_OFFICIAL
#else
        "    if ([url.host isEqualToString:@\"safepay\"]) {\n" +
        "        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {\n" +
        "            NSLog(@\"支付宝支付结果：%@\", resultDic);\n" +
        "        }];\n" +
        "    }\n" +
#endif
        "    return YES;\n" +
        "}\n" +
        "\n" +
        "- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url\n" + 
        "{\n" +
        "    [WXApi handleOpenURL:url delegate:self];\n" + 
        "    return YES;\n" +
        "}\n" +
        "\n" + 
        "- (void)onResp:(BaseResp *)resp\n" +
        "{\n" +
        "    if ([resp isKindOfClass:[SendAuthResp class]]) {\n" +
        "        SendAuthResp *authResp = (SendAuthResp *)resp;\n" +
        "        switch (authResp.errCode) {\n" +
        "            case WXSuccess:\n" +
        "                [[NSNotificationCenter defaultCenter] postNotificationName:@\"WXAuthorizationSuccess\" object:nil userInfo:@{@\"code\" : authResp.code}];\n" +
        "                break;\n" +
        "            default:\n" +
        "                NSLog(@\"登录失败，retcode=%d\", authResp.errCode);\n" +
        "                break;\n" +
        "        }\n" +
        "    }\n" +
#if APPLE_OFFICIAL
#else
        "    if ([resp isKindOfClass:[PayResp class]]) {\n" +
        "        PayResp *response = (PayResp *)resp;\n" +
        "        switch (response.errCode) {\n" +
        "            case WXSuccess:\n" +
        "                NSLog(@\"支付成功\");\n" +
        "                break;\n" +
        "            default:\n" +
        "                NSLog(@\"支付失败，retcode=%d\", response.errCode);\n" +
        "                break;\n" +
        "        }\n" +
        "    }\n" +
#endif
        "}\n" +
        "- (void)applicationDidEnterBackground:(UIApplication*)application";
        //在指定代码后面增加一大行代码
        UnityAppController.Replace("- (void)applicationDidEnterBackground:(UIApplication*)application", wxAPIdelegateCode);

#if APPLE_OFFICIAL
#else
        // 修改Alipay
        string alipayHandlePath = pathToBuiltProject + "/Libraries/Plugins/iOS/Alipay/AlipayHandle.mm";
        XClass AlipayHandle = new XClass(alipayHandlePath);

        AlipayHandle.Replace("#define kAlipayScheme @\"kAlipayScheme\"", "#define kAlipayScheme @\"" + alipayScheme + "\"");
#endif

#if APPLE_OFFICIAL
        // 修改Wechat
        string wechatHandlePath = pathToBuiltProject + "/Libraries/Plugins/iOS/Wechat/WechatHandle.mm";
        XClass WechatHandle = new XClass(wechatHandlePath);

        WechatHandle.Replace("void IOS_WechatPay(char* gameObjectName, char* partnerId, char* prepayId, char* noncestr, char* timeStamp, char* sign)", 
        "\n/*\nvoid IOS_WechatPay(char* gameObjectName, char* partnerId, char* prepayId, char* noncestr, char* timeStamp, char* sign)");

        WechatHandle.Replace("void IOS_WechatShareWebpage(char* gameObjectName, int type, char* url, char* title, char* description)", 
        "\n*/\nvoid IOS_WechatShareWebpage(char* gameObjectName, int type, char* url, char* title, char* description)");
#else
#endif

    }

        //添加lib方法
    static void AddLibToProject(PBXProject inst, string targetGuid, string lib)
    {
        string fileGuid = inst.AddFile("usr/lib/" + lib, "Frameworks/" + lib, PBXSourceTree.Sdk);
        inst.AddFileToBuild(targetGuid, fileGuid);
    }
}
#endif