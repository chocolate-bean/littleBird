using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using System.Reflection;
using System.Runtime.InteropServices;

namespace LuaFramework
{
    public class SDKBase
    {
        public string gameObjectName;
        public SDKBase(string gameObjectName)
        {
            this.gameObjectName = gameObjectName;
        }

        public virtual void Init()
        {
            Debug.Log("InitSDKBase");
        }

        public virtual void GetIMEI()
        {
            Debug.Log("Editor or Win,Can not GetIMEI");
        }

        public virtual void GetIDFA()
        {
            Debug.Log("Editor or Win,Can not GetIDFA");
        }

        public virtual string GetUUID()
        {
            return SystemInfo.deviceUniqueIdentifier;
        }

        public virtual string GetStoreID()
        {
            return SystemInfo.deviceUniqueIdentifier;
        }

        public virtual void OpenAlbum()
        {
            Debug.Log("Editor or Win,Can not OpenAlbum");
        }

        public virtual void OpenPhoto()
        {
            Debug.Log("Editor or Win,Can not OpenPhoto");
        }

        public virtual void Alipay(string orderInfo)
        {
            Debug.Log("Editor or Win,Can not Alipay");
        }

        public virtual void WechatPay(string partnerId, string prepayId, string noncestr, string timeStamp, string sign)
        {
            Debug.Log("Editor or Win,Can not WechatPay");
        }

        public virtual void WechatLogin()
        {
            Debug.Log("Editor or Win,Can not WechatLogin");
        }
        
        public virtual void InAppPurchases(string productId, string orderInfo)
        {
            Debug.Log("Editor or Win,Can not InAppPurchases");
        }

        public virtual void WechatShareWebpage(int type, string url, string title,string description)
        {
            Debug.Log("Editor or Win,Can not ShareWebpage");
        }

        public virtual void CopyTextToClipboard(string text)
        {
            Debug.Log("Editor or Win,Can not CopyTextToClipboard");
        }

        public virtual void JumpToWX()
        {
            Debug.Log("Editor or Win,Can not JumpToWX");
        }

        public virtual void InstallAPK(string path)
        {
            Debug.Log("Editor or Win,Can not InstallAPK");
        }

        public virtual void OpenWebView(string url)
        {
#if UNITY_EDITOR_WIN
            Application.OpenURL(url);
#else
            //调用第三方
            GameObject obj = new GameObject("UniWebView");
            UniWebView webView = obj.AddComponent<UniWebView>();
            // webView.SetShowToolbar(true);
            webView.Frame = new Rect(0, 0, Screen.width, Screen.height);
            webView.AddUrlScheme("thumbp");
            webView.OnMessageReceived += (view, message) => {
                UnityEngine.Object.Destroy(obj);
                AppFacade.Instance.GetManager<SDKManager>(ManagerName.SDK).UrlCallbcak(message.Path);
            };

            webView.Load(url);
            webView.Show();
#endif
        }

        public virtual int GetSystemVersion(){
            return 0;
        }

        public virtual void OPPOLogin() {
            Debug.Log("Editor or Win,Can not OPPOLogin");
        }

        public virtual void OPPOPay(string order, string attach, int amount, string desc, string name, string url) {
            Debug.Log("Editor or Win,Can not OPPOPay");
        }

        public virtual void OPPOExit() {
            Debug.Log("Editor or Win,Can not OPPOExit");
        }

        public virtual void VIVOLogin() {
            Debug.Log("Editor or Win,Can not VIVOLogin");
        }

        public virtual void VIVOWXPay(string order, string attach, int amount, string desc, string name) {
            Debug.Log("Editor or Win,Can not VIVOWXPay");
        }

        public virtual void VIVOAliPay(string order, string attach, int amount, string desc, string name) {
            Debug.Log("Editor or Win,Can not VIVOAliPay");
        }

        public virtual void VIVOExit() {
            Debug.Log("Editor or Win,Can not VIVOExit");
        }

        public virtual void IAppPayWXPay(string paramsString) {
            Debug.Log("Editor or Win,Can not VIVOWXPay");
        }

        public virtual void IAppPayAliPay(string paramsString) {
            Debug.Log("Editor or Win,Can not VIVOAliPay");
        }


    }
}