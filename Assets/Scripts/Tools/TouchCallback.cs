using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.Events;

public class TouchCallback : MonoBehaviour, IPointerDownHandler, IPointerUpHandler
// , IBeginDragHandler, IDragHandler, IEndDragHandler, IPointerEnterHandler, IPointerExitHandler
{
    public TouchEvent onTouchChanged;

    public void Awake()
    {
        onTouchChanged = new TouchEvent();
    }

    public void OnPointerDown(PointerEventData eventData)
    {
        onTouchChanged.Invoke("OnPointerDown", eventData);
    }

    public void OnPointerUp(PointerEventData eventData)
    {
        onTouchChanged.Invoke("OnPointerUp", eventData);
    }

    // public void OnBeginDrag(PointerEventData eventData)
    // {
    //     onTouchChanged.Invoke("OnBeginDrag", eventData);
    // }

    // public void OnDrag(PointerEventData eventData)
    // {
    //     onTouchChanged.Invoke("OnDrag", eventData);
    // }

    // public void OnEndDrag(PointerEventData eventData)
    // {
    //     onTouchChanged.Invoke("OnEndDrag", eventData);
    // }

    // public void OnPointerEnter(PointerEventData eventData)
    // {
    //     onTouchChanged.Invoke("OnPointerEnter", eventData);
    // }

    // public void OnPointerExit(PointerEventData eventData)
    // {
    //     onTouchChanged.Invoke("OnPointerExit", eventData);
    // }

    public class TouchEvent : UnityEvent<string, PointerEventData>{}
}
