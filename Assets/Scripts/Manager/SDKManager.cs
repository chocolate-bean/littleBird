using System.ComponentModel;
using UnityEngine;
using LuaInterface;
using System.Collections.Generic;
// using Umeng;
using System;
using System.Collections;

#if GP
using Facebook.Unity;
using Facebook.MiniJSON;
#endif

namespace LuaFramework
{
    public class SDKManager : Manager
    {
        // 多平台
        private SDKBase sdk;
        // FB邀请链接
        public string appLinkUrl;
        // AF是否初始化
        public bool AFInit;
        // Umeng是否初始化
        public bool UmengInit;

        // 用于获取IEMI后的回调
        public LuaFunction GetIMEICallback;

        // 用于获取IEMI后的回调
        public LuaFunction GetIDFACallback;

        //用于获得图片后的回调
        public LuaFunction GetImageCallBack;

        //网页内命令字出发回调
        public LuaFunction onMessageReceived;

        // 用于微信登录获得code之后的回调
        public LuaFunction GetWXLoginCallback;

        public LuaFunction InAppPurchasesCallback;
        void Awake()
        {
#if UNITY_EDITOR
            sdk = new SDKBase(gameObject.name);
#elif UNITY_ANDROID
            sdk = new SDKAndroid(gameObject.name);
#elif UNITY_IPHONE
            sdk = new SDKIOS(gameObject.name);
#else
            sdk = new SDKBase(gameObject.name);
#endif
        }

        public void Start()
        {
            //针对多平台的SDK初始化
            SDKInit();
            CommonInit();
        }

        public void SDKInit()
        {
            if (sdk == null)
            {
                return;
            }

            sdk.Init();
        }

        public void CommonInit()
        {
#if GP
            // FB初始化
            FB.Init(
                // 初始化成功回调
                () =>
                {
                    Debug.Log("FB OnInitComplete!");
                    Debug.Log("FB.AppId: " + FB.AppId);
                    Debug.Log("FB.GraphApiVersion: " + FB.GraphApiVersion);
                    //初始化成功去获取appLinkUrl
                    FBGetAPPLinkUrl();
                },
                // 初始化失败回调
                (isUnityShutDown) =>
                {
                    Debug.Log("FB OnHideUnity：" + isUnityShutDown);
                }
            );
#endif

            string channel = AppConst.channel;
            // 友盟初始化
// #if UNITY_ANDROID
//             GA.SetLogEnabled(true);
//             GA.Start(AppConst.umengAppkey, channel);
//             UmengInit = true;
// #elif UNITY_IPHONE
//             GA.Start(AppConst.umengAppkey, channel);
//             UmengInit = true;
// #else
//             Debug.Log("EDITOR OR WIN，UMeng NOT INIT");
//             UmengInit = false;
// #endif
        }

#if GP
        /// <summary>
        /// FB登陆
        /// </summary>
        /// <param name="LoginSuccess"></param>
        /// <param name="LoginFaild"></param>
        public void FBLogin(LuaFunction LoginSuccess, LuaFunction LoginFaild)
        {
            List<string> param = new List<string>() {"public_profile"};
            FB.LogInWithReadPermissions(param,
                (result) =>
                {
                    if (FB.IsLoggedIn)
                    {
                        Debug.Log("FBLoginSucceed");
                        //string tokenString = Facebook.Unity.AccessToken.CurrentAccessToken.ToString();
                        string tokenString = Facebook.Unity.AccessToken.CurrentAccessToken.TokenString;
                        LoginSuccess.Call(tokenString);
                    }
                    else
                    {
                        Debug.Log("FBLoginFaild");
                        LoginFaild.Call(result.Error);
                    }
                }
            );
        }

        /// <summary>
        /// 获取FB邀请链接
        /// </summary>
        public void FBGetAPPLinkUrl()
        {
            FB.GetAppLink((result) =>
            {
                //打印获取结果
                Debug.Log(result.RawResult);

                appLinkUrl = result.Url;
            });
        }
#endif

