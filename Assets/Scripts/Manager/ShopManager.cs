#if GP
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Purchasing;
using LuaInterface;
using UnityEngine.Purchasing.Security;

namespace LuaFramework
{
    /// <summary>
    /// 这是通用方式，通过读取catalog里面的信息，获取所有商品信息
    /// </summary>
    public class ShopManager : Manager, IStoreListener
    {
        private static IStoreController m_StoreController;
        private static IExtensionProvider m_StoreExtensionProvider;
        LuaFunction onBuyProductCallBcak;

        void Start()
        {
            InitializePurchasing();
        }
        private bool IsInitialized()
        {
            return m_StoreController != null && m_StoreExtensionProvider != null;
        }
        //初始化内购项目，主要是从catalog中获取商品信息，设置给 UnityPurchasing
        void InitializePurchasing()
        {
            if (IsInitialized())
            {
                Debug.Log("初始化失败");
                return;
            }
            StandardPurchasingModule module = StandardPurchasingModule.Instance();
            module.useFakeStoreUIMode = FakeStoreUIMode.StandardUser;
            ConfigurationBuilder builder = ConfigurationBuilder.Instance(module);
            //通过编辑器中的Catalog添加，方便操作
            ProductCatalog catalog = ProductCatalog.LoadDefaultCatalog();
            // Debug.Log(catalog.allProducts.Count);
            foreach (var product in catalog.allProducts)
            {
                if (product.allStoreIDs.Count > 0)
                {
                    // Debug.Log("product:" + product.id);
                    var ids = new IDs();
                    foreach (var storeID in product.allStoreIDs)
                    {
                        ids.Add(storeID.id, storeID.store);
                        // Debug.Log("stordId:" + storeID.id  + ", " + storeID.store);
                    }
                    builder.AddProduct(product.id, product.type, ids);
                }
                else
                {
                    builder.AddProduct(product.id, product.type);
                }
            }
            UnityPurchasing.Initialize(this, builder);
        }

        //提供给lua调用
        public void OnShopInit(LuaFunction func)
        {
            Debug.Log("Lua Init IAP");
            onBuyProductCallBcak = func;
        }
        public void OnBuyCoins(string productID,string orderId)
        {
            Debug.Log("Lua Call IAP Buy");
            BuyProductID(productID, orderId);
        }

        //这里是通过商品id购买物品
        private void BuyProductID(string productId,string orderId)
        {
            if (IsInitialized())
            {
                Debug.Log("Buy ProductID: " + productId);
                Product product = m_StoreController.products.WithID(productId);
                if (product != null && product.availableToPurchase)
                {
                    Debug.Log(string.Format("Purchasing product asychronously: '{0}'", product.definition.id));
                    m_StoreController.InitiatePurchase(product, orderId);
                }
                else
                {
                    Debug.Log("BuyProductID: FAIL. Not purchasing product, either is not found or is not available for purchase");
                }
            }
            else
            {
                Debug.Log("没出初始化");
            }
        }
        //初始化回调
        public void OnInitialized(IStoreController controller, IExtensionProvider extensions)
        {
            //初始化成功
            Debug.Log("OnInitialized: PASS");
            m_StoreController = controller;
            m_StoreExtensionProvider = extensions;
        }
        public void OnInitializeFailed(InitializationFailureReason error)
        {
            //初始化失败
            Debug.Log("OnInitializeFailed InitializationFailureReason:" + error);
            if (error == InitializationFailureReason.AppNotKnown)
            {
                Debug.Log("AppNotKnown");
            }
            else if (error == InitializationFailureReason.NoProductsAvailable)
            {
                Debug.Log("NoProductsAvailable");
            }
            else if (error == InitializationFailureReason.PurchasingUnavailable)
            {
                Debug.Log("PurchasingUnavailable");
            }
        }
        //购买成功后的回调，包括restore的商品
        public PurchaseProcessingResult ProcessPurchase(PurchaseEventArgs args)
        {
            string productID = args.purchasedProduct.definition.id;
            //onBuyProductCallBcak.Call(true, args.purchasedProduct.transactionID, args.purchasedProduct.receipt);
            //Debug.Log("IAP:" + args.purchasedProduct.receipt);
            //这里要取出receipt的数据给PHP做二次验证
            Dictionary<string, object> wrapper = (Dictionary<string, object>)MiniJson.JsonDecode(args.purchasedProduct.receipt);

            string store = (string)wrapper["Store"];
            string payload = (string)wrapper["Payload"];
#if UNITY_EDITOR
            Debug.Log("IAP:" + args.purchasedProduct.receipt);
#elif UNITY_ANDROID
            Debug.Log("IAP receipt:" + args.purchasedProduct.receipt);

            Dictionary<string, object> gpDetails = (Dictionary<string, object>)MiniJson.JsonDecode(payload);

            string gpJson = (string)gpDetails["json"];
            string gpSig  = (string)gpDetails["signature"];
            string id = args.purchasedProduct.definition.id;

            Debug.Log("IAP gpJson:" + gpJson);
            Debug.Log("IAP gpSig:" + gpSig);
            Debug.Log("IAP id:" + id);

            onBuyProductCallBcak.Call(true, gpJson, gpSig);
#elif UNITY_IPHONE
            onBuyProductCallBcak.Call();
#endif
            return PurchaseProcessingResult.Complete;
        }
        //购买失败回调，根据具体情况给出具体的提示
        public void OnPurchaseFailed(Product product, PurchaseFailureReason failureReason)
        {
            //支付失败
            Debug.Log(string.Format("OnPurchaseFailed: FAIL. Product: '{0}', PurchaseFailureReason: {1}", product.definition.storeSpecificId, failureReason));
            #region 支付失败原因
            if (failureReason == PurchaseFailureReason.UserCancelled)
            {
                //用户取消交易
                Debug.Log("UserCancelled");
            }
            else if (failureReason == PurchaseFailureReason.ExistingPurchasePending)
            {
                //上一笔交易还未完成
                Debug.Log("ExistingPurchasePending");
            }
            else if (failureReason == PurchaseFailureReason.PaymentDeclined)
            {
                //拒绝付款
                Debug.Log("PaymentDeclined");
            }
            else if (failureReason == PurchaseFailureReason.ProductUnavailable)
            {
                //商品不可用
                Debug.Log("ProductUnavailable");
            }
            else if (failureReason == PurchaseFailureReason.PurchasingUnavailable)
            {
                //支付不可用
                Debug.Log("PurchasingUnavailable");
            }
            else
            {
                //位置错误
                Debug.Log("OnPurchaseFailed without Error");
            }
            #endregion
            Debug.Log("IAP Buy Fail");
            onBuyProductCallBcak.Call(false,"","");
        }

        public ProductMetadata getProductMetadata(string productName)
        {
#if UNITY_EDITOR
            return null;
#else
            if (IsInitialized())
            {
                ProductMetadata mataData = m_StoreController.products.WithID(productName).metadata;
                Debug.Log(mataData.isoCurrencyCode);
                Debug.Log(mataData.localizedDescription);
                Debug.Log(mataData.localizedPriceString);
                return mataData;
            }
            else
            {
                Debug.Log("初始化失败");
                return null;
            }
#endif
        }
    }
}
#else
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace LuaFramework
{
    /// <summary>
    /// 这是通用方式，通过读取catalog里面的信息，获取所有商品信息
    /// </summary>
    public class ShopManager : Manager
    {
    }
}
#endif