using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System;
using System.IO;
using System.Security.Cryptography;
using LuaFramework;

public class ChannelSwitch: EditorWindow {

    static string[] pathList = new string[] {
        @"Fonts",
        @"Images",
        @"Plugins",
        @"Resources",
        @"Sence",
    };

    // 排除的文件夹列表
    static string[] outSidePath = new string[] {
        "x86_64"
    };

    [MenuItem("ChannelSwitch/打开工具窗口")]
    static void OpenWindow() {
        EditorWindow.GetWindowWithRect(typeof(ChannelSwitch), new Rect(0, 0, 500, 500));
    }

    bool isBackup = false;
    bool isCustom = false;
    ChannelType channelType = AppConst.channelType;
    String channelFolder = AppConst.sidConfig.GetChannelFolder(AppConst.channelType);

    private void OnGUI() {
        GUILayout.Space(20);
        isBackup = EditorGUILayout.Toggle(isBackup ? "当前您选中的是备份" : "当前您选中的是还原", isBackup);
        if (isBackup) {
            // 猜测当前包是什么
            EditorGUILayout.LabelField("当前渠道所采用的路径为: " + channelFolder);
            GUILayout.Space(10);
            isCustom = EditorGUILayout.Toggle(isCustom ? "使用自定义路径" : "使用默认路径", isCustom);
            if (isCustom) {
                GUILayout.Space(10);
                channelType = (ChannelType)EditorGUILayout.EnumPopup(channelType);
                channelFolder = EnumExtension.GetChannelTypeAttribute(channelType).ChannelFolder;
            } else {
                channelFolder = AppConst.sidConfig.GetChannelFolder(AppConst.channelType);
            }
            GUILayout.Space(10);
            if (GUILayout.Button("将当前资源备份到该路径下")) {
                BackupCurChannel(channelFolder);
            }
            GUILayout.Space(20);
        } else {
            EditorGUILayout.LabelField("选择要恢复的路径");
            GUILayout.Space(10);
            channelType = (ChannelType)EditorGUILayout.EnumPopup(channelType);
            channelFolder = EnumExtension.GetChannelTypeAttribute(channelType).ChannelFolder;
            GUILayout.Space(10);
            if (GUILayout.Button("从 " + channelFolder + " 路径下恢复")) {
                ResetTOChannel(channelFolder);
            }
        }
    }

    // 备份当前渠道
    static void BackupCurChannel(String channelPath)
    {
        string sourcePath = @"Assets/";
        EditorUtility.DisplayProgressBar("备份资源到：" + channelPath, "开始备份", 0);
        for (int i = 0; i < pathList.Length; i++)
        {
            string path = pathList[i];
            EditorUtility.DisplayProgressBar("备份资源到：" + channelPath, path, ((float)i / pathList.Length));
            try
            {
                BuildAPK.DeleteFolder(channelPath + path, outSidePath);
                BuildAPK.CopyFolder(sourcePath + path, channelPath + path, outSidePath);
            }
            catch (Exception e)
            {
                Debug.Log(path + "路径有误");
                Debug.Log(e.Message);
                EditorUtility.ClearProgressBar();
            }
        }
        EditorUtility.ClearProgressBar();
        // 刷新资源
        AssetDatabase.Refresh();
    }

    // 恢复指定渠道
    static void ResetTOChannel(String sourcePath)
    {
        string destPath = @"Assets/";
        EditorUtility.DisplayProgressBar("恢复资源：" + sourcePath, "开始恢复", 0);
        for (int i = 0; i < pathList.Length; i++)
        {
            string path = pathList[i];
            EditorUtility.DisplayProgressBar("恢复资源：" + sourcePath, path, ((float)i / pathList.Length));
            try
            {
                // Debug.Log(sourcePath + path);
                // Debug.Log(destPath + path);
                // Debug.Log(outSidePath);
                BuildAPK.DeleteFolder(destPath + path, outSidePath);
                BuildAPK.CopyFolder(sourcePath + path, destPath + path, outSidePath);
            }
            catch (Exception e)
            {
                Debug.Log(path + "路径有误");
                Debug.Log(e.Message);
                EditorUtility.ClearProgressBar();
            }
        }
        EditorUtility.ClearProgressBar();
        // 刷新资源
        AssetDatabase.Refresh();
    }

    static void DeleteDestinationPath(string destPath, string[] outSidePath = null) {
        FileAttributes attr = File.GetAttributes(destPath);
        if (attr == FileAttributes.Directory) {
            Directory.Delete(destPath, true);
        }
    }

    static void CompareChannel(string sourcePath, string mainPath, string channelPath) {
        if (Directory.Exists(sourcePath)) {

            List<string> sourceFilePaths = new List<string>(Directory.GetFiles(sourcePath));
            for (int i = 0; i < sourceFilePaths.Count; i++) {
                string sourceFile = sourceFilePaths[i];
                string mainFile = Path.Combine(mainPath, Path.GetFileName(sourceFile));
                if (!CompareFile(sourceFile, mainFile)) {
                    if (!Directory.Exists(channelPath)) {
                        Directory.CreateDirectory(channelPath);
                    }
                    string channelFile = Path.Combine(channelPath, Path.GetFileName(sourceFile));
                    // 判断这个路径是否存在
                    File.Copy(sourceFile, channelFile, true);
                }
            }

            List<string> sourceDirPaths = new List<string>(Directory.GetDirectories(sourcePath));
            for (int i = 0; i < sourceDirPaths.Count; i++) {
                string sourceDir = sourceDirPaths[i];
                string mainDir = Path.Combine(mainPath, Path.GetFileName(sourceDir));
                string channelDir = Path.Combine(channelPath, Path.GetFileName(sourceDir));
                CompareChannel(sourceDir, mainDir, channelDir);
            }
        }
    }

    static bool CompareFile(string one, string two) {
        if (File.Exists(one) && File.Exists(two)) {
            HashAlgorithm oneHash = HashAlgorithm.Create();
            FileStream oneStream = new FileStream(one, FileMode.Open);
            byte[] oneHashByte = oneHash.ComputeHash(oneStream);
            oneStream.Close();

            HashAlgorithm twoHash = HashAlgorithm.Create();
            FileStream twoStream = new FileStream(two, FileMode.Open);
            byte[] twoHashByte = twoHash.ComputeHash(twoStream);
            oneStream.Close();

            return (BitConverter.ToString(oneHashByte) == BitConverter.ToString(twoHashByte));
        }
        return false;
    }

}