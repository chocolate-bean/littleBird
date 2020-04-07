using LuaInterface;
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEngine.Networking;
using UnityEngine.UI;

namespace LuaFramework
{
    public class WWWManager : Manager
    {
        string APKPath;
        // Use this for initialization
        void Start()
        {

        }

        // Update is called once per frame
        void Update()
        {

        }

        public void LoadImage(string url, LuaFunction callback)
        {
            StartCoroutine(DownLoadImage(url, callback, false));
            // LocalDownLoadImage(url, callback, false);
        }

        public void LoadAndCacheImage(string url, LuaFunction callback, bool isCache = true)
        {
            string hash = CSharpTools.md5(url);
            string path = Application.persistentDataPath + "/" + hash + ".png";

            if (File.Exists(path))
            {
                string wwwPath = "file://" + path;
                StartCoroutine(LoadImageFromPath(url, callback));
            }
            else
            {
                StartCoroutine(DownLoadImage(url, callback, isCache));
                // LocalDownLoadImage(url, callback, false);
            }
        }

        public IEnumerator LoadImageFromPath(string url, LuaFunction callback)
        {
            WWW www = new WWW(url);
            yield return www;
            if (www.error != null)
            {
                callback.Call(false, url);
            }
            else
            {
                Texture2D texture = www.texture;
                Sprite sprite = Sprite.Create(texture, new Rect(0, 0, texture.width, texture.height), new Vector2(0.5f, 0.5f));
                callback.Call(true, sprite);
            }
        }

        public IEnumerator DownLoadImage(string url, LuaFunction callback, bool isCache)
        {
            WWW www = new WWW(url);
            yield return www;
            if (www.error != null)
            {
                callback.Call(false, url);
            }
            else
            {
                Texture2D texture = www.texture;
                Sprite sprite = Sprite.Create(texture, new Rect(0, 0, texture.width, texture.height), new Vector2(0.5f, 0.5f));
                callback.Call(true, sprite);

                if (isCache)
                {
                    string hash = CSharpTools.md5(url);
                    string path = Application.persistentDataPath + "/" + hash + ".png";
                    byte[] bytes = texture.EncodeToPNG();
                    File.WriteAllBytes(path, bytes);
                }
            }
        }

        public void LocalDownLoadImage(string url, LuaFunction callback, bool isCache)
        {
            using(WWW www = new WWW(url))
            {
                while(!www.isDone){
                }
                    if (www.error != null)
                    {
                        callback.Call(false, url);
                    }
                    else
                    {
                        Texture2D texture = www.texture;
                        Sprite sprite = Sprite.Create(texture, new Rect(0, 0, texture.width, texture.height), new Vector2(0.5f, 0.5f));
                        callback.Call(true, sprite);

                        if (isCache)
                        {
                            string hash = CSharpTools.md5(url);
                            string path = Application.persistentDataPath + "/" + hash + ".png";
                            byte[] bytes = texture.EncodeToPNG();
                            File.WriteAllBytes(path, bytes);
                        }
                    }
            }
        }

        public void RequestHttpGET(string url, LuaFunction callback)
        {
            StartCoroutine(StartHTTPGET(url, callback));
        }

        public void RequestHttpPOST(string url, WWWForm form, LuaFunction callback)
        {
            StartCoroutine(StartHTTPPOST(url, form, callback));
        }

        public void StopHttp()
        {
            StopAllCoroutines();
        }

        public IEnumerator StartHTTPGET(string url, LuaFunction callback)
        {
            using (UnityWebRequest www = UnityWebRequest.Get(url))
            {
                www.timeout = 3;
                yield return www.SendWebRequest();
                callback.Call(www.isNetworkError, www.downloadHandler.text);
            }
        }

        public IEnumerator StartHTTPPOST(string url, WWWForm form, LuaFunction callback)
        {

            using (UnityWebRequest www = UnityWebRequest.Post(url, form))
            {
                www.timeout = 3;
                yield return www.SendWebRequest();
                callback.Call(www.isNetworkError, www.downloadHandler.text);
            }
        }

