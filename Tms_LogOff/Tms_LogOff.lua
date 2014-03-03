----------------------------------------------------
-- �������ٵǳ� ver 0.1 Build 20140303
-- Code by: ��һ��tinymins @ ZhaiYiMing.CoM
-- ���塤˫��������
----------------------------------------------------
Tms_LogOff = Tms_LogOff or {}
-----------------------------------------------
-- ���غ����ͱ���
-----------------------------------------------
local _PluginVersion = {
	dwVersion = 0x0010000,
	szBuildDate = "20140303",
}
local _LogOffCache = {
    loaded = false,
    bLogOffExRunning = false,
}
_LogOffData = {
    bTimeOutLogOff = false,
    nTimeOutUnixTime = GetCurrentTime()+3600,
    bPlayerLeaveLogOff = false,
    szPlayerLeaveNames = "",
    bClientLevelOverLogOff = false,
    nClientLevelOver = 90,
}
for k, _ in pairs(_LogOffData) do
	RegisterCustomData("_LogOffData." .. k)
end
----------------------------------------------------
-- ���ݳ�ʼ��
Tms_LogOff.Loaded = function()
    if(_LogOffCache.loaded) then return end
    _LogOffCache.loaded = true
    
    Player_AppendAddonMenu({function()
        return {
            Tms_LogOff.GetMenuList()
        }
    end })
end
-----------------------------------------------
-- ͨ�ú���
-----------------------------------------------
-- (string, number) Tms_LogOff.GetVersion()		-- HM�� ��ȡ�ַ����汾�� �޸ķ����ù�����
Tms_LogOff.GetVersion = function()
	local v = _PluginVersion.dwVersion
	local szVersion = string.format("%d.%d.%d", v/0x1000000,
		math.floor(v/0x10000)%0x100, math.floor(v/0x100)%0x100)
	if  v%0x100 ~= 0 then
		szVersion = szVersion .. "b" .. tostring(v%0x100)
	end
	return szVersion, v
end
-- (void)Tms_LogOff.LogOff(bCompletely, bUnfight)
Tms_LogOff.LogOffEx = function(bCompletely, bUnfight)
    if not bUnfight then TMS.LogOff(bCompletely) return end
    -- �ѽ�ս���ͷŻ�����
    for i,v in ipairs({"����","������ɢ","������Ӱ"}) do
        if TMS.CanUseSkill(v) then TMS.UseSkill(v) end
    end
    OutputMessage("MSG_SYS", "[�������]��ս�ǳ������������ͷ���ս���ܣ���Ϸ������ս˲�����ߡ�\n")
    -- ��Ӻ��������ȴ���ս��
    TMS.BreatheCall("LOG_OFF",function()
        if not GetClientPlayer().bFightState then
            TMS.LogOff(bCompletely)    -- ����ս�����ߡ�
        end
    end)
end
Tms_LogOff.ConditionLogOff = function()
    local bLogOff = false
    if _LogOffData.bTimeOutLogOff and GetCurrentTime()>_LogOffData.nTimeOutUnixTime then bLogOff = true end
    local bAllPlayerLeave = true
    if _LogOffData.bPlayerLeaveLogOff and _LogOffData.szPlayerLeaveNames~="" then
        local tNearPlayer = TMS.GetNearPlayerList()
        for i,szName in pairs(string.split(_LogOffData.szPlayerLeaveNames, ',')) do
            for _,v in pairs(tNearPlayer) do
                if v.szName == szName then bAllPlayerLeave = false end
            end
        end
    else bAllPlayerLeave = false
    end
    if _LogOffData.bClientLevelOverLogOff and GetClientPlayer().nLevel>=_LogOffData.nClientLevelOver then bLogOff=true end
    bLogOff = bLogOff or bAllPlayerLeave
    if bLogOff then TMS.LogOff(true) end