        public void GetIMEI(LuaFunction func)
        {
            if (sdk.GetSystemVersion() > 28)
            {
                GetIMEICallback = func;
                GetIMEICallback.Call(SystemInfo.deviceUniqueIdentifier);
            }
            else{
                sdk.GetIMEI();
                GetIMEICallback = func;
            }
        }

        public void GetIDFA(LuaFunction func)
        {
            if (sdk.GetSystemVersion() > 28)
            {
                GetIDFACallback = func;
                GetIDFACallback.Call(SystemInfo.deviceUniqueIdentifier);
            }
            else{
                sdk.GetIDFA();
                GetIDFACallback = func;
            }
        }

        public string GetUUID()
        {
            return sdk.GetUUID();
        }

        public string GetStoreID()
        {
            return sdk.GetStoreID();
        }

        public void OpenAlbum(LuaFunction func)
        {
            sdk.OpenAlbum();
            GetImageCallBack = func;
        }

        public void OpenPhoto(LuaFunction func)
        {
            sdk.OpenPhoto();
            GetImageCallBack = func;
        }

        public void CopyTextToClipboard(string text)
        {
            sdk.CopyTextToClipboard(text);
        }

        public void JumpToWX()
        {
            sdk.JumpToWX();
        }

        public void InstallAPK(string path)
        {
            sdk.InstallAPK(path);
        }

        public void OpenWebView(string webUrl, LuaFunction onMessageReceivedFunc)
        {
            onMessageReceived = onMessageReceivedFunc;
            sdk.OpenWebView(webUrl);
        }

        public void Alipay(string orderInfo)
        {
            sdk.Alipay(orderInfo);
        }

        public void WechatPay(string partnerId, string prepayId, string noncestr, string timeStamp, string sign)
        {
            sdk.WechatPay(partnerId, prepayId, noncestr, timeStamp, sign);
        }

        public void WechatLogin(LuaFunction func)
        {
            GetWXLoginCallback = func;
            sdk.WechatLogin();
        }

        public void InAppPurchases(string productId, string orderInfo, LuaFunction func)
        {
            sdk.InAppPurchases(productId, orderInfo);
            InAppPurchasesCallback = func;
        }

        public void WechatShareWebpage(int type, string url, string title, string description)
        {
            sdk.WechatShareWebpage(type, url, title, description);
        }

        public void PostImage(string url,Sprite sprite,string mid,string sig,LuaFunction callback)
        {
            Byte[] spByte = sprite.texture.EncodeToJPG();

            WWWForm form = new WWWForm();
            form.AddField("mid", mid);
            form.AddField("sig", sig);
            form.AddBinaryData("micon", spByte);
            StartCoroutine(PostToUrl(url,form,callback));
        }

        public IEnumerator PostToUrl(string url, WWWForm form, LuaFunction callback)
        {
            WWW www = new WWW(url, form);
            yield return www;
            if(www.error != null)
            {
                Debug.Log("成功");
                callback.Call(false,www.text);
            }
            else
            {
                Debug.Log("失败");
                callback.Call(true,www.text);
            }
        }

        public IEnumerator LoadTextureFromLocal(string relativePath, Action<Texture2D> callback)
        {
            if (!string.IsNullOrEmpty(relativePath) && callback != null)
            {
                //从本地获取，file://xxx
                string localPath = "file://" + Application.persistentDataPath + relativePath;

                Debug.Log("LoadTexture at local " + localPath);

                WWW www = new WWW(localPath);
                yield return www;
                if (www.error != null)
                {
                    Debug.LogError("加载本地图片失败;" + www.error);
                    callback(null);
                }
                else
                {
                    Debug.LogError("加载本地图片成功;");
                    Texture2D tex = www.texture;
                    callback(tex);
                }
            }
        }

        /**
            以下都是原生回调 
         */
        public void NativeErrorCallback(string error)
        {
            AppFacade.Instance.GetManager<LuaManager>(ManagerName.Lua).CallLuaNativeErrorCallback(error);
        }

        public void IEMICallback(string iemi)
        {
            GetIMEICallback.Call(iemi);
        }

        public void IDFACallback(string idfa)
        {
            GetIDFACallback.Call(idfa);
        }

