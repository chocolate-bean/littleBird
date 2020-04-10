using System.Collections;
using System.Collections.Generic;
using UnityEngine;



public class WallCollider : MonoBehaviour
{
    private bool flag = false;
    // Start is called before the first frame update
    void Start()
    {

    }

    private void Awake() 
    {

    }
    // Update is called once per frame
    void Update()
    {
              
    }
     
    
    private void OnCollisionEnter2D(Collision2D other) 
    {
        print("wall 2d碰撞");
    }

    private void OnCollisionStay2D(Collision2D other) 
    {
        print("wall OnCollisionStay2D");
    }

    private void OnCollisionExit2D(Collision2D other) 
    {
        print("wall OnCollisionExit2D");
    }

    private void OnTriggerEnter2D(Collider2D other) 
    {
        print("wall 开始触发 ");
       
    }

    // private void OnTriggerStay2D(Collider2D other) {
    //     print("wall OnTriggerStay2D");
    // }

    // private void OnTriggerExit2D(Collider2D other) {
    //     print("wall OnTriggerExit2D");
    // }
}

