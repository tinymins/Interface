----------------------------------------------------
-- ������ͼ���� ver 0.1 Build 20140226
-- Code by: ��һ��tinymins @ ZhaiYiMing.CoM
-- ���塤˫��������
----------------------------------------------------
Tms_ScreenShotHelper = Tms_ScreenShotHelper or {}
-----------------------------------------------
-- ���غ����ͱ���
-----------------------------------------------
local _PluginVersion = {
	dwVersion = 0x0010000,
	szBuildDate = "20140226",
}
local _ScreenShotHelperDataDefault = {
    bUseGlobalSetting = true,
    szFileExName = "jpg",
    nQuality = 100,
    bAutoHideUI = false,
    szFilePath = "./ScreenShot/",
}
local _ScreenShotHelperDataGlobal = LoadLUAData("/Interface/Tms_ScreenShotHelper/Global.dat")
_ScreenShotHelperDataGlobal = _ScreenShotHelperDataGlobal or _ScreenShotHelperDataDefault
_ScreenShotHelperData = _ScreenShotHelperData or _ScreenShotHelperDataDefault
for k, _ in pairs(_ScreenShotHelperData) do
	RegisterCustomData("_ScreenShotHelperData." .. k)
end
local _ScreenShotHelperCache = {
    loaded = false,
}
----------------------------------------------------
-- ���ݳ�ʼ��
Tms_ScreenShotHelper.Loaded = function()
    if(_ScreenShotHelperCache.loaded) then return end
    _ScreenShotHelperCache.loaded = true
    
    Player_AppendAddonMenu({function()
        return {
            Tms_ScreenShotHelper.GetMenuList()
        }
    end })
    -- Target_AppendAddonMenu({ function(dwID)
        -- return {
            -- Tms_ScreenShotHelper.GetTargetMenu(dwID),
        -- }
    -- end })
    Tms_ScreenShotHelper.Reload()
    TMS.BreatheCall("Tms_ScreenShot_Hotkey_Check", function() local nKey, nShift, nCtrl, nAlt = Hotkey.Get("Tms_ScreenShot_Hotkey") if nKey==0 then Hotkey.Set("Tms_ScreenShot_Hotkey",1,44,false,false,false) end end, 10000)
    
    OutputMessage("MSG_SYS", "[�������]���ݼ��سɹ�����ӭʹ��������ͼ���֡�\n")
end
Tms_ScreenShotHelper.Reload = function(bLoadGlobalData)
    if bLoadGlobalData==true then 
        _ScreenShotHelperDataGlobal = LoadLUAData("/Interface/Tms_ScreenShotHelper/Global.dat")
    elseif _ScreenShotHelperData.bUseGlobalSetting then
        SaveLUAData("/Interface/Tms_ScreenShotHelper/Global.dat", _ScreenShotHelperDataGlobal)
    end
end
-----------------------------------------------
-- ͨ�ú���
-----------------------------------------------
-- (string, number) Tms_ScreenShotHelper.GetVersion()		-- HM�� ��ȡ�ַ����汾�� �޸ķ����ù�����
Tms_ScreenShotHelper.GetVersion = function()
	local v = _PluginVersion.dwVersion
	local szVersion = string.format("%d.%d.%d", v/0x1000000,
		math.floor(v/0x10000)%0x100, math.floor(v/0x100)%0x100)
	if  v%0x100 ~= 0 then
		szVersion = szVersion .. "b" .. tostring(v%0x100)
	end
	return szVersion, v
end

Tms_ScreenShotHelper.ShotScreen = function(nShowUI, nQuality, bFullPath)
    if nQuality==nil then
        local szFilePath, nQuality ,bFullPath, szFolderPath, bStationVisible, _SettingData
        _SettingData = (_ScreenShotHelperData.bUseGlobalSetting and _ScreenShotHelperDataGlobal) or _ScreenShotHelperData
        local tDateTime = TimeToDate(GetCurrentTime())
        local i=0
        szFolderPath = _SettingData.szFilePath
        if not IsFileExist(szFolderPath) then
            szFolderPath = _ScreenShotHelperDataDefault.szFilePath
            OutputMessage("MSG_SYS", "��ͼ�ļ������ô���".._SettingData.szFilePath.."Ŀ¼�����ڡ��ѱ����ͼ��Ĭ��λ�á�\n")
        end
        repeat
            szFilePath = szFolderPath .. (string.format("%04d-%02d-%02d_%02d-%02d-%02d-%03d", tDateTime.year, tDateTime.month, tDateTime.day, tDateTime.hour, tDateTime.minute, tDateTime.second, i)) .."." .. _SettingData.szFileExName
            i=i+1
        until not IsFileExist(szFilePath)
        nQuality = _SettingData.nQuality
        bFullPath = true -- bFullPath = (string.sub(szFilePath,2,2) == ":")
        bStationVisible = Station.IsVisible()
        if nShowUI == 0 then
            if bStationVisible then Station.Hide() end
            TMS.DelayCall(function()
                Tms_ScreenShotHelper.ShotScreen(szFilePath, nQuality, bFullPath)
                if bStationVisible then Station.Show() end
            end,100)
        elseif nShowUI == 1 then
            if not bStationVisible then Station.Show() end
            TMS.DelayCall(function()
                Tms_ScreenShotHelper.ShotScreen(szFilePath, nQuality, bFullPath)
                if not bStationVisible then Station.Hide() end
            end,100)
        else
            if bStationVisible and _SettingData.bAutoHideUI then Station.Hide() end
            TMS.DelayCall(function()
                Tms_ScreenShotHelper.ShotScreen(szFilePath, nQuality, bFullPath)
                if bStationVisible and _SettingData.bAutoHideUI then Station.Show() end
            end,100)
        end
    else
        local szFullPath = ScreenShot(nShowUI, nQuality, bFullPath)
        OutputMessage("MSG_SYS", "[�������]��ͼ�ɹ����ļ��ѱ��棺"..szFullPath.."\n")
    end
