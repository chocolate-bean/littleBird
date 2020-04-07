using LuaInterface;
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEngine.Networking;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

namespace LuaFramework
{
    public class SoundManager : Manager
    {
        private Dictionary<string, AudioSource> sound;

        void Awake()
        {
            sound = new Dictionary<string, AudioSource>();
        }

        //播放背景音乐
        public void PlayBGM()
        {
            GameObject.Find("BgMusic").GetComponent<AudioSource>().Play();
        }

        //停止背景音乐
        public void StopBGM()
        {
            GameObject.Find("BgMusic").GetComponent<AudioSource>().Stop();
        }

        //暂停背景音乐
        public void PauseBGM()
        {
            GameObject.Find("BgMusic").GetComponent<AudioSource>().Pause();
        }

        //切换背景音乐
        public void ChangeBGM(string name)
        {
            if(PlayerPrefs.GetInt("MUSIC") == 0){
                GameObject.Find("BgMusic").GetComponent<AudioSource>().clip = Resources.Load<AudioClip>("Sounds/" + name);
                GameObject.Find("BgMusic").GetComponent<AudioSource>().Play();
            }
            else{
                GameObject.Find("BgMusic").GetComponent<AudioSource>().Stop();
            }
        }

        //播放指定音效
        public void PlaySound(string name)
        {
            PlaySoundWithNewSource(name, false, null);
        }

        //关闭所有音效
        public void CloseSound()
        {
            GameObject SoundEffect = GameObject.Find("SoundEffect");
            AudioSource[] audios = SoundEffect.GetComponents<AudioSource>();
            for (int i = 0; i < audios.Length; i++)
            {
                Destroy(audios[i]);
            }
            sound = new Dictionary<string, AudioSource>();
        }

        //播放指定音效
        public void PlaySoundWithNewSource(string name, bool isLoop, LuaFunction luafunc)
        {
            if(PlayerPrefs.GetInt("SOUND") == 0){
                if(isLoop && sound.ContainsKey(name))
                {
                    Destroy(sound[name]);
                    sound.Remove(name);
                }

                GameObject SoundEffect = GameObject.Find("SoundEffect");
                AudioSource audioSource = SoundEffect.AddComponent<AudioSource>();
                StartCoroutine(playSound(audioSource, name, isLoop, luafunc));
            }
            else{
                CloseSound();
            }
        }

        public IEnumerator playSound(AudioSource audioSource, string name, bool isLoop, LuaFunction func)
        {
            audioSource.loop = false;
            audioSource.Stop();
            audioSource.playOnAwake = false;

            audioSource.clip = Resources.Load<AudioClip>("Sounds/" + name);

            if (audioSource.clip != null)
            {
                audioSource.Play();
                if (isLoop)
                {
                    audioSource.loop = true;
                    sound.Add(name, audioSource);
                }
                else
                {
                    yield return new WaitForSeconds(audioSource.clip.length);
                    Destroy(audioSource);
                    if (func != null)
                    {
                        func.Call(name);
                    }
                }
            }
        }

        // 关闭指定音效
        public void StopSoundWithName(string name)
        {
            if (sound.ContainsKey(name))
            {
                Destroy(sound[name]);
                sound.Remove(name);
            }
        }
    }
}