end
Tms_LogOff.ToggleConditionLogOff = function(bRunning)
    local szTip = ""
    if bRunning==nil then bRunning = not _LogOffCache.bLogOffExRunning end
    _LogOffCache.bLogOffExRunning = bRunning
    if _LogOffCache.bLogOffExRunning then
        TMS.BreatheCall("TMS_ConditionLogOff", Tms_LogOff.ConditionLogOff, 1000)
        szTip = szTip .. "----------------------------------------------\n"
        szTip = szTip .. "[�������]��Ϸ���ڷ�����������֮һʱ�˳���¼��\n"
        if _LogOffData.bTimeOutLogOff then
            local tDate = TimeToDate(_LogOffData.nTimeOutUnixTime)
            szTip = szTip .. "����ϵͳʱ�䳬����" .. (string.format("%04d��%02d��%02d�� %02d:%02d:%02d (%d���)", tDate.year, tDate.month, tDate.day, tDate.hour, tDate.minute, tDate.second, _LogOffData.nTimeOutUnixTime-GetCurrentTime())) .. "\n"
        end
        if _LogOffData.bPlayerLeaveLogOff then
            szTip = szTip .. "�����������ȫ����ʧ����Ұ��" .. _LogOffData.szPlayerLeaveNames .. "\n"
        end
        if _LogOffData.bClientLevelOverLogOff then
            szTip = szTip .. "��������ȼ��ﵽ" .. _LogOffData.nClientLevelOver .. "��ʱ��\n"
        end
        szTip = szTip .. "----------------------------------------------\n"
    else
        TMS.BreatheCall("TMS_ConditionLogOff")
        szTip = szTip .. "[�������]�����ǳ��ѹر�\n"
    end
    TMS.print(szTip)
end
---------------------------------------------------
-- �����˵�
function Tms_LogOff.GetMenuList()
	local szVersion,v  = Tms_LogOff.GetVersion()
	return
    {  -- ���˵�
        szOption = "�������ٵǳ�",szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=119;szLayer = "ICON_LEFT",
        { szOption = "��ǰ�汾 "..szVersion.."  ".._PluginVersion.szBuildDate,bDisable = true, },
        {  -- ������������
			szOption = "������������ ",
			szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=119;szLayer = "ICON_RIGHT",
			bCheck = true,
			bChecked = _LogOffCache.bLogOffExRunning,
			fnAction = function()
                Tms_LogOff.ToggleConditionLogOff()
			end,
			fnAutoClose = function() return true end,
            {  -- ��ʼ
                szOption = "��ʼ ",
                szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=119;szLayer = "ICON_RIGHT",
                bCheck = true,
                bChecked = _LogOffCache.bLogOffExRunning,
                fnAction = function()
                    Tms_LogOff.ToggleConditionLogOff()
                end,
                fnMouseEnter = function()
                    TMS.MenuTip("�������ǳ���\n�����ʼ���У�����������ʱ�Զ����ߡ�\n�ٴε��ȡ���趨��")
                end,
                fnAutoClose = function() return true end
            },
            {bDevide = true},
            {  -- ָ��ʱ�������
                szOption = "ָ��ʱ������� ",
                szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=119;szLayer = "ICON_RIGHT",
                bCheck = true,
                bChecked = _LogOffData.bTimeOutLogOff,
                fnAction = function()
                    if _LogOffData.bTimeOutLogOff then
                        _LogOffData.bTimeOutLogOff = false
                    else
                        -- ��������
                        GetUserInputNumber(3600, 2592000, nil, function(num) _LogOffData.nTimeOutUnixTime = GetCurrentTime()+num _LogOffData.bTimeOutLogOff=true end, function() end, function() end)
                    end
                end,
                fnMouseEnter = function()
                    TMS.MenuTip("�������ǳ���\n����趨��ָ������֮�����ߣ���һСʱ��������3600���ȷ����\n�ٴε��ȡ���趨��")
                end,
                fnAutoClose = function() return true end
            },
            {  -- ָ�������ʧ������
                szOption = "ָ�������ʧ������ ",
                szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=119;szLayer = "ICON_RIGHT",
                bCheck = true,
                bChecked = _LogOffData.bPlayerLeaveLogOff,
                fnAction = function()
                    if _LogOffData.bPlayerLeaveLogOff then
                        _LogOffData.bPlayerLeaveLogOff = false
                    else
                        -- ��������
                        GetUserInput("����������ƣ���������ö��ŷָ���", function(nVal)
                            nVal = (string.gsub(nVal, "^%s*(.-)%s*$", "%1"))
                            nVal = (string.gsub(nVal, "��", ","))
                            _LogOffData.szPlayerLeaveNames = nVal
                            if nVal~="" then _LogOffData.bPlayerLeaveLogOff=true end
                        end, function() end, function() end, nil, _LogOffData.szPlayerLeaveNames )
                    end
                end,
                fnMouseEnter = function()
                    TMS.MenuTip("�������ǳ���\n����趨��ָ�����ȫ����ʧ֮�����ߣ��������֮���ð�Ƕ��ŷָ���\n�ٴε��ȡ���趨��")
                end,
                fnAutoClose = function() return true end
            },
            {  -- ����ȼ�����ָ��ֵ����
                szOption = "����ȼ�����ָ��ֵ���� ",
                szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=119;szLayer = "ICON_RIGHT",
                bCheck = true,
                bChecked = _LogOffData.bClientLevelOverLogOff,
                fnAction = function()
                    if _LogOffData.bClientLevelOverLogOff then
                        _LogOffData.bClientLevelOverLogOff = false
                    else
                        -- ��������
                        GetUserInputNumber(90, 100, nil, function(num) _LogOffData.nClientLevelOver = num _LogOffData.bClientLevelOverLogOff=true end, function() end, function() end)
                    end
                end,
                fnMouseEnter = function()
                    TMS.MenuTip("�������ǳ���\n����趨������ȼ�����ָ��ֵ֮�����ߣ���24��������24���ȷ����\n�ٴε��ȡ���趨��")
                end,
                fnAutoClose = function() return true end
            },
		},
        {bDevide = true},
        {  -- ���ؽ�ɫѡ��
			szOption = "���ؽ�ɫѡ�� ",
			szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=119;szLayer = "ICON_RIGHT",
			bCheck = false,
			bChecked = false,
			fnAction = function()
                Tms_LogOff.LogOffEx(false)
			end,
			fnMouseEnter = function()
				TMS.MenuTip("�����ٵǳ���\nǿ�Ʒ��ؽ�ɫѡ��ҳ�档")
			end,
			fnAutoClose = function() return true end
		},
        {  -- �����û���¼
			szOption = "�����û���¼ ",
			szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=119;szLayer = "ICON_RIGHT",
			bCheck = false,
			bChecked = false,
			fnAction = function()
                Tms_LogOff.LogOffEx(true)
			end,
			fnMouseEnter = function()
				TMS.MenuTip("�����ٵǳ���\nǿ�Ʒ����˻���¼ҳ�档")
			end,
			fnAutoClose = function() return true end
		},
        {  -- ��ս�󷵻ؽ�ɫѡ��
			szOption = "��ս�󷵻ؽ�ɫѡ�� ",
			szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=119;szLayer = "ICON_RIGHT",
			bCheck = false,
			bChecked = false,
			fnAction = function()
                Tms_LogOff.LogOffEx(false, true)
			end,
			fnMouseEnter = function()
				TMS.MenuTip("�����ٵǳ���\n����һ������ս����һ˲�䷵�ؽ�ɫѡ��ҳ�档")
			end,
			fnAutoClose = function() return true end
		},
        {  -- ��ս�󷵻��û���¼
			szOption = "��ս�󷵻��û���¼ ",
			szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=119;szLayer = "ICON_RIGHT",
			bCheck = false,
			bChecked = false,
			fnAction = function()
                Tms_LogOff.LogOffEx(true, true)
			end,
			fnMouseEnter = function()
				TMS.MenuTip("�����ٵǳ���\n����һ������ս����һ˲�䷵���˻���¼ҳ�档")
			end,
			fnAutoClose = function() return true end
		},
    }
