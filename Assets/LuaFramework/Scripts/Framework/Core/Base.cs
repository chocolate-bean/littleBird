using UnityEngine;
using System.Collections;
using LuaFramework;
using System.Collections.Generic;

public class Base : MonoBehaviour {
    private AppFacade m_Facade;
    private LuaManager m_LuaMgr;
    private ResourceManager m_ResMgr;
    private TimerManager m_TimerMgr;
    private ThreadManager m_ThreadMgr;
    private SDKManager m_SDKMgr;
    private NativeManager m_NativeMgr;
    private ShopManager m_ShopMgr;
    private WWWManager m_WWWMgr;
    private SoundManager m_SoundMgr;

    /// <summary>
    /// 注册消息
    /// </summary>
    /// <param name="view"></param>
    /// <param name="messages"></param>
    protected void RegisterMessage(IView view, List<string> messages) {
        if (messages == null || messages.Count == 0) return;
        Controller.Instance.RegisterViewCommand(view, messages.ToArray());
    }

    /// <summary>
    /// 移除消息
    /// </summary>
    /// <param name="view"></param>
    /// <param name="messages"></param>
    protected void RemoveMessage(IView view, List<string> messages) {
        if (messages == null || messages.Count == 0) return;
        Controller.Instance.RemoveViewCommand(view, messages.ToArray());
    }

    protected AppFacade facade {
        get {
            if (m_Facade == null) {
                m_Facade = AppFacade.Instance;
            }
            return m_Facade;
        }
    }

    protected LuaManager LuaManager {
        get {
            if (m_LuaMgr == null) {
                m_LuaMgr = facade.GetManager<LuaManager>(ManagerName.Lua);
            }
            return m_LuaMgr;
        }
    }

    protected ResourceManager ResManager {
        get {
            if (m_ResMgr == null) {
                m_ResMgr = facade.GetManager<ResourceManager>(ManagerName.Resource);
            }
            return m_ResMgr;
        }
    }

    protected TimerManager TimerManager {
        get {
            if (m_TimerMgr == null) {
                m_TimerMgr = facade.GetManager<TimerManager>(ManagerName.Timer);
            }
            return m_TimerMgr;
        }
    }

    protected ThreadManager ThreadManager {
        get {
            if (m_ThreadMgr == null) {
                m_ThreadMgr = facade.GetManager<ThreadManager>(ManagerName.Thread);
            }
            return m_ThreadMgr;
        }
    }

    protected SDKManager SDKManager
    {
        get
        {
            if (m_SDKMgr == null)
            {
                m_SDKMgr = facade.GetManager<SDKManager>(ManagerName.SDK);
            }
            return m_SDKMgr;
        }
    }
    protected NativeManager NativeManager
    {
        get
        {
            if (m_NativeMgr == null)
            {
                m_NativeMgr = facade.GetManager<NativeManager>(ManagerName.Native);
            }
            return m_NativeMgr;
        }
    }

    protected WWWManager WWWManager
    {
        get
        {
            if (m_WWWMgr == null)
            {
                m_WWWMgr = facade.GetManager<WWWManager>(ManagerName.WWW);
            }
            return m_WWWMgr;
        }
    }

    protected ShopManager ShopManager
    {
        get
        {
            if (m_ShopMgr == null)
            {
                m_ShopMgr = facade.GetManager<ShopManager>(ManagerName.SDK);
            }
            return m_ShopMgr;
        }
    }

    protected SoundManager SoundManager
    {
        get
        {
            if (m_SoundMgr == null)
            {
                m_SoundMgr = facade.GetManager<SoundManager>(ManagerName.Sound);
            }
            return m_SoundMgr;
        }
    }
}