        public void GetImage(string imagePath)
        {
            Debug.Log("获取图片回调");
            Debug.Log(imagePath);
            string TEMP_IMAGE = "/images/temp.png";
            if (Application.platform == RuntimePlatform.IPhonePlayer)
            {
                TEMP_IMAGE = "/temp.png";
            }
            //这里需要通过携程去加载本地文件
            StartCoroutine(LoadTextureFromLocal(TEMP_IMAGE, delegate (Texture2D texture)
            {
                Sprite sprite = Sprite.Create(texture, new Rect(0, 0, texture.width, texture.height), new Vector2(0.5f, 0.5f));
                GetImageCallBack.Call(sprite);
            }));
        }

        public void GetWXLogin(string code)
        {
            Debug.Log("获取微信登录回调");
            Debug.Log(code);
            GetWXLoginCallback.Call(code);
        }

        public void GetInAppPurchasesCallback(string jsonString)
        {   
            InAppPurchasesCallback.Call(jsonString);
        }

        public void UrlCallbcak(string command)
        {
            Debug.Log(command);
            if(command == "close")
            {
                //TODO 关闭浏览器命令暂不需要处理
            }
            else
            {
                onMessageReceived.Call(command);
            }
        }

        
        /** 
        * OPPO相关
        * 开始
        */  

        public LuaFunction LuaOPPOLoginCallback;
        public void OPPOLogin(LuaFunction func) {
            LuaOPPOLoginCallback = func;
            sdk.OPPOLogin();
        }
        public void OPPOLoginCallback(string resultString) {
            LuaOPPOLoginCallback.Call(resultString);
        }


        public LuaFunction LuaOPPOPayCallback;
        public void OPPOPay(string order, string attach, int amount, string desc, string name, string url, LuaFunction func) {
            LuaOPPOPayCallback = func;
            sdk.OPPOPay(order, attach, amount, desc, name, url);
        }

        public void OPPOPayCallback(string resultString) {
            LuaOPPOPayCallback.Call(resultString);
        }

        public LuaFunction LuaOPPOExitCallback;
        public void OPPOExit(LuaFunction func) {
            LuaOPPOExitCallback = func;
            sdk.OPPOExit();
        }
        public void OPPOExitCallback(string resultString) {
            LuaOPPOExitCallback.Call(resultString);
        }


        /** 
        * VIVO相关
        * 开始
        */  

        public LuaFunction LuaVIVOLoginCallback;
        public void VIVOLogin(LuaFunction func) {
            LuaVIVOLoginCallback = func;
            sdk.VIVOLogin();
        }
        public void VIVOLoginCallback(string resultString) {
            LuaVIVOLoginCallback.Call(resultString);
        }


        public LuaFunction LuaVIVOPayCallback;
        public void VIVOWXPay(string order, string attach, int amount, string desc, string name, LuaFunction func) {
            LuaVIVOPayCallback = func;
            sdk.VIVOWXPay(order, attach, amount, desc, name);
        }

        public void VIVOAliPay(string order, string attach, int amount, string desc, string name, LuaFunction func) {
            LuaVIVOPayCallback = func;
            sdk.VIVOAliPay(order, attach, amount, desc, name);
        }


        public void VIVOPayCallback(string resultString) {
            LuaVIVOPayCallback.Call(resultString);
        }

        public LuaFunction LuaVIVOExitCallback;
        public void VIVOExit(LuaFunction func) {
            LuaVIVOExitCallback = func;
            sdk.VIVOExit();
        }
        public void VIVOExitCallback(string resultString) {
            LuaVIVOExitCallback.Call(resultString);
        }

        /** 
        * 爱贝相关
        * 开始
        */ 

        public LuaFunction LuaIAppPayPayCallback;
        public void IAppPayWXPay(string paramsString, LuaFunction func) {
            LuaIAppPayPayCallback = func;
            sdk.IAppPayWXPay(paramsString);
        }

        public void IAppPayAliPay(string paramsString, LuaFunction func) {
            LuaIAppPayPayCallback = func;
            sdk.IAppPayAliPay(paramsString);
        }

        public void IAppPayPayCallback(string resultString) {
            LuaIAppPayPayCallback.Call(resultString);
        }
        
    }
}