end
-----------------------------------------------
-- �¼���
-----------------------------------------------
RegisterEvent("CUSTOM_DATA_LOADED", Tms_LogOff.Loaded)
-- RegisterEvent("BUFF_UPDATE", Tms_LogOff.Breathe)
-----------------------------------------------
-- ��ݼ���
-----------------------------------------------
Hotkey.AddBinding("Tms_LogOff_Hotkey_RUI", "�����û���½ҳ", "�������ٵǳ�", function() Tms_LogOff.LogOffEx(true) end, nil)
Hotkey.AddBinding("Tms_LogOff_Hotkey_RRL", "���ؽ�ɫѡ��ҳ", "", function() Tms_LogOff.LogOffEx(false) end, nil)
Hotkey.AddBinding("Tms_LogOff_Hotkey_RUI_NOT_FIGHT", "��ս�������û���½ҳ", "", function() Tms_LogOff.LogOffEx(true, true) end, nil)
Hotkey.AddBinding("Tms_LogOff_Hotkey_RRL_NOT_FIGHT", "��ս�����ؽ�ɫѡ��ҳ", "", function() Tms_LogOff.LogOffEx(false, true) end, nil)
AppendCommand("logoff", function(szParam)
    local bCompletely, bUnfight = string.find(szParam, "��ɫ")==nil, string.find(szParam, "��ս")~=nil
    Tms_LogOff.LogOffEx(bCompletely, bUnfight)
end)