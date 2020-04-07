using UnityEngine;
using System.Collections;
using LuaFramework;

public class StartUpCommand : ControllerCommand {

    public override void Execute(IMessage message) {
        if (!Util.CheckEnvironment()) return;

        GameObject gameMgr = GameObject.Find("GlobalGenerator");
        if (gameMgr != null) {
            AppView appView = gameMgr.AddComponent<AppView>();
        }

        //-----------------初始化管理器-----------------------
        AppFacade.Instance.AddManager<LuaManager>(ManagerName.Lua);
        AppFacade.Instance.AddManager<TimerManager>(ManagerName.Timer);
        AppFacade.Instance.AddManager<ResourceManager>(ManagerName.Resource);
        AppFacade.Instance.AddManager<ThreadManager>(ManagerName.Thread);
        AppFacade.Instance.AddManager<GameManager>(ManagerName.Game);
        AppFacade.Instance.AddManager<SDKManager>(ManagerName.SDK);
        AppFacade.Instance.AddManager<NativeManager>(ManagerName.Native);
        AppFacade.Instance.AddManager<ShopManager>(ManagerName.Shop);
        AppFacade.Instance.AddManager<WWWManager>(ManagerName.WWW);
        AppFacade.Instance.AddManager<SoundManager>(ManagerName.Sound);

    }
}