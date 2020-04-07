using UnityEngine;
using LuaInterface;
using System.Collections;
using System.Collections.Generic;
using System;
using UnityEngine.UI;
using UnityEngine.SceneManagement;
using UnityEngine.EventSystems;

public class UIHelper:MonoBehaviour
{
    //添加监听
    public static void AddButtonClick(GameObject go, LuaFunction luafunc)
    {
        if (go == null || luafunc == null)
        {
            Debug.Log("GameObject or luafunc is null");
            return;
        }


        Button btn = go.GetComponent<Button>();
        if (btn == null)
        {
            Debug.Log("Button is null");
            return;
        }


        btn.onClick.AddListener
        (
            delegate ()
            {
                luafunc.Call(go);
            }
        );
    }

    //清除监听
    public static void ClearButtonClick(GameObject go)
    {
        if (go == null)
        {
            return;
        }
        Button btn = go.GetComponent<Button>();
        if (btn == null)
        {
            return;
        }
        btn.onClick.RemoveAllListeners();
    }

    // 添加开关按钮的监听
    public static void AddToggleClick(GameObject go,LuaFunction luafunc)
    {
        if (go == null || luafunc == null)
        {
            Debug.Log("GameObject or luafunc is null");
            return;
        }

        Toggle toggle = go.GetComponent<Toggle>();
        if (toggle == null)
        {
            Debug.Log("Button is null");
            return;
        }

        toggle.onValueChanged.AddListener
        (
            (bool value) => luafunc.Call(go)
        );
    }

    // 添加ScrollRect 滚动的监听
    public static void AddScrollValueChangedListen(GameObject go, LuaFunction luafunc)
    {
        if (go == null || luafunc == null)
        {
            Debug.Log("GameObject or luafunc is null");
            return;
        }

        ScrollRect scrollRect = go.GetComponent<ScrollRect>();
        if (scrollRect == null)
        {
            Debug.Log("ScrollRect is null");
            return;
        }

        scrollRect.onValueChanged.AddListener
        (
            (Vector2 value) => luafunc.Call(value)
        );
    }

    public static void AddSliderValueChangedListen(GameObject go, LuaFunction luafunc)
    {
        if (go == null || luafunc == null)
        {
            Debug.Log("GameObject or luafunc is null");
            return;
        }

        Slider slider = go.GetComponent<Slider>();
        if (slider == null)
        {
            Debug.Log("ScrollRect is null");
            return;
        }

        slider.onValueChanged.AddListener
        (
            (float value) => luafunc.Call(value)
        );
    }


    public static Sprite LoadSprite(string path)
    {
        Sprite sp = Resources.Load<Sprite>(path);
        return sp;
    }

    public static Vector2 getSpriteSize(Sprite sprite)
    {
        return new Vector2(sprite.rect.width, sprite.rect.height);
    }


    public static void addTouchListener(GameObject gameObject, LuaFunction luafunc)
    {
        
        if (gameObject == null || luafunc == null)
        {
            Debug.Log("GameObject or luafunc is null");
            return;
        }

        TouchCallback touchCallback = gameObject.GetComponent<TouchCallback>();
        if (touchCallback == null)
        {
            touchCallback = gameObject.AddComponent<TouchCallback>();
        }

        touchCallback.onTouchChanged.AddListener
        (
             (string eventString, PointerEventData eventData) => luafunc.Call(eventString, eventData, gameObject)
        );
    }

    public static void getCanvasPos(GameObject gameObject)
    {
        Canvas canvas = GameObject.Find("Canvas").GetComponent<Canvas>();
        Vector3 vector3;
        if(RectTransformUtility.ScreenPointToWorldPointInRectangle(canvas.transform as RectTransform, gameObject.transform.position, canvas.worldCamera, out vector3)){
            Debug.Log(vector3);
            RectTransform rectTransform = gameObject.transform as RectTransform;
            rectTransform.position = vector3;
			// return vector2;
		}
        // return vector2;
    }

    public static void OpenWebView(string webUrl, LuaFunction onLoadSuccess, LuaFunction onMessageReceived)
    {
        GameObject webViewGameObject = new GameObject("webViewGameObject");
    }

    public static void SetHorizontalLayoutGroupSpacing(GameObject gameObject, float value) {
        HorizontalLayoutGroup group = gameObject.GetComponent<HorizontalLayoutGroup>();
        if (group != null)
        {
            group.spacing = value;
            group.SetLayoutHorizontal();
        }
    }

}


