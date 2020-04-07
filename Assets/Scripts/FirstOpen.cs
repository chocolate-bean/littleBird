using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FirstOpen : MonoBehaviour {
    public GameObject firstOpenText;
    private void Awake()
    {
        int isFirstOpen = PlayerPrefs.GetInt("isFirstOpen");
        if (isFirstOpen == 1)
        {
            firstOpenText.SetActive(false);
        }
        PlayerPrefs.SetInt("isFirstOpen", 1);
    }

    // Use this for initialization
    void Start () {

    }
	
	// Update is called once per frame
	void Update () {
		
	}
}
