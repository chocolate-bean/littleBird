using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
using System.IO;
public class TMPHelper : MonoBehaviour {
	public static void setText(GameObject target, string str)
	{
		TextMeshProUGUI tmpUGUI = target.GetComponent<TextMeshProUGUI>();
		if(tmpUGUI == null)
		{
			Debug.Log("TextMeshProUGUI is null");
			return;
		}
		tmpUGUI.text = str;
	}

	public static void setTextColor(GameObject target, Color color, string name = "Text")
	{
		TextMeshProUGUI tmpUGUI = target.GetComponent<TextMeshProUGUI>();
		if(tmpUGUI == null)
		{
			Debug.Log("TextMeshProUGUI is null");
			return;
		}
		/** 
			- _ClipRect: {r: -32767, g: -32767, b: 32767, a: 32767}
			- _EnvMatrixRotation: {r: 0, g: 0, b: 0, a: 0}
			- _FaceColor: {r: 1, g: 1, b: 1, a: 1}
			- _GlowColor: {r: 0, g: 1, b: 0, a: 0.5}
			- _MaskCoord: {r: 0, g: 0, b: 32767, a: 32767}
			- _OutlineColor: {r: 1, g: 1, b: 1, a: 1}
			- _ReflectFaceColor: {r: 0, g: 0, b: 0, a: 1}
			- _ReflectOutlineColor: {r: 0, g: 0, b: 0, a: 1}
			- _SpecularColor: {r: 1, g: 1, b: 1, a: 1}
			- _UnderlayColor: {r: 0.36862746, g: 0.20392157, b: 0.07058824, a: 0.5019608}
		*/
		if (name.Equals("Text"))
		{
			tmpUGUI.color = color; 
		} 
		else if (name.Equals("Face"))
		{
			tmpUGUI.fontMaterial.SetColor("_FaceColor", color);
		}
		else if (name.Equals("Outline"))
		{
			tmpUGUI.fontMaterial.SetColor("_OutlineColor", color);
		}
		else if (name.Equals("Underlay"))
		{
			tmpUGUI.fontMaterial.SetColor("_UnderlayColor", color);
		}
	}

	public static Color getTextColor(GameObject target)
	{
		TextMeshProUGUI tmpUGUI = target.GetComponent<TextMeshProUGUI>();
		if(tmpUGUI == null)
		{
			Debug.Log("TextMeshProUGUI is null");
			return Color.white;
		}
		return tmpUGUI.color;
	}

	public static void setTexture(GameObject target, string name, string path = null)
	{
		TextMeshProUGUI tmpUGUI = target.GetComponent<TextMeshProUGUI>();
		if(tmpUGUI == null)
		{
			Debug.Log("TextMeshProUGUI is null");
			return;
		}
		/**
		- _BumpMap:
		- _Cube:
		- _FaceTex:
		- _MainTex:
		- _OutlineTex:
		*/
		string textName = null;
		if (name.Equals("Face"))
		{
			textName = "_FaceTex";
		}
		else if (name.Equals("Outline"))
		{
			textName = "_OutlineTex";
		}

		if (textName != null)
		{
			if (path != null)
			{
				Texture2D texture = Resources.Load<Texture2D>(path);
                if (texture != null) {
				    tmpUGUI.fontMaterial.SetTexture(textName, texture);
                } else {
                    Debug.Log("图片路径没有资源");
                }
			}
			else
			{
				tmpUGUI.fontMaterial.SetTexture(textName, null);
			}
		}
	}
}
