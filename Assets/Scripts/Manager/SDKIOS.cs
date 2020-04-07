using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Linq;
using System.Text;
using UnityEngine;

namespace LuaFramework
{
#if UNITY_IOS && !UNITY_EDITOR
    public class SDKIOS : SDKBase
    {
        [DllImport("__Internal")]
        private static extern void IOS_IDFA(string gameObjectName);
        [DllImport("__Internal")]
        private static extern void IOS_IDFV(string gameObjectName);
        [DllImport("__Internal")]
        private static extern void IOS_OpenCamera(string gameObjectName);
        [DllImport("__Internal")]
        private static extern void IOS_OpenAlbum(string gameObjectName);
        [DllImport("__Internal")]
        private static extern bool IOS_OpenURL(string gameObjectName, string urlString);
        [DllImport("__Internal")]
        private static extern bool IOS_CopyTextToClipboard(string gameObjectName, string text);
        [DllImport("__Internal")]
        private static extern void IOS_WechatLogin(string gameObjectName);
        [DllImport("__Internal")]
        private static extern void IOS_WechatShareWebpage(string gameObjectName, int type, string url, string title, string description);
#if APPLE_OFFICIAL
#else
        // 这个宏主要用于区分 iOS appleStore的
        [DllImport("__Internal")]
        private static extern void IOS_WechatPay(string gameObjectName, string partnerId, string prepayId, string noncestr, string timeStamp, string sign);
        [DllImport("__Internal")]
        private static extern void IOS_AliPay(string gameObjectName, string orderInfo);
#endif
        [DllImport("__Internal")]
        private static extern void IOS_InAppPurchases(string gameObjectName, string productId, string orderInfo);

        public SDKIOS(string gameObjectName) : base(gameObjectName)
        {
            this.gameObjectName = gameObjectName;
        }

        public override void Init()
        {
            Debug.Log("InitSDKIOS");
        }

        public override void GetIMEI()
        {
            IOS_IDFV(this.gameObjectName);
        }

        public override void GetIDFA()
        {
            IOS_IDFA(this.gameObjectName);
        }

        public override string GetUUID()
        {
            return SystemInfo.deviceUniqueIdentifier;
        }

        public override string GetStoreID()
        {
            return SystemInfo.deviceUniqueIdentifier;
        }

        public override void OpenAlbum()
        {
            IOS_OpenAlbum(this.gameObjectName);
        }

        public override void OpenPhoto()
        {
            IOS_OpenCamera(this.gameObjectName);
        }

        public override void Alipay(string orderInfo)
        {
#if APPLE_OFFICIAL
            Debug.Log("APPLE_OFFICIAL,Can not Alipay");
#else
            IOS_AliPay(this.gameObjectName, orderInfo);
#endif
        }

        public override void WechatPay(string partnerId, string prepayId, string noncestr, string timeStamp, string sign)
        {
#if APPLE_OFFICIAL
            Debug.Log("APPLE_OFFICIAL,Can not WechatPay");
#else
            IOS_WechatPay(this.gameObjectName, partnerId, prepayId, noncestr, timeStamp, sign);
#endif
        }

        public override void WechatLogin()
        {
            IOS_WechatLogin(this.gameObjectName);
        }

        public override void InAppPurchases(string productId, string orderInfo)
        {
            IOS_InAppPurchases(this.gameObjectName, productId, orderInfo);
        }

        public override void WechatShareWebpage(int type, string url, string title, string description)
        {
            //WXSceneSession          = 0,   /**< 聊天界面    */
            //WXSceneTimeline         = 1,   /**< 朋友圈     */
            //WXSceneFavorite         = 2,   /**< 收藏       */
            //WXSceneSpecifiedSession = 3,   /**< 指定联系人  */
            IOS_WechatShareWebpage(this.gameObjectName, type, url, title, description);
        }

        public override void CopyTextToClipboard(string text)
        {
            IOS_CopyTextToClipboard(this.gameObjectName, text);
        }

        public override void JumpToWX()
        {
            bool isSuccess = IOS_OpenURL(this.gameObjectName, "weixin://");
            if (isSuccess) {
                Debug.Log("跳转到微信成功");
            } else {
                Debug.Log("跳转到微信失败");
            }
        }

        public override void InstallAPK(string path)
        {
            Debug.Log("Editor or Win,Can not InstallAPK");
        }

        public override void OpenWebView(string url)
        {
            base.OpenWebView(url);
        }

        public override int GetSystemVersion()
        {
            //???
            return 0;
        }
    }
#endif
}
