using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveManager : MonoBehaviour {

    Coroutine cmove;
    // Use this for initialization
    void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		
	}

    /// <summary>
    /// 让物体沿着指定的坐标点顺序移动
    /// </summary>
    /// <param name="vecs">坐标集合</param>
    /// <param name="type">移动的类型</param>
    /// <param name="speed">速度</param>
    public void Move(Vector3[] vecs, int type, float speed)
    {
        cmove = StartCoroutine(MoveForTargets(vecs, type, speed));
    }

    /// <summary>
    /// 终止当前的移动
    /// </summary>
    public void StopMove()
    {
        if (cmove != null)
        {
            StopCoroutine(cmove);
            cmove = null;
        }
    }

    private IEnumerator MoveForTargets(Vector3[] vecs, int type, float speed)
    {
        for (int i = 0; i < vecs.Length; i++)
        {
            switch (type)
            {
                case 1:
                    // 直线运动
                    while (gameObject.transform.localPosition != vecs[i])
                    {
                        gameObject.transform.localPosition = Vector3.MoveTowards(gameObject.transform.localPosition, vecs[i], speed * Time.deltaTime);
                        yield return null;
                    }
                    break;
                case 2:
                    // 弧线运动（无转向）
                    while (gameObject.transform.localPosition != vecs[i])
                    {
                        Vector3 center = (gameObject.transform.localPosition + vecs[i]) * 0.5f;
                        center -= new Vector3(0, 1, 0);
                        Vector3 start = gameObject.transform.localPosition - center;
                        Vector3 end = vecs[i] - center;

                        //插值
                        transform.position = Vector3.Slerp(start, end, Time.time);
                        transform.position += center;
                    }
                    break;
                case 3:
                    // 弧线运动（转向）
                    float distanceToTarget = Vector3.Distance(gameObject.transform.localPosition, vecs[i]);
                    float currentDist = Vector3.Distance(gameObject.transform.localPosition, vecs[i]);
                    while (currentDist > 0.5f)
                    {
                        gameObject.transform.LookAt(vecs[i]);
                        float angle = Mathf.Min(1, Vector3.Distance(gameObject.transform.localPosition, vecs[i]) / distanceToTarget) * 45;
                        gameObject.transform.rotation = gameObject.transform.rotation * Quaternion.Euler(Mathf.Clamp(-angle, -42, 42), 0, 0);
                        currentDist = Vector3.Distance(gameObject.transform.localPosition, vecs[i]);
                        gameObject.transform.Translate(Vector3.forward * Mathf.Min(speed * Time.deltaTime, currentDist));
                        yield return null;
                    }
                    break;
                default:
                    // 直线运动
                    while (gameObject.transform.localPosition != vecs[i])
                    {
                        gameObject.transform.localPosition = Vector3.MoveTowards(gameObject.transform.localPosition, vecs[i], speed * Time.deltaTime);
                        yield return null;
                    }
                    break;
            }
        }
    }
}
