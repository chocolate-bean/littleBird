using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using UnityEngine;

public class ColliderSprict : MonoBehaviour
{
    
    // LuaFunction
    private LuaFunction collierCallBack;
    public int testNumber = 85;
    // Start is called before the first frame update
    void Start()
    {
       
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void SetLuaFunction(LuaFunction callback)
     {
        collierCallBack = callback;
    }

    private void OnCollisionEnter2D(Collision2D other) 
    {
        print("2d碰撞");
    }
    
    private void OnCollisionStay2D(Collision2D other)
     {
        print("OnCollisionStay2D");
    }

    private void OnCollisionExit2D(Collision2D other)
     {
        print("OnCollisionExit2D");
    }

    private void OnTriggerEnter2D(Collider2D other) 
    {
        print("开始触发");
        if (collierCallBack != null)
        {
            collierCallBack.Call();
            collierCallBack.Dispose();
            collierCallBack = null;
        }
    }

    // private void OnTriggerStay2D(Collider2D other) {
    //     print("OnTriggerStay2D");
    // }

    // private void OnTriggerExit2D(Collider2D other) {
    //     print("OnTriggerExit2D");
    // }
}
