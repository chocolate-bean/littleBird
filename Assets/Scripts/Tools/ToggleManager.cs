using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ToggleManager : MonoBehaviour {
    private Toggle m_toggle;

    void Start()
    {
        m_toggle = gameObject.GetComponent<Toggle>();
        m_toggle.onValueChanged.AddListener(IsOnValue);
        if(m_toggle.isOn)
        {
            gameObject.transform.Find("Background").GetComponent<Image>().enabled = false;
        }
        else
        {
            gameObject.transform.Find("Background").GetComponent<Image>().enabled = true;
        }
    }
    private void IsOnValue(bool value)
    {
        if (value)
        {
            gameObject.transform.Find("Background").GetComponent<Image>().enabled = false;
        }
        else
        {
            gameObject.transform.Find("Background").GetComponent<Image>().enabled = true;
        }
    }
}