        public void DownloadAPK(string url, string md5)
        {
            string hash = CSharpTools.md5(url);
            string path = Application.persistentDataPath + "/" + hash + ".apk";
            APKPath = path;

            // 如果已经下载完了就安装，没有就重新下载
            if (File.Exists(APKPath))
            {
                if(CSharpTools.getFileHash(APKPath) == md5)
                {
                    InstallAPK(APKPath);
                }
                else
                {
                    StartCoroutine(StatrtDownloadAPK(url, md5));
                }
                
            }
            else
            {
                StartCoroutine(StatrtDownloadAPK(url, md5));
            }
        }

        public IEnumerator StatrtDownloadAPK(string url, string md5)
        {
            Text progressName = GameObject.Find("progressName").GetComponent<Text>();
            progressName.text = "正在下载中...";
            Slider progressBar = GameObject.Find("progressBar").GetComponent<Slider>();

            using (UnityWebRequest request = UnityWebRequest.Get(url))
            {
                request.SendWebRequest();
                while (!request.isDone)
                {
                    Debug.Log(request.downloadProgress);
                    progressBar.value = request.downloadProgress;
                    progressName.text = "正在下载中..." + Math.Floor(request.downloadProgress * 100) + "%";
                    yield return 1;
                }

                progressBar.value = 1;
                progressName.text = "正在下载中...100%";
                Debug.Log("下载完成");

                if (request.isDone)
                {
                    byte[] bytes = request.downloadHandler.data;
                    CreatFile(bytes);
                    InstallAPK(APKPath);
                    //if (CSharpTools.getFileHash(APKPath) == md5)
                    //{
                    //    InstallAPK(APKPath);
                    //}
                    //else
                    //{
                    //    StartCoroutine(StatrtDownloadAPK(url, md5));
                    //}
                }
            }
        }

        public void CreatFile(byte[] bytes)
        {
            Stream stream;
            //text_test.GetComponent<Text>().text = holdPath;
            Debug.Log("下载地址" + APKPath);
            FileInfo file1 = new FileInfo(APKPath);
            stream = file1.Create();
            stream.Write(bytes, 0, bytes.Length);
            stream.Close();
            stream.Dispose();
        }

        public void InstallAPK(string path)
        {
            Debug.Log("准备安装...");
            try
            {
                var Intent = new AndroidJavaClass("android.content.Intent");
                var ACTION_VIEW = Intent.GetStatic<string>("ACTION_VIEW");
                var FLAG_ACTIVITY_NEW_TASK = Intent.GetStatic<int>("FLAG_ACTIVITY_NEW_TASK");
                var intent = new AndroidJavaObject("android.content.Intent", ACTION_VIEW);

                var file = new AndroidJavaObject("java.io.File", path);
                var Uri = new AndroidJavaClass("android.net.Uri");
                var uri = Uri.CallStatic<AndroidJavaObject>("fromFile", file);

                intent.Call<AndroidJavaObject>("setDataAndType", uri, "application/vnd.android.package-archive");
                intent.Call<AndroidJavaObject>("addFlags", FLAG_ACTIVITY_NEW_TASK);
                intent.Call<AndroidJavaObject>("setClassName", "com.android.packageinstaller", "com.android.packageinstaller.PackageInstallerActivity");

                var UnityPlayer = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
                var currentActivity = UnityPlayer.GetStatic<AndroidJavaObject>("currentActivity");
                currentActivity.Call("startActivity", intent);
            }
            catch (System.Exception e)
            {
                try
                {
                    AppFacade.Instance.GetManager<SDKManager>(ManagerName.SDK).InstallAPK(path);
                }
                catch (System.Exception)
                {
                    Debug.Log("安装失败");
                }
            }

        }
    }
}
