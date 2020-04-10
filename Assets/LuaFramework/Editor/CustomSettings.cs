using UnityEngine;
using System;
using System.Collections.Generic;
using LuaInterface;
using LuaFramework;
using UnityEditor;

using BindType = ToLuaMenu.BindType;
using UnityEngine.UI;
using System.Reflection;

public static class CustomSettings
{
    public static string FrameworkPath = AppConst.FrameworkRoot;
    public static string saveDir = FrameworkPath + "/ToLua/Source/Generate/";
    public static string luaDir = FrameworkPath + "/Lua/";
    public static string toluaBaseType = FrameworkPath + "/ToLua/BaseType/";
	public static string baseLuaDir = FrameworkPath + "/ToLua/Lua";
	public static string injectionFilesPath = Application.dataPath + "/ToLua/Injection/";

    //导出时强制做为静态类的类型(注意customTypeList 还要添加这个类型才能导出)
    //unity 有些类作为sealed class, 其实完全等价于静态类
    public static List<Type> staticClassTypes = new List<Type>
    {
        typeof(UnityEngine.Application),
        typeof(UnityEngine.Time),
        typeof(UnityEngine.Screen),
        typeof(UnityEngine.SleepTimeout),
        typeof(UnityEngine.Input),
        typeof(UnityEngine.Resources),
        // typeof(UnityEngine.Physics),
        // typeof(UnityEngine.RenderSettings),
        // typeof(UnityEngine.QualitySettings),
        // typeof(UnityEngine.GL),
        // typeof(UnityEngine.Graphics),
    };

    //附加导出委托类型(在导出委托时, customTypeList 中牵扯的委托类型都会导出， 无需写在这里)
    public static DelegateType[] customDelegateList = 
    {        
        _DT(typeof(Action)),                
        _DT(typeof(UnityEngine.Events.UnityAction)),
        _DT(typeof(System.Predicate<int>)),
        _DT(typeof(System.Action<int>)),
        _DT(typeof(System.Comparison<int>)),
        _DT(typeof(System.Func<int, int>)),
    };

