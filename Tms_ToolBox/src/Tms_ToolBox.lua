-----------------------------------------------
-- ���غ����ͱ���
-----------------------------------------------
Tms_ToolBox = {
    dwVersion = 0x0030000,
    szBuildDate = "20140209",
}
-----------------------------------------------
-- ����
-----------------------------------------------
-- RegisterCustomData("_WYAutoData.")
local _WYAutoCache = {
    loaded = false,
}
----------------------------------------------------
-- ���ݳ�ʼ��
Tms_ToolBox.Loaded = function()
    OutputMessage("MSG_SYS", "[�ֲи���]���ݼ��سɹ�����ӭʹ���������ֲи�����\n")
end
-----------------------------------------------
-- ͨ�ú���
-----------------------------------------------
-- (string, number) Tms_ToolBox.GetVersion()		-- HM�� ��ȡ�ַ����汾�� �޸ķ����ù�����
Tms_ToolBox.GetVersion = function()
	local v = _WYAuto.dwVersion
	local szVersion = string.format("%d.%d.%d", v/0x1000000,
		math.floor(v/0x10000)%0x100, math.floor(v/0x100)%0x100)
	if  v%0x100 ~= 0 then
		szVersion = szVersion .. "b" .. tostring(v%0x100)
	end
	return szVersion, v
end
-- (void) Tms_ToolBox.MenuTip(string str)	-- MenuTip
Tms_ToolBox.MenuTip = function(str)
	local szText="<image>path=\"ui/Image/UICommon/Talk_Face.UITex\" frame=25 w=24 h=24</image> <text>text=" .. EncodeComponentsString(str) .." font=207 </text>"
	local x, y = this:GetAbsPos()
	local w, h = this:GetSize()
	OutputTip(szText, 450, {x, y, w, h})
end

--(void) Tms_ToolBox.print(optional nChannel, szText)     -- �����Ϣ
Tms_ToolBox.print = function(nChannel,szText)
	local me = GetClientPlayer()
	if type(nChannel) == "string" then
		szText = nChannel
		nChannel = _WYAutoData.cEchoChanel or PLAYER_TALK_CHANNEL.LOCAL_SYS
	end
	local tSay = {{ type = "text", text = szText }}
	if nChannel == PLAYER_TALK_CHANNEL.RAID and me.GetScene().nType == MAP_TYPE.BATTLE_FIELD then
		nChannel = PLAYER_TALK_CHANNEL.BATTLE_FIELD
    end
	if nChannel == PLAYER_TALK_CHANNEL.LOCAL_SYS then
		OutputMessage("MSG_SYS", szText)
	elseif _WYAutoData.bEchoMsg then
		me.Talk(nChannel,"",tSay)
	end
end
--(void) Tms_ToolBox.println(optional nChannel,szText)     -- ���������Ϣ
Tms_ToolBox.println = function(nChannel,szText)
	if type(nChannel) == "string" then
        Tms_ToolBox.print(nChannel .. "\n")
    else
        Tms_ToolBox.print(nChannel, szText .. "\n")
	end
end

Tms_ToolBox.RegisterPanel = function( szName, szTitle, fn, szIconTex, dwIconFrame, rgbTitleColor )
    local frame = Station.Lookup("Normal/Tms_ToolBox")
    
    local fx = Wnd.OpenWindow("interface\\Tms_ToolBox\\ui\\TabBox.ini", "aTabBox")
    if fx then    
        local item = fx:Lookup("TabBox")
        Output(item)
        if item then
            item:ChangeRelation(Station.Lookup("Normal/Tms_ToolBox"):Lookup("WndWindow_Total"):Lookup("WndWindow_Tabs"), true, true)
            item:SetName(szName)
            item:SetRelPos(0,100)
            item:Lookup("","Text_TabBox_Title"):SetText(szTitle)
            item:Lookup("","Text_TabBox_Title"):SetFontScheme(18)
        end
    end
    Wnd.CloseWindow(fx)
end
---------------------------------------------------
-- �����˵�
function Tms_ToolBox.GetMenuList()
	return {  -- ���˵�
        szOption = "����������",szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=119;szLayer = "ICON_LEFT",fnAction = function() 	Station.Lookup("Normal/Tms_ToolBox"):Show() end,
    }
end

---------------------------------------------------
-- �¼�ע��
OutputMessage("MSG_SYS","[�������]����������С���")
TraceButton_AppendAddonMenu( {{ szOption = "����������",szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=119;szLayer = "ICON_LEFT",fnAction = function() 	Station.Lookup("Normal/Tms_ToolBox"):ToggleVisible() end, }} )
Player_AppendAddonMenu( {{ szOption = "����������",szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=119;szLayer = "ICON_LEFT",fnAction = function() 	Station.Lookup("Normal/Tms_ToolBox"):ToggleVisible() end, }} )
---------------------------------------------------
--��һ�������÷���lua�ļ���ĩβ��Ҳ�����㶨��ĺ����ĺ���
Wnd.OpenWindow("Interface\\Tms_ToolBox\\ui\\Tms_ToolBox.ini","Tms_ToolBox")
--��һ�������Ǵ����ļ�·�����ڶ��������Ǵ�������Ҳ����WYAuto.ini�ĵ�һ���Ǹ����֡�
---------------------------------------------------
RegisterEvent("CALL_LUA_ERROR", function() OutputMessage("MSG_SYS", arg0) end)
Tms_ToolBox.RegisterPanel( "szName", "szTitle", "szIconTex", "dwIconFrame", "fn" )