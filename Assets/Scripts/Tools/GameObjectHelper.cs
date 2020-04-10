using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine.UI;
using UnityEngine;
using LuaInterface;

namespace LuaFramework
{
    public static class GameObjectHelper
    {
        //设置文本
        public static GameObject setText(this GameObject target,string str)
        {
            Text text = target.GetComponent<Text>();
            if(text == null)
            {
                Debug.Log("Text is null");
                return target;
            }

            text.text = str;
            return target;
        }

        //设置Sprite
        //通过sprite
        public static GameObject setSprite(this GameObject target, Sprite sprite)
        {
            Image image = target.GetComponent<Image>();
            if(image == null)
            {
                Debug.Log("Image is null");
                return target;
            }

            image.sprite = sprite;
            return target;
        }

        //设置Sprite
        //通过路径
        public static GameObject setSprite(this GameObject target, string path)
        {
            Image image = target.GetComponent<Image>();
            if (image == null)
            {
                Debug.Log("Image is null");
                return target;
            }

            Sprite sp = Resources.Load<Sprite>(path);
            if(sp == null)
            {
                Debug.Log("path is null");
                return target;
            }
            image.sprite = sp;
            return target;
        }

        //给物体添加一个btn回调
        //若没有Button组件则添加一个Button组件
        public static GameObject addButtonClick(this GameObject target, LuaFunction luafunc, bool sound = false)
        {
            if (target == null || luafunc == null)
            {
                Debug.Log("GameObject or luafunc is null");
                return target;
            }

            Button btn = target.GetComponent<Button>();
            if (btn == null)
            {
                btn = target.AddComponent<Button>();
            }

            btn.onClick.AddListener
            (
                delegate ()
                {
                    if (sound)
                    {
                        AppFacade.Instance.GetManager<SoundManager>(ManagerName.Sound).PlaySound("clickButton");
                    }
                    luafunc.Call(target);
                }
            );

            return target;
        }

        //清除监听
        public static GameObject ClearButtonClick(this GameObject target)
        {
            if (target == null)
            {
                return target;
            }
            Button btn = target.GetComponent<Button>();
            if (btn == null)
            {
                return target;
            }
            btn.onClick.RemoveAllListeners();
            return target;
        }

        public static GameObject setVisiable(this GameObject target,bool active)
        {
            target.SetActive(active);
            return target;
        }

        public static GameObject pos(this GameObject target, float x, float y)
        {
            target.transform.localPosition = new Vector3(x, y, 0);
            return target;
        }

        public static GameObject size(this GameObject target, float x, float y)
        {
            RectTransform rect = target.GetComponent<RectTransform>();
            rect.sizeDelta = new Vector3(x, y, 0);
            return target;
        }

        public static GameObject scale(this GameObject target, Vector3 vector)
        {
            target.transform.localScale = vector;
            return target;
        }

        public static GameObject scaleX(this GameObject target, float value)
        {
            target.transform.localScale = new Vector3(value, 1, 1);
            return target;
        }

        public static GameObject scaleY(this GameObject target, float value)
        {
            target.transform.localScale = new Vector3(1, value, 1);
            return target;
        }

        public static GameObject show(this GameObject target)
        {
            target.SetActive(true);
            return target;
        }

        public static GameObject hide(this GameObject target)
        {
            target.SetActive(false);
            return target;
        }

        public static GameObject rotation(this GameObject target, float x, float y, float z)
        {
            target.transform.localEulerAngles = new Vector3(x, y, z);
            return target;
        }

        public static GameObject addTo(this GameObject target,GameObject parent)
        {
            target.transform.SetParent(parent.transform);
            return target;
        }

        public static GameObject addChild(this GameObject target, GameObject child)
        {
            child.transform.SetParent(target.transform);
            return target;
        }

        public static GameObject removeAllChildren(this GameObject target)
        {
            for (int i = target.transform.childCount - 1; i >= 0; i--)
            {
                GameObject.Destroy(target.transform.GetChild(i).gameObject);
            }
            return target;
        }

        public static GameObject color(this GameObject target, Color value)
        {
            Component[] comps = target.GetComponentsInChildren<Component>();
            foreach (Component component in comps)
            {
                if (component is CanvasRenderer)
                {
                    (component as CanvasRenderer).SetColor(value);
                }
            }
            
            return target;
        }
        
        public static GameObject opacity(this GameObject target, float value)
        {
            Component[] comps = target.GetComponentsInChildren<Component>();
            foreach (Component component in comps)
            {
                if (component is CanvasRenderer)
                {
                    (component as CanvasRenderer).SetAlpha(value);
                }
            }

            return target;
        }

        // 警告
        // Warnning
        // fadeIn以及fadeOut 将会把gameobject以及全部子节点的透明度全部改变
        public static GameObject fadeIn(this GameObject target, float time)
        {

            Component[] comps = target.GetComponentsInChildren<Component>();
            foreach (Component component in comps)
            {
                if (component is Graphic)
                {
                    (component as Graphic).CrossFadeAlpha(1, time, true);
                }
            }

            return target;
        }

        public static GameObject fadeOut(this GameObject target, float time)
        {

            Component[] comps = target.GetComponentsInChildren<Component>();
            foreach (Component component in comps)
            {
                if (component is Graphic)
                {
                    (component as Graphic).CrossFadeAlpha(0, time, true);
                }
            }

            return target;
        }
        
        public static GameObject findChild(this GameObject target, string name)
        {
            Transform childTs = target.transform.Find(name);
            if (childTs != null)
            {
                return childTs.gameObject;
            }
            else
            {
                return null;
            }
        }

        public static GameObject[] getChilds(this GameObject target)
        {
            var childs = new List<GameObject>();
            for (int i = target.transform.childCount - 1; i >= 0; i--)
            {
                childs.Add(target.transform.GetChild(i).gameObject);
            }
            int count = childs.ToArray().Length;
            return childs.ToArray();
        }
        
    }
}