    //在这里添加你要导出注册到lua的类型列表
    public static BindType[] customTypeList =
    {                
        //------------------------为例子导出--------------------------------
        //_GT(typeof(TestEventListener)),
        //_GT(typeof(TestProtol)),
        //_GT(typeof(TestAccount)),
        //_GT(typeof(Dictionary<int, TestAccount>)).SetLibName("AccountMap"),
        //_GT(typeof(KeyValuePair<int, TestAccount>)),
        //_GT(typeof(Dictionary<int, TestAccount>.KeyCollection)),
        //_GT(typeof(Dictionary<int, TestAccount>.ValueCollection)),
        //_GT(typeof(TestExport)),
        //_GT(typeof(TestExport.Space)),
        //-------------------------------------------------------------------        
                        
        _GT(typeof(LuaInjectionStation)),
        _GT(typeof(InjectType)),
        _GT(typeof(Debugger)).SetNameSpace(null),          

        _GT(typeof(DG.Tweening.DOTween)),
        _GT(typeof(DG.Tweening.Tween)).SetBaseType(typeof(System.Object)).AddExtendType(typeof(DG.Tweening.TweenExtensions)),
        _GT(typeof(DG.Tweening.Sequence)).AddExtendType(typeof(DG.Tweening.TweenSettingsExtensions)),
        _GT(typeof(DG.Tweening.Tweener)).AddExtendType(typeof(DG.Tweening.TweenSettingsExtensions)),
        _GT(typeof(DG.Tweening.LoopType)),
        _GT(typeof(DG.Tweening.PathMode)),
        _GT(typeof(DG.Tweening.PathType)),
        _GT(typeof(DG.Tweening.RotateMode)),
        _GT(typeof(DG.Tweening.Ease)),
        _GT(typeof(Component)).AddExtendType(typeof(DG.Tweening.ShortcutExtensions)),
        _GT(typeof(Transform)).AddExtendType(typeof(DG.Tweening.ShortcutExtensions)),
        _GT(typeof(Material)).AddExtendType(typeof(DG.Tweening.ShortcutExtensions)),
        _GT(typeof(Image)).AddExtendType(typeof(DG.Tweening.ShortcutExtensions46)),
        _GT(typeof(Slider)).AddExtendType(typeof(DG.Tweening.ShortcutExtensions46)),
        _GT(typeof(Text)).AddExtendType(typeof(DG.Tweening.ShortcutExtensions46)),
        _GT(typeof(RectTransform)).AddExtendType(typeof(DG.Tweening.ShortcutExtensions46)),
      
        //骨骼动画
        _GT(typeof(DragonBones.UnityArmatureComponent)),
        _GT(typeof(DragonBones.Armature)),
        _GT(typeof(DragonBones.Animation)),
        _GT(typeof(DragonBones.AnimationData)),
        _GT(typeof(DragonBones.UnityFactory)),

        _GT(typeof(Behaviour)),
        _GT(typeof(MonoBehaviour)),        
        _GT(typeof(GameObject)).AddExtendType(typeof(GameObjectHelper)),
        _GT(typeof(TrackedReference)),
        _GT(typeof(Application)),
        _GT(typeof(Physics)),
        _GT(typeof(Collider)),
        _GT(typeof(Time)),        
        _GT(typeof(Texture)),
        _GT(typeof(Texture2D)),
        _GT(typeof(Shader)),        
        _GT(typeof(Renderer)),
        _GT(typeof(WWW)),
        _GT(typeof(WWWForm)),
        _GT(typeof(Screen)),   
        _GT(typeof(CameraClearFlags)),
        _GT(typeof(AudioClip)),        
        _GT(typeof(AssetBundle)),
        _GT(typeof(ParticleSystem)),
        _GT(typeof(AsyncOperation)).SetBaseType(typeof(System.Object)),        
        _GT(typeof(LightType)),
        _GT(typeof(SleepTimeout)),
        _GT(typeof(Outline)), 
        _GT(typeof(GridLayoutGroup)), 

        //枚举值
        _GT(typeof(ChannelType)),
        _GT(typeof(SidConfig)),

        _GT(typeof(RuntimePlatform)),
#if UNITY_5_3_OR_NEWER && !UNITY_5_6_OR_NEWER
        _GT(typeof(UnityEngine.Experimental.Director.DirectorPlayer)),
#endif

        // _GT(typeof(MeshRenderer)),
#if !UNITY_5_4_OR_NEWER
        _GT(typeof(ParticleEmitter)),
        _GT(typeof(ParticleRenderer)),
        _GT(typeof(ParticleAnimator)), 
#endif
        
        _GT(typeof(Animation)),        
        _GT(typeof(AnimationClip)).SetBaseType(typeof(UnityEngine.Object)),        
        _GT(typeof(AnimationState)),
        _GT(typeof(AnimationBlendMode)),
        _GT(typeof(Animator)),
        _GT(typeof(RuntimeAnimatorController)),
        _GT(typeof(QueueMode)),  
        _GT(typeof(PlayMode)),
        _GT(typeof(WrapMode)),
		_GT(typeof(LuaProfiler)),
          
        //for LuaFramework
		_GT(typeof(Resources)),      
        _GT(typeof(Grid)),
        _GT(typeof(Toggle)),
        _GT(typeof(ScrollRect)),
        _GT(typeof(Button)),
        _GT(typeof(ToggleGroup)),
        _GT(typeof(InputField)),
        _GT(typeof(UnityEngine.Random)),
        _GT(typeof(RectTransform.Edge)),
        _GT(typeof(RectTransform.Axis)),
        _GT(typeof(UnityEngine.EventSystems.PointerEventData)),

        _GT(typeof(Util)),
        _GT(typeof(AppConst)),
        _GT(typeof(LuaHelper)),
        _GT(typeof(LuaBehaviour)),

        _GT(typeof(GameManager)),
        _GT(typeof(LuaManager)),
        _GT(typeof(TimerManager)),
        _GT(typeof(ThreadManager)),
        _GT(typeof(ResourceManager)),
        _GT(typeof(SDKManager)),
        _GT(typeof(NativeManager)),
        _GT(typeof(ShopManager)),
        _GT(typeof(WWWManager)),
        _GT(typeof(SoundManager)),
        _GT(typeof(UnityEngine.SceneManagement.SceneManager)),
        _GT(typeof(UnityEngine.SceneManagement.Scene)),
#if GP
        _GT(typeof(UnityEngine.Purchasing.ProductMetadata)),
#endif
        _GT(typeof(PlayerPrefs)),
        _GT(typeof(UIHelper)),
        _GT(typeof(TMPHelper)),
        _GT(typeof(CSharpTools)),
        _GT(typeof(ImageLoaderHelper)),
        _GT(typeof(SystemInfo)),

        // 自定义类
        _GT(typeof(ByteArray)),
        _GT(typeof(NetFramework)),
        _GT(typeof(ChipAnim)),

        // 断点接入
        _GT(typeof(LuaDebugTool)),
        _GT(typeof(LuaValueInfo)),

        //小鸟和墙的碰撞
        _GT(typeof(ColliderSprict))
    };

    public static List<Type> dynamicList = new List<Type>()
    {
        // typeof(MeshRenderer),
#if !UNITY_5_4_OR_NEWER
        typeof(ParticleEmitter),
        typeof(ParticleRenderer),
        typeof(ParticleAnimator),
#endif
    };

    //重载函数，相同参数个数，相同位置out参数匹配出问题时, 需要强制匹配解决
    //使用方法参见例子14
    public static List<Type> outList = new List<Type>()
    {
        
    };
        
    //ngui优化，下面的类没有派生类，可以作为sealed class
    public static List<Type> sealedList = new List<Type>()
    {
       
    };

    public static BindType _GT(Type t)
    {
        return new BindType(t);
    }

    public static DelegateType _DT(Type t)
    {
        return new DelegateType(t);
    }    


    [MenuItem("Lua/Attach Profiler", false, 151)]
    static void AttachProfiler()
    {
        if (!Application.isPlaying)
        {
            EditorUtility.DisplayDialog("警告", "请在运行时执行此功能", "确定");
            return;
        }

        LuaClient.Instance.AttachProfiler();
    }

    [MenuItem("Lua/Detach Profiler", false, 152)]
    static void DetachProfiler()
    {
        if (!Application.isPlaying)
        {            
            return;
        }

        LuaClient.Instance.DetachProfiler();
    }
}
