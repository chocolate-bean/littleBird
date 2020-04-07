using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEditor;
using UnityEngine.UI;
using System.IO;

class GetText : EditorWindow
{
    [MenuItem("Tools/提取全部文本")]
    static void OneKeyChangeFont()
    {
        string[] guids = AssetDatabase.FindAssets("t:Prefab", new string[] { "Assets/Resources/Prefabs" });
        if (guids != null && guids.Length > 0)
        {
            EditorUtility.DisplayProgressBar("Replacing...", "Start replace", 0);
            int progress = 0;
            List<string> texts = new List<string>();
            foreach (string guid in guids)
            {
                progress++;
                string path = AssetDatabase.GUIDToAssetPath(guid);
                EditorUtility.DisplayProgressBar("Replacing....", path, ((float)progress / guids.Length));
                GameObject obj = AssetDatabase.LoadAssetAtPath(path, typeof(GameObject)) as GameObject;

                bool isChanged = false;
                Text[] lblist = obj.GetComponentsInChildren<Text>(true);
                foreach (Text item in lblist)
                {
                    ContentSizeFitter cs = item.gameObject.GetComponent<ContentSizeFitter>();
                    if(cs == null)
                    {
                        cs = item.gameObject.AddComponent<ContentSizeFitter>();
                        cs.horizontalFit = ContentSizeFitter.FitMode.PreferredSize;
                        cs.verticalFit = ContentSizeFitter.FitMode.PreferredSize;
                    }

                    isChanged = true;
                }
                if (isChanged)
                {
                    EditorUtility.SetDirty(obj);
                    AssetDatabase.SaveAssets();
                }
                EditorUtility.ClearProgressBar();
            }
            File.WriteAllLines("Assets/Editor/AutoText/TEXTS.txt", texts.ToArray());
        }
    }
}

