using UnityEngine;
using UnityEngine.EventSystems;
using LuaInterface;
using System.Collections;
using System.Collections.Generic;
using System;
using UnityEngine.UI;
using System.Security.Cryptography;
using System.Text;
using System.IO;

public class CSharpTools
{
    /// <summary>
    /// 获取系统时间
    /// </summary>
    /// <returns></returns>
    public static long GetOSTime()
    {
        TimeSpan ts = DateTime.Now.ToUniversalTime() - new DateTime(1970, 1, 1);//ToUniversalTime()转换为标准时区的时间,去掉的话直接就用北京时间
        //return (long)ts.TotalMilliseconds; //精确到毫秒
        return (long)ts.TotalSeconds;//获取10位
    }

    /// <summary>
    /// 获取字符串的MD5
    /// </summary>
    /// <param name="source"></param>
    /// <returns></returns>
    public static string md5(string source)
    {
        MD5CryptoServiceProvider md5 = new MD5CryptoServiceProvider();
        byte[] data = System.Text.Encoding.UTF8.GetBytes(source);
        byte[] md5Data = md5.ComputeHash(data, 0, data.Length);
        md5.Clear();

        string destString = "";
        for (int i = 0; i < md5Data.Length; i++)
        {
            destString += Convert.ToString(md5Data[i], 16).PadLeft(2, '0');
        }
        destString = destString.PadLeft(32, '0');
        return destString;
    }

    /// <summary>  
    /// 获取文件的MD5 
    /// </summary>  
    public static string getFileHash(string filePath)
    {           
        try
        {
            FileStream fs = new FileStream(filePath, FileMode.Open);
            int len = (int)fs.Length;
            byte[] data = new byte[len];
            fs.Read(data, 0, len);
            fs.Close();
            MD5 md5 = new MD5CryptoServiceProvider();
            byte[] result = md5.ComputeHash(data);
            string fileMD5 = "";
            foreach (byte b in result)
            {
                fileMD5 += Convert.ToString(b, 16);
            }
            return fileMD5;   
        }
        catch (FileNotFoundException e)
        {
            Console.WriteLine(e.Message);
            return "";
        }                                 
    }

    /// <summary>  
    /// Base64编码  
    /// </summary>  
    public static string Base64Encode(string message)
    {
        byte[] bytes = Encoding.GetEncoding("utf-8").GetBytes(message);
        return Convert.ToBase64String(bytes);
    }

    /// <summary>  
    /// Base64解码  
    /// </summary>  
    public static string Base64Decode(string message)
    {
        byte[] bytes = Convert.FromBase64String(message);
        return Encoding.GetEncoding("utf-8").GetString(bytes);
    }

    /// <summary>  
    /// 清楚缓存  
    /// </summary>  
    public static void cleanCache()
    {
        try
        {
            DirectoryInfo dir = new DirectoryInfo(Application.persistentDataPath);
            FileSystemInfo[] fileinfo = dir.GetFileSystemInfos();  //返回目录中所有文件和子目录
            foreach (FileSystemInfo i in fileinfo)
            {
                if (i is DirectoryInfo)            //判断是否文件夹
                {
                    DirectoryInfo subdir = new DirectoryInfo(i.FullName);
                    subdir.Delete(true);          //删除子目录和文件
                }
                else
                {
                    File.Delete(i.FullName);      //删除指定文件
                }
            }
        }
        catch (Exception e)
        {
            throw;
        }
        Application.Quit();
    }

    public static float GetTowPointAngle(Vector3 from_, Vector3 to_)
    {
        //两点的x、y值
        float x = from_.x - to_.x;
        float y = from_.y - to_.y;

        //斜边长度
        float hypotenuse = Mathf.Sqrt(Mathf.Pow(x,2f)+Mathf.Pow(y,2f));

        //求出弧度
        float cos = x / hypotenuse;
        float radian = Mathf.Acos(cos);

        //用弧度算出角度    
        float angle = 180 / (Mathf.PI / radian);

        if (y < 0)
        {
            angle = -angle;
        }
        else if ((y == 0) && (x < 0))
        {
            angle = 180;
        }
        return angle;
    }

    // 判断是否点在ui上
    public static bool IsPointerOverUIObject(Vector2 screenPosition)
    {
        //实例化点击事件
        PointerEventData eventDataCurrentPosition = new PointerEventData(EventSystem.current);
        //将点击位置的屏幕坐标赋值给点击事件
        eventDataCurrentPosition.position = new Vector2(screenPosition.x, screenPosition.y);

        List<RaycastResult> results = new List<RaycastResult>();
        //向点击处发射射线
        EventSystem.current.RaycastAll(eventDataCurrentPosition, results);

        return results.Count > 0;
    }

    /*
        贝塞尔相关
     */

    // 递归找点
    static List<Vector3> findPoint(List<Vector3> points, float average)
    {   
        var length = points.Count;
        List<Vector3> finds = new List<Vector3>();
        
        for (int index = 0; index < length - 1; index++)
        {
            finds.Add(Vector3.Lerp(points[index], points[index + 1], average));
        }
        if (finds.Count == 1)
        {
            return finds;
        } else {
            return findPoint(finds, average);
        }
    }

    public static List<Vector3> ToBezierLinePoints(List<Vector3> points, int pointCount)
    {
        List<Vector3> linePoints = new List<Vector3>();
        for (int index = 0; index < pointCount; index++)
        {
            linePoints.Add(findPoint(points, index / (float)pointCount)[0]);
        }
        return  linePoints;
    }

    // 屏幕适配相关
    private static float DefaultW = 1280;
    private static float DefaultH = 720;
    public static float FitX (float x)
    {
        return x / DefaultW * Screen.width;
    }

    public static float FitY (float x)
    {
        
        return x / DefaultH * Screen.height;
    }

    public static float StandardX (float x)
    {
        return x * DefaultW / Screen.width;
    }

    public static float StandardY (float x)
    {
        
        return x * DefaultH / Screen.height;
    }

}
