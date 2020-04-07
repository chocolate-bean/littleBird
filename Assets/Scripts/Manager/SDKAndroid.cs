using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using UnityEngine;

namespace LuaFramework
{
    public class SDKAndroid : SDKBase
    {        private AndroidJavaObject jc;
        private AndroidJavaObject jo;
        public SDKAndroid(string gameObjectName):base(gameObjectName)
        {
            //要调用的java类名
            string className = "com.thumbp.androidhelper.androidhelper";
            if(AppConst.channelType == ChannelType.DBBY){
                className = "com.zxq.androidhelper.androidhelper";
            }

            AndroidJavaClass jc = new AndroidJavaClass(className);
            jo = jc.CallStatic<AndroidJavaObject>("GetInstance", gameObjectName);
            this.gameObjectName = gameObjectName;
        }


        public override void Init()
        {
            Debug.Log("InitSDKAndroid");
        }

        public override void GetIMEI()
        {
            jo.Call("getIMEI");
        }

        public override void GetIDFA()
        {
            Debug.Log("Andorid,Can not GetIDFA");
        }

        

        public override string GetUUID()
        {
            string UUID = jo.Call<string>("GetUUID").ToString();
            return UUID;
        }

        public override string GetStoreID()
        {
            string StoreID = jo.Call<string>("GetUUID").ToString();
            return StoreID;
        }

        public override void OpenAlbum()
        {
            jo.Call("openAlbum");
        }

        public override void OpenPhoto()
        {
            jo.Call("openCamera");
        }
            
        public override void Alipay(string orderInfo)
        {
            jo.Call("alipay", orderInfo);
        }

        public override void WechatPay(string partnerId, string prepayId, string noncestr, string timeStamp, string sign)
        {
            jo.Call("wxpay", partnerId, prepayId, noncestr, timeStamp, sign, AppConst.wxAppID);
        }


        public override void WechatLogin()
        {
            jo.Call("wxlogin", AppConst.wxAppID);
        }

        public override void WechatShareWebpage(int type, string url, string title, string description)
        {
            jo.Call("wxwebpage", type, url, title, description, AppConst.wxAppID);
        }

        public override void InAppPurchases(string productId, string orderInfo)
        {
            Debug.Log("Andorid, Can not InAppPurchases");
        }

        public override void CopyTextToClipboard(string text)
        {
            jo.Call("CopyTextToClipboard", text);
        }

        public override void JumpToWX()
        {
            jo.Call("JumpToWX");
        }

        public override void InstallAPK(string path)
        {
            jo.Call("InstallAPK", path);
        }

        public override void OpenWebView(string url)
        {
            // if (GetSystemVersion() >= 21)
            // {
            //     //调用第三方
            //     GameObject obj = new GameObject("UniWebView");
            //     UniWebView webView = obj.AddComponent<UniWebView>();
            //     // webView.SetShowToolbar(true);
            //     webView.Frame = new Rect(0, 0, Screen.width, Screen.height);
            //     webView.AddUrlScheme("thumbp");
            //     webView.OnMessageReceived += (view, message) => {
            //         UnityEngine.Object.Destroy(obj);
            //         AppFacade.Instance.GetManager<SDKManager>(ManagerName.SDK).UrlCallbcak(message.Path);
            //     };
            //     webView.OnPageStarted += (view, newURL) => {
            //         Debug.LogFormat("Csharp OnPageStarted: -->>>>>>> {0}", newURL);
            //         if (newURL.StartsWith("weixin://") || newURL.StartsWith("alipay://")) {
            //         Debug.LogFormat("Csharp Destory will open weixin or alipay: -->>>>>>> {0}", newURL);
            //             UnityEngine.Object.Destroy(obj);
            //             jo.Call("openWebView", newURL);
            //         }
            //     };
            //     webView.OnShouldClose += (view) => {
            //         view.CleanCache();
            //         view = null;
            //         return true;
            //     };
 
            //     webView.SetBackButtonEnabled(false);// 回退钮  物理按键

            //     webView.Load(url);
            //     webView.Show();
            // }
            // else
            // {
            //     //调用自己写的
            // }
            jo.Call("openWebView", url);
        }

        public override int GetSystemVersion()
        {
            int version = jo.Call<int>("GetAndroidVersion");
            return version;
        }


        public override void OPPOLogin() {
            jo.Call("OPPOLogin");
        }

        public override void OPPOPay(string order, string attach, int amount, string desc, string name, string url) {
            jo.Call("OPPOPay", order, attach, amount, desc, name, url);
        }

        public override void OPPOExit() {
            jo.Call("OPPOExit");
        }

        public override void VIVOLogin() {
            jo.Call("VIVOLogin");
        }

        public override void VIVOExit() {
            jo.Call("VIVOExit");
        }

        public override void VIVOWXPay(string order, string attach, int amount, string desc, string name) {
            jo.Call("VIVOWXPay", order, attach, amount, desc, name);
        }

        public override void VIVOAliPay(string order, string attach, int amount, string desc, string name) {
            jo.Call("VIVOAliPay", order, attach, amount, desc, name);
        }

        public override void IAppPayWXPay(string paramsString) {
            jo.Call("IAppPayWXPay", paramsString);
        }

        public override void IAppPayAliPay(string paramsString) {
            jo.Call("IAppPayAliPay", paramsString);
        }
    }
}
