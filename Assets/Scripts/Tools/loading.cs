using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class loading : MonoBehaviour {
    public float speed;

	// Use this for initialization
	void Start () {
        transform.localEulerAngles = Vector3.zero;
	}
	
	// Update is called once per frame
	void Update () {
        transform.Rotate(new Vector3(0,0, -speed * Time.deltaTime));
    }
}
