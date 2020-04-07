using LuaFramework;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Net;
using System.Net.Mail;
using System.Text;
using UnityEngine;

// public class CMDBuild
// {
//     // CMDbuild APK
//     public static void CMDAutoBuild()
//     {
//         string[] args = Environment.GetCommandLineArgs();
//         string buildArgs = string.Empty;
//         for (int i = 0; i < args.Length; i++)
//         {
//             //Debug.Log("argindex:" + i + "  arg:" + args[i]);
//             if (args[i].Contains("buildArg"))
//             {
//                 //调用BuildAPK 需要用到的参数
//                 buildArgs = args[i];
//             }
//         }

//         UnityEngine.Debug.Log("buildArgs:" + buildArgs);
//         buildArgs = buildArgs.Replace("-buildArg=", "");
//         UnityEngine.Debug.Log(buildArgs);
//         UnityEngine.Debug.Log("调用BuildAPK");
//         SidConfig sid = (SidConfig)Enum.Parse(typeof(SidConfig), buildArgs);
//         BuildAPK.ChangeChannel(sid);
//         BuildAPK.BuildChannel(sid);

//         try
//         {
//             string smtpService = "smtp.qq.com";
//             string sendEmail = "36497913@qq.com";
//             string sendpwd = "smvhwovufetmbjbi";
//             string path = "E:/FishingGame/Tools/cmd/Test.txt";

//             Directory.SetCurrentDirectory("Tools/cmd");
//             ProcessStartInfo info = new ProcessStartInfo();
//             info.FileName = "SendMail.exe";
//             info.Arguments = " " + smtpService + " " + sendEmail + " " + sendpwd + " " + path;
//             info.WindowStyle = ProcessWindowStyle.Hidden;
//             info.UseShellExecute = true;
//             info.ErrorDialog = true;

//             Process pro = Process.Start(info);
//             pro.WaitForExit();
//         }
//         catch (Exception e)
//         {
//             UnityEngine.Debug.Log(e.Message);
//         }
//     }
// }