end
---------------------------------------------------
-- �����˵�
function Tms_ScreenShotHelper.GetMenuList()
	local szVersion,v  = Tms_ScreenShotHelper.GetVersion()
	return
    {  -- ���˵�
        szOption = "������ͼ����",szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=119;szLayer = "ICON_LEFT",
        { szOption = "��ǰ�汾 "..szVersion.."  ".._PluginVersion.szBuildDate,bDisable = true, },
        {  -- ʹ�������˺�ȫ���趨
			szOption = "��ʹ�������˺�ȫ���趨�� ",
			szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=119;szLayer = "ICON_RIGHT",
			bCheck = true,
			bChecked = _ScreenShotHelperData.bUseGlobalSetting,
			fnAction = function()
                _ScreenShotHelperData.bUseGlobalSetting = not _ScreenShotHelperData.bUseGlobalSetting
                if _ScreenShotHelperData.bUseGlobalSetting then Tms_ScreenShotHelper.Reload(true) end
			end,
			fnMouseEnter = function()
				TMS.MenuTip("�������趨ģʽ��\n��ѡ������ý�ɫʹ�ù����趨��ȡ����ѡ��ý�ɫʹ�õ����趨��")
			end,
			fnAutoClose = function() return true end
		},
        {bDevide = true},
        {  -- ��ͼʱ����UI
			szOption = "����ͼʱ����UI�� ",
			szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=119;szLayer = "ICON_RIGHT",
			bCheck = true,
			bChecked = (_ScreenShotHelperData.bUseGlobalSetting and _ScreenShotHelperDataGlobal.bAutoHideUI) or (not _ScreenShotHelperData.bUseGlobalSetting and _ScreenShotHelperData.bAutoHideUI),
			fnAction = function()
                if _ScreenShotHelperData.bUseGlobalSetting then
                    _ScreenShotHelperDataGlobal.bAutoHideUI = not _ScreenShotHelperDataGlobal.bAutoHideUI
                else
                    _ScreenShotHelperData.bAutoHideUI = not _ScreenShotHelperData.bAutoHideUI
                end
                Tms_ScreenShotHelper.Reload() 
			end,
			fnMouseEnter = function()
				TMS.MenuTip("��������ͼ���֡�\n��ѡ�������ͼʱ�Զ�����UI��")
			end,
			fnAutoClose = function() return true end
		},
        {  -- �����ʽ
			szOption = "ͼƬ�����ʽ ",
			szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=119;szLayer = "ICON_RIGHT",
			bCheck = false,
			bChecked = false,
			fnAction = function() end,
			fnAutoClose = function() return true end,
            --jpg
            {szOption = "jpg", bMCheck = true, bChecked = (_ScreenShotHelperData.bUseGlobalSetting and _ScreenShotHelperDataGlobal.szFileExName=="jpg") or (not _ScreenShotHelperData.bUseGlobalSetting and _ScreenShotHelperData.szFileExName=="jpg"), rgb = GetMsgFontColor("MSG_SYS", true), fnAction = function() if _ScreenShotHelperData.bUseGlobalSetting then _ScreenShotHelperDataGlobal.szFileExName="jpg" else _ScreenShotHelperData.szFileExName="jpg" end Tms_ScreenShotHelper.Reload() end, fnAutoClose = function() return true end},
            --png
            {szOption = "png", bMCheck = true, bChecked = (_ScreenShotHelperData.bUseGlobalSetting and _ScreenShotHelperDataGlobal.szFileExName=="png") or (not _ScreenShotHelperData.bUseGlobalSetting and _ScreenShotHelperData.szFileExName=="png"), rgb = GetMsgFontColor("MSG_SYS", true), fnAction = function() if _ScreenShotHelperData.bUseGlobalSetting then _ScreenShotHelperDataGlobal.szFileExName="png" else _ScreenShotHelperData.szFileExName="png" end Tms_ScreenShotHelper.Reload() end, fnAutoClose = function() return true end},
            --bmp
            {szOption = "bmp", bMCheck = true, bChecked = (_ScreenShotHelperData.bUseGlobalSetting and _ScreenShotHelperDataGlobal.szFileExName=="bmp") or (not _ScreenShotHelperData.bUseGlobalSetting and _ScreenShotHelperData.szFileExName=="bmp"), rgb = GetMsgFontColor("MSG_SYS", true), fnAction = function() if _ScreenShotHelperData.bUseGlobalSetting then _ScreenShotHelperDataGlobal.szFileExName="bmp" else _ScreenShotHelperData.szFileExName="bmp" end Tms_ScreenShotHelper.Reload() end, fnAutoClose = function() return true end},
            --tga
            {szOption = "tga", bMCheck = true, bChecked = (_ScreenShotHelperData.bUseGlobalSetting and _ScreenShotHelperDataGlobal.szFileExName=="tga") or (not _ScreenShotHelperData.bUseGlobalSetting and _ScreenShotHelperData.szFileExName=="tga"), rgb = GetMsgFontColor("MSG_SYS", true), fnAction = function() if _ScreenShotHelperData.bUseGlobalSetting then _ScreenShotHelperDataGlobal.szFileExName="tga" else _ScreenShotHelperData.szFileExName="tga" end Tms_ScreenShotHelper.Reload() end, fnAutoClose = function() return true end},
		},
        {  -- ����ͼƬ����
            szOption = "���ý�ͼ����(0-100) ",
			szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=119;szLayer = "ICON_RIGHT",
            bCheck = false,
            bChecked = false,
            fnAction = function()
                -- ��������
                GetUserInputNumber((_ScreenShotHelperData.bUseGlobalSetting and _ScreenShotHelperDataGlobal.nQuality) or _ScreenShotHelperData.nQuality, 100, nil, function(num) if _ScreenShotHelperData.bUseGlobalSetting then _ScreenShotHelperDataGlobal.nQuality=num else _ScreenShotHelperData.nQuality=num end Tms_ScreenShotHelper.Reload() end, function() end, function() end)
            end,
            fnMouseEnter = function()
                TMS.MenuTip("��������ͼ���֡�\n���ý�ͼ����(0-100)��Խ��Խ���� ͼƬҲ��Խռ�ռ䡣")
            end,
            fnAutoClose = function() return true end
        },
        {  -- ���ý�ͼ�ļ���
            szOption = "���ý�ͼ�ļ��� ",
			szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=119;szLayer = "ICON_RIGHT",
            bCheck = false,
            bChecked = false,
            fnAction = function()
                GetUserInput("���ý�ͼ�ļ��� ����Ϊ����ָ�Ĭ���ļ���", function(nVal)
                    nVal = string.gsub(nVal, "^%s*(.-)%s*$", "%1")
                    nVal = string.gsub(nVal, "^(.-)[\/]*$", "%1")
                    if nVal=="" then nVal = _ScreenShotHelperDataDefault.szFilePath else nVal = nVal .. "/" end
                    if _ScreenShotHelperData.bUseGlobalSetting then
                        _ScreenShotHelperDataGlobal.szFilePath = nVal
                    else
                        _ScreenShotHelperData.szFilePath = nVal
                    end
                    Tms_ScreenShotHelper.Reload()
                end, function() end, function() end, nil, (_ScreenShotHelperData.bUseGlobalSetting and _ScreenShotHelperDataGlobal.szFilePath) or _ScreenShotHelperData.szFilePath)
            end,
            fnMouseEnter = function()
                TMS.MenuTip("��������ͼ���֡�\n���ý�ͼ�ļ��У���ͼ�ļ������浽���õ�Ŀ¼�У�֧�־���·�������·�������·������/bin/zhcn/��")
            end,
            fnAutoClose = function() return true end
        },
    }
end
-----------------------------------------------
-- �¼���
-----------------------------------------------
RegisterEvent("CUSTOM_DATA_LOADED", Tms_ScreenShotHelper.Loaded)
-- RegisterEvent("BUFF_UPDATE", Tms_ScreenShotHelper.Breathe)
RegisterEvent("CUSTOM_DATA_LOADED", Tms_ScreenShotHelper.Reload)
-----------------------------------------------
-- ��ݼ���
-----------------------------------------------
Hotkey.AddBinding("Tms_ScreenShot_Hotkey", "��ͼ������", "������Ļ��ͼ", function() Tms_ScreenShotHelper.ShotScreen(-1) end, nil)
Hotkey.AddBinding("Tms_ScreenShot_Hotkey_HideUI", "����UI��ͼ������", "", function() Tms_ScreenShotHelper.ShotScreen(0) end, nil)
Hotkey.AddBinding("Tms_ScreenShot_Hotkey_ShowUI", "��ʾUI��ͼ������", "", function() Tms_ScreenShotHelper.ShotScreen(1) end, nil)
OutputMessage("MSG_SYS", "[�������]��������С���\n")