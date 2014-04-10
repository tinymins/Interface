---------------------------------
-- �������
-- by������@˫����@׷����Ӱ
-- ref: �����������Դ�� @haimanchajian.com
---------------------------------
-----------------------------------------------
-- ���غ����ͱ���
-----------------------------------------------
MY = { UI = {} }
--[[ �����Դ���
    (table) MY.LoadLangPack(void)
]]
MY.LoadLangPack = function()
	local _, _, szLang = GetVersion()
	local t0 = LoadLUAData("interface\\MY\\lang\\default.lua") or {}
	local t1 = LoadLUAData("interface\\MY\\lang\\" .. szLang .. ".lua") or {}
	for k, v in pairs(t0) do
		if not t1[k] then
			t1[k] = v
		end
	end
	setmetatable(t1, {
		__index = function(t, k) return k end,
		__call = function(t, k, ...) return string.format(t[k], ...) end,
	})
	return t1
end
local _L = MY.LoadLangPack()
-----------------------------------------------
-- ����
-----------------------------------------------
-- RegisterCustomData("_WYAutoData.")
-----------------------------------------------
-- ˽�к���
-----------------------------------------------
 _MY = {
    frame = nil,
    hBox = nil,
    nDebugLevel = 1,
    dwVersion = 0x0000100,
    szBuildDate = "20140209",
    szIniFile = "Interface\\MY\\ui\\MY.ini",
    szIniFileEditBox = "Interface\\MY\\ui\\WndEditBox.ini",
    szIniFileButton = "Interface\\MY\\ui\\WndButton.ini",
    szIniFileTabBox = "Interface\\MY\\ui\\WndTabBox.ini",
    szIniFileCheckBox = "Interface\\MY\\ui\\WndCheckBox.ini",
    szIniFileMainPanel = "Interface\\MY\\ui\\MainPanel.ini",
    szName = _L["mingyi plugins"],
    szShortName = _L["mingyi plugin"],
    tNearNpc = {},      -- ������NPC
    tNearPlayer = {},   -- ���������
    tNearDoodad = {},   -- ��������Ʒ
    tPlayerSkills = {}, -- ��Ҽ����б�[����]
    tBreatheCall = {},  -- breathe call ����
    tDelayCall = {},    -- delay call ����
    tRequest = {},      -- �����������
    tTabs = {},         -- ��ǩҳ
    tUiEventListener = {},  -- UI��Ӧ����
    tEvent = {},            -- ��Ϸ�¼���
}
_MY.Init = function()
	-- var
	_MY.hBox = _MY.frame:Lookup("","Box_1")
    -- ������Ϣ��Ӧ��
    for i, szEventName in pairs {
        "OnCheckBoxCheck", "OnCheckBoxUncheck",
        "OnItemMouseEnter", "OnItemMouseLeave",
        "OnMouseEnter", "OnMouseLeave",
        "OnLButtonClick", "OnLButtonDown", "OnLButtonUp",
        "OnRButtonClick", "OnRButtonDown", "OnRButtonUp",
        "OnItemLButtonClick", "OnItemLButtonDown", "OnItemLButtonUp",
        "OnItemRButtonClick", "OnItemRButtonDown", "OnItemRButtonUp",
        "OnGetFocus",
        "OnEditChanged",
        } do
        MY[szEventName] = function()
            local szName = this:GetName()
            local evelnr = _MY.tUiEventListener[szName]
            if evelnr and type(evelnr[szEventName]) == "function" then
                evelnr[szEventName]()
            else 
                MY.Debug(szEventName .. ' ' .. szName .."\n","unsolved event",1)
            end
        end
    end
    -- ���ڰ�ť
    MY.UI.RegisterEvent("Button_WindowClose",{
        OnLButtonClick = function() if _MY.frame then _MY.frame:Hide() end end
    })
    -- �����˵�
    local tMenu = { function() return {{
        szOption = _L["mingyi plugins"],
        fnAction = function()
            Station.Lookup("Normal/MY"):ToggleVisible()
        end,
        bCheck = true,
        bChecked = Station.Lookup("Normal/MY"):IsVisible(),
    }} end }
    TraceButton_AppendAddonMenu( tMenu )
    Player_AppendAddonMenu( tMenu )
    -- ��ʾ��ӭ��Ϣ
    MY.Sysmsg(string.format(_L["%s, welcome to use mingyi plugins!"], GetClientPlayer().szName) .. " v" .. MY.GetVersion() .. ' Build ' .. _MY.szBuildDate .. "\n")
end
-- get channel header
_MY.tTalkChannelHeader = {
	[PLAYER_TALK_CHANNEL.NEARBY] = "/s ",
	[PLAYER_TALK_CHANNEL.FRIENDS] = "/o ",
	[PLAYER_TALK_CHANNEL.TONG_ALLIANCE] = "/a ",
	[PLAYER_TALK_CHANNEL.RAID] = "/t ",
	[PLAYER_TALK_CHANNEL.BATTLE_FIELD] = "/b ",
	[PLAYER_TALK_CHANNEL.TONG] = "/g ",
	[PLAYER_TALK_CHANNEL.SENCE] = "/y ",
	[PLAYER_TALK_CHANNEL.FORCE] = "/f ",
	[PLAYER_TALK_CHANNEL.CAMP] = "/c ",
	[PLAYER_TALK_CHANNEL.WORLD] = "/h ",
}
-- parse faceicon in talking message
_MY.ParseFaceIcon = function(t)
	if not _MY.tFaceIcon then
		_MY.tFaceIcon = {}
		for i = 1, g_tTable.FaceIcon:GetRowCount() do
			local tLine = g_tTable.FaceIcon:GetRow(i)
			_MY.tFaceIcon[tLine.szCommand] = true
		end
	end
	local t2 = {}
	for _, v in ipairs(t) do
		if v.type ~= "text" then
			if v.type == "faceicon" then
				v.type = "text"
			end
			table.insert(t2, v)
		else
			local nOff, nLen = 1, string.len(v.text)
			while nOff <= nLen do
				local szFace = nil
				local nPos = StringFindW(v.text, "#", nOff)
				if not nPos then
					nPos = nLen
				else
					for i = nPos + 6, nPos + 2, -2 do
						if i <= nLen then
							local szTest = string.sub(v.text, nPos, i)
							if _MY.tFaceIcon[szTest] then
								szFace = szTest
								nPos = nPos - 1
								break
							end
						end
					end
				end
				if nPos >= nOff then
					table.insert(t2, { type = "text", text = string.sub(v.text, nOff, nPos) })
					nOff = nPos + 1
				end
				if szFace then
					table.insert(t2, { type = "text", text = szFace })
					nOff = nOff + string.len(szFace)
				end
			end
		end
	end
	return t2
end
-- parse name in talking message
_MY.ParseName = function(t)
	local t2 = {}
	for _, v in ipairs(t) do
		if v.type ~= "text" then
			if v.type == "name" then
				v = { type = "text", text = "["..v.name.."]" }
			end
			table.insert(t2, v)
		else
			local nOff, nLen = 1, string.len(v.text)
			while nOff <= nLen do
				local szName = nil
				local nPos1, nPos2 = string.find(v.text, '%[[^%[%]]+%]', nOff)
				if not nPos1 then
					nPos1 = nLen
				else
					szName = string.sub(v.text, nPos1 + 1, nPos2 - 1)
                    nPos1 = nPos1 - 1
				end
				if nPos1 >= nOff then
					table.insert(t2, { type = "text", text = string.sub(v.text, nOff, nPos1) })
					nOff = nPos1 + 1
				end
				if szName then
					table.insert(t2, { type = "name", name = szName })
					nOff = nPos2 + 1
				end
			end
		end
	end
	return t2
end
-- close window
_MY.ClosePanel = function(bRealClose)
	local frame = Station.Lookup("Normal/MY")
	if frame then
		if not bRealClose then
			frame:Hide()
		else
			Wnd.CloseWindow(frame)
			_MY.frame = nil
		end
		PlaySound(SOUND.UI_SOUND, g_sound.CloseFrame)
	end
end
-----------------------------------------------
-- ͨ�ú���
-----------------------------------------------
-- (string, number) MY.GetVersion()		-- HM�� ��ȡ�ַ����汾�� �޸ķ����ù�����
MY.GetVersion = function()
	local v = _MY.dwVersion
	local szVersion = string.format("%d.%d.%d", v/0x1000000,
		math.floor(v/0x10000)%0x100, math.floor(v/0x100)%0x100)
	if  v%0x100 ~= 0 then
		szVersion = szVersion .. "b" .. tostring(v%0x100)
	end
	return szVersion, v
end
-- (void) MY.MenuTip(string str)	-- MenuTip
MY.MenuTip = function(str)
	local szText="<image>path=\"ui/Image/UICommon/Talk_Face.UITex\" frame=25 w=24 h=24</image> <text>text=" .. EncodeComponentsString(str) .." font=207 </text>"
	local x, y = this:GetAbsPos()
	local w, h = this:GetSize()
	OutputTip(szText, 450, {x, y, w, h})
end
--[[ (void) MY.RemoteRequest(string szUrl, func fnAction)		-- ����Զ�� HTTP ����
-- szUrl		-- ��������� URL������ http:// �� https://��
-- fnAction 	-- ������ɺ�Ļص��������ص�ԭ�ͣ�function(szTitle, szContent)]]
MY.RemoteRequest = function(szUrl, fnAction)
	local page = Station.Lookup("Normal/MY/Page_1")
	if page then
		_MY.tRequest[szUrl] = fnAction
		page:Navigate(szUrl)
	end
end
--[[ ��N2��N1�������  --  ����+2
    -- ����N1���ꡢ����N2���� 
    (number) MY.GetFaceToTargetDegree(nX,nY,nFace,nTX,nTY)
    -- ����N1��N2
    (number) MY.GetFaceToTargetDegree(oN1, oN2)
    -- ���
    nil -- ��������
    number -- �����(0-180)
]]
MY.GetFaceDegree = function(nX,nY,nFace,nTX,nTY)
    if type(nY)=="userdata" and type(nX)=="userdata" then nTX=nY.nX nTY=nY.nY nY=nX.nY nFace=nX.nFaceDirection nX=nX.nX end
    if type(nX)~="number" or type(nY)~="number" or type(nFace)~="number" or type(nTX)~="number" or type(nTY)~="number" then return nil end
    local a = nFace * math.pi / 128
    return math.acos( ( (nTX-nX)*math.cos(a) + (nTY-nY)*math.sin(a) ) / ( (nTX-nX)^2 + (nTY-nY)^2) ^ 0.5 ) * 180 / math.pi
end
--[[ ��oT2��oT1�����滹�Ǳ���
    (bool) MY.IsFaceToTarget(oT1,oT2)
    -- ���淵��true
    -- ���Է���false
    -- ��������ȷʱ����nil
]]
MY.IsFaceToTarget = function(oT1,oT2)
    if type(oT1)~="userdata" or type(oT2)~="userdata" then return nil end
    local a = oT1.nFaceDirection * math.pi / 128
    return (oT2.nX-oT1.nX)*math.cos(a) + (oT2.nY-oT1.nY)*math.sin(a) > 0
end
--[[ װ����ΪszName��װ��
    (void) MY.Equip(szName)
    szName  װ������
]]
MY.Equip = function(szName)
    local me = GetClientPlayer()
    for i=1,6 do
        if me.GetBoxSize(i)>0 then
            for j=0, me.GetBoxSize(i)-1 do
                local item = me.GetItem(i,j)
                if item == nil then
                    j=j+1
                elseif GetItemNameByItem(item)==szName then
                    local eRetCode, nEquipPos = me.GetEquipPos(i, j)
                    if szName==_L["ji guan"] or szName==_L["nu jian"] then
                        for k=0,15 do
                            if me.GetItem(INVENTORY_INDEX.BULLET_PACKAGE, k) == nil then
                                OnExchangeItem(i, j, INVENTORY_INDEX.BULLET_PACKAGE, k)
                                return
                            end
                        end
                        return
                    else
                        OnExchangeItem(i, j, INVENTORY_INDEX.EQUIP, nEquipPos)
                        return
                    end
                end
            end
        end
    end
end
--[[ ��ȡ�����buff�б�
    (table) MY.GetBuffList(obj)
]]
MY.GetBuffList = function(obj)
    local aBuffTable = {}
    local nCount = obj.GetBuffCount() or 0
    for i=1,nCount,1 do
        local dwID, nLevel, bCanCancel, nEndFrame, nIndex, nStackNum, dwSkillSrcID, bValid = obj.GetBuff(i - 1)
        if dwID then
            table.insert(aBuffTable,{dwID = dwID, nLevel = nLevel, bCanCancel = bCanCancel, nEndFrame = nEndFrame, nIndex = nIndex, nStackNum = nStackNum, dwSkillSrcID = dwSkillSrcID, bValid = bValid})
        end
    end
    return aBuffTable
end
--[[ ͨ���������ƻ�ȡ���ܶ���
    (table) MY.GetSkillByName(szName)
]]
MY.GetSkillByName = function(szName) 
	if table.getn(_MY.tPlayerSkills)==0 then
        for i = 1, g_tTable.Skill:GetRowCount() do
            local tLine = g_tTable.Skill:GetRow(i)
            if tLine~=nil and tLine.dwIconID~=nil and tLine.fSortOrder~=nil and tLine.szName~=nil and tLine.dwIconID~=13 and ( (not _MY.tPlayerSkills[tLine.szName]) or tLine.fSortOrder>_MY.tPlayerSkills[tLine.szName].fSortOrder) then
                _MY.tPlayerSkills[tLine.szName] = tLine
            end
        end
    end
    return _MY.tPlayerSkills[szName]
end
--[[ �жϼ��������Ƿ���Ч
    (bool) MY.IsValidSkill(szName)
]]
MY.IsValidSkill = function(szName)
    if MY.GetSkillByName(szName)==nil then return false else return true end
end
--[[ �жϵ�ǰ�û��Ƿ����ĳ������
    (bool) MY.CanUseSkill(number dwSkillID[, dwLevel])
]]
MY.CanUseSkill = function(dwSkillID, dwLevel)
    -- �жϼ����Ƿ���Ч ����������ת��Ϊ����ID
    if type(dwSkillID) == "string" then if MY.IsValidSkill(dwSkillID) then dwSkillID = MY.GetSkillByName(dwSkillID).dwSkillID else return false end end
	local me, box = GetClientPlayer(), _MY.hBox
	if me and box then
		if not dwLevel then
			if dwSkillID ~= 9007 then
				dwLevel = me.GetSkillLevel(dwSkillID)
			else
				dwLevel = 1
			end
		end
		if dwLevel > 0 then
			box:EnableObject(false)
			box:SetObjectCoolDown(1)
			box:SetObject(UI_OBJECT_SKILL, dwSkillID, dwLevel)
			UpdataSkillCDProgress(me, box)
			return box:IsObjectEnable() and not box:IsObjectCoolDown()
		end
	end
	return false
end
--[[ �ͷż���,�ͷųɹ�����true
    (bool)MY.UseSkill(dwSkillID, bForceStopCurrentAction, eTargetType, dwTargetID)
    dwSkillID               ����ID
    bForceStopCurrentAction �Ƿ��ϵ�ǰ�˹�
    eTargetType             �ͷ�Ŀ������
    dwTargetID              �ͷ�Ŀ��ID
]]
MY.UseSkill = function(dwSkillID, bForceStopCurrentAction, eTargetType, dwTargetID)
    -- �жϼ����Ƿ���Ч ����������ת��Ϊ����ID
    if type(dwSkillID) == "string" then if MY.IsValidSkill(dwSkillID) then dwSkillID = MY.GetSkillByName(dwSkillID).dwSkillID else return false end end
    local me = GetClientPlayer()
    -- ��ȡ����CD
    local bCool, nLeft, nTotal = me.GetSkillCDProgress( dwSkillID, me.GetSkillLevel(dwSkillID) ) local bIsPrepare ,dwPreSkillID ,dwPreSkillLevel , fPreProgress= me.GetSkillPrepareState()
	local oTTP, oTID = me.GetTarget()
    if dwTargetID~=nil then SetTarget(eTargetType, dwTargetID) end
    if ( not bCool or nLeft == 0 and nTotal == 0 ) and not ( not bForceStopCurrentAction and dwPreSkillID == dwSkillID ) then
        me.StopCurrentAction() OnAddOnUseSkill( dwSkillID, me.GetSkillLevel(dwSkillID) )
        if dwTargetID then SetTarget(oTTP, oTID) end
        return true
    else
        if dwTargetID then SetTarget(oTTP, oTID) end
        return false
    end
end
--[[ �ǳ���Ϸ
    (void) MY.LogOff(bCompletely)
    bCompletely Ϊtrue���ص�½ҳ Ϊfalse���ؽ�ɫҳ Ĭ��Ϊfalse
]]
MY.LogOff = function(bCompletely)
    if bCompletely then
        ReInitUI(LOAD_LOGIN_REASON.RETURN_GAME_LOGIN)
    else
        ReInitUI(LOAD_LOGIN_REASON.RETURN_ROLE_LIST)
    end
end
--[[ ��ȡ����NPC�б�
    (table) MY.GetNearNpc(void)
]]
MY.GetNearNpc = function() return _MY.tNearNpc end
--[[ ��ȡ��������б�
    (table) MY.GetNearPlayer(void)
]]
MY.GetNearPlayer = function() return _MY.tNearPlayer end
--[[ ��ȡ������Ʒ�б�
    (table) MY.GetNearPlayer(void)
]]
MY.GetNearDoodad = function() return _MY.tNearDoodad end
--[[ (KObject) MY.GetTarget()														-- ȡ�õ�ǰĿ���������
-- (KObject) MY.GetTarget([number dwType, ]number dwID)	-- ���� dwType ���ͺ� dwID ȡ�ò�������]]
MY.GetTarget = function(dwType, dwID)
	if not dwType then
		local me = GetClientPlayer()
		if me then
			dwType, dwID = me.GetTarget()
		else
			dwType, dwID = TARGET.NO_TARGET, 0
		end
	elseif not dwID then
		dwID, dwType = dwType, TARGET.NPC
		if IsPlayer(dwID) then
			dwType = TARGET.PLAYER
		end
	end
	if dwID <= 0 or dwType == TARGET.NO_TARGET then
		return nil, TARGET.NO_TARGET
	elseif dwType == TARGET.PLAYER then
		return GetPlayer(dwID), TARGET.PLAYER
	elseif dwType == TARGET.DOODAD then
		return GetDoodad(dwID), TARGET.DOODAD
	else
		return GetNpc(dwID), TARGET.NPC
	end
end
--[[ ���� dwType ���ͺ� dwID ����Ŀ��
-- (void) MY.SetTarget([number dwType, ]number dwID)
-- dwType	-- *��ѡ* Ŀ������
-- dwID		-- Ŀ�� ID]]
MY.SetTarget = function(dwType, dwID)
	if not dwType or dwType <= 0 then
		dwType, dwID = TARGET.NO_TARGET, 0
	elseif not dwID then
		dwID, dwType = dwType, TARGET.NPC
		if IsPlayer(dwID) then
			dwType = TARGET.PLAYER
		end
	end
	SetTarget(dwType, dwID)
end
--[[ �ж�ĳ��Ƶ���ܷ���
-- (bool) MY.CanTalk(number nChannel)]]
MY.CanTalk = function(nChannel)
	for _, v in ipairs({"WHISPER", "TEAM", "RAID", "BATTLE_FIELD", "NEARBY", "TONG", "TONG_ALLIANCE" }) do
		if nChannel == PLAYER_TALK_CHANNEL[v] then
			return true
		end
	end
	return false
end
--[[ �л�����Ƶ��
-- (void) MY.SwitchChat(number nChannel)]]
MY.SwitchChat = function(nChannel)
	local szHeader = _MY.tTalkChannelHeader[nChannel]
	if szHeader then
		SwitchChatChannel(szHeader)
	elseif type(nChannel) == "string" then
		SwitchChatChannel("/w " .. nChannel .. " ")
	end
end
--[[ ������������
-- (void) MY.Talk(string szTarget, string szText[, boolean bNoEscape])
-- (void) MY.Talk([number nChannel, ] string szText[, boolean bNoEscape])
-- szTarget			-- ���ĵ�Ŀ���ɫ��
-- szText				-- �������ݣ������Ϊ���� KPlayer.Talk �� table��
-- nChannel			-- *��ѡ* ����Ƶ����PLAYER_TALK_CHANNLE.*��Ĭ��Ϊ����
-- bNoEscape	-- *��ѡ* ���������������еı���ͼƬ�����֣�Ĭ��Ϊ false
-- bSaveDeny	-- *��ѡ* �������������������ɷ��Ե�Ƶ�����ݣ�Ĭ��Ϊ false
-- �ر�ע�⣺nChannel, szText ���ߵĲ���˳����Ե�����ս��/�Ŷ�����Ƶ�������л�]]
MY.Talk = function(nChannel, szText, bNoEscape, bSaveDeny)
	local szTarget, me = "", GetClientPlayer()
	-- channel
	if not nChannel then
		nChannel = PLAYER_TALK_CHANNEL.NEARBY
	elseif type(nChannel) == "string" then
		if not szText then
			szText = nChannel
			nChannel = PLAYER_TALK_CHANNEL.NEARBY
		elseif type(szText) == "number" then
			szText, nChannel = nChannel, szText
		else
			szTarget = nChannel
			nChannel = PLAYER_TALK_CHANNEL.WHISPER
		end
	elseif nChannel == PLAYER_TALK_CHANNEL.RAID and me.GetScene().nType == MAP_TYPE.BATTLE_FIELD then
		nChannel = PLAYER_TALK_CHANNEL.BATTLE_FIELD
	end
	-- say body
	local tSay = nil
	if type(szText) == "table" then
		tSay = szText
	else
		local tar = MY.GetTarget(me.GetTarget())
		szText = string.gsub(szText, "%$zj", '['..me.szName..']')
		if tar then
			szText = string.gsub(szText, "%$mb", '['..tar.szName..']')
		end
		tSay = {{ type = "text", text = szText .. "\n"}}
	end
	if not bNoEscape then
		tSay = _MY.ParseFaceIcon(tSay)
		tSay = _MY.ParseName(tSay)
	end
	me.Talk(nChannel, szTarget, tSay)
	if bSaveDeny and not MY.CanTalk(nChannel) then
		local edit = Station.Lookup("Lowest2/EditBox/Edit_Input")
		edit:ClearText()
		for _, v in ipairs(tSay) do
			if v.type == "text" then
				edit:InsertText(v.text)
			else
				edit:InsertObj(v.text, v)
			end
		end
		-- change to this channel
		MY.SwitchChat(nChannel)
	end
end
--[[ ��ʾ������Ϣ
    MY.Sysmsg(szContent, szPrefix)
    szContent   Ҫ��ʾ��������Ϣ
    szPrefix    ��Ϣͷ��
]]
MY.Sysmsg = function(szContent, szPrefix)
    if type(szContent)=="boolean" then szContent = (szContent and 'true') or 'false' end
    szPrefix = szPrefix or _MY.szShortName
    OutputMessage("MSG_SYS", string.format("[%s]%s", szPrefix, szContent) )
end
--[[ Debug���
    (void)MY.Debug(szText, szHead, nLevel)
    szText  Debug��Ϣ
    szHead  Debugͷ
    nLevel  Debug����[���ڵ�ǰ����ֵ���������]
]]
MY.Debug = function(szText, szHead, nLevel)
    if type(nLevel)~="number" then nLevel = 1 end
    if type(szHead)~="string" then szHead = 'MY DEBUG' end
    if nLevel > _MY.nDebugLevel then
        MY.Sysmsg(szText, szHead)
    end
end
--[[ �ӳٵ���
    (void) MY.DelayCall(func fnAction, number nDelay)
    fnAction	-- ���ú���
    nTime		-- �ӳٵ���ʱ�䣬��λ�����룬ʵ�ʵ����ӳ��ӳ��� 62.5 ��������
]]
MY.DelayCall = function(fnAction, nDelay)
	local nTime = nDelay + GetTime()
	table.insert(_MY.tDelayCall, { nTime = nTime, fnAction = fnAction })
end
--[[ ע�����ѭ�����ú���
    (void) MY.BreatheCall(string szKey, func fnAction[, number nTime])
    szKey		-- ���ƣ�����Ψһ���ظ��򸲸�
    fnAction	-- ѭ���������ú�������Ϊ nil ���ʾȡ����� key �µĺ���������
    nTime		-- ���ü������λ�����룬Ĭ��Ϊ 62.5����ÿ����� 16�Σ���ֵ�Զ�������� 62.5 ��������
]]
MY.BreatheCall = function(szKey, fnAction, nTime)
	local key = StringLowerW(szKey)
	if type(fnAction) == "function" then
		local nFrame = 1
		if nTime and nTime > 0 then
			nFrame = math.ceil(nTime / 62.5)
		end
		_MY.tBreatheCall[key] = { fnAction = fnAction, nNext = GetLogicFrameCount() + 1, nFrame = nFrame }
	else
		_MY.tBreatheCall[key] = nil
	end
end
--[[ �ı��������Ƶ��
    (void) MY.BreatheCallDelay(string szKey, nTime)
    nTime		-- �ӳ�ʱ�䣬ÿ 62.5 �ӳ�һ֡
]]
MY.BreatheCallDelay = function(szKey, nTime)
	local t = _MY.tBreatheCall[StringLowerW(szKey)]
	if t then
		t.nFrame = math.ceil(nTime / 62.5)
		t.nNext = GetLogicFrameCount() + t.nFrame
	end
end
--[[ �ӳ�һ�κ��������ĵ���Ƶ��
    (void) MY.BreatheCallDelayOnce(string szKey, nTime)
    nTime		-- �ӳ�ʱ�䣬ÿ 62.5 �ӳ�һ֡
]]
MY.BreatheCallDelayOnce = function(szKey, nTime)
	local t = _MY.tBreatheCall[StringLowerW(szKey)]
	if t then
		t.nNext = GetLogicFrameCount() + math.ceil(nTime / 62.5)
	end
end
--[[ ע����Ϸ�¼�����
    -- ע��
    MY.RegisterEvent( szEventName, szListenerId, fnListener )
    MY.RegisterEvent( szEventName, fnListener )
    -- ע��
    MY.RegisterEvent( szEventName, szListenerId )
    MY.RegisterEvent( szEventName )
 ]]
MY.RegisterEvent = function(szEventName, szListenerId, fnListener)
    if type(szListenerId)=="function" then fnListener = szListenerId szListenerId = nil end
    if type(fnListener)=="function" then -- ����¼�����
        if type(_MY.tEvent[szEventName])~="table" then
            _MY.tEvent[szEventName] = {}
            RegisterEvent(szEventName, function(...)
                if type(_MY.tEvent[szEventName])=="table" then
                    for i, event in pairs(_MY.tEvent[szEventName]) do
                        event(...)
                    end
                end
            end)
        end
        if type(szListenerId)=="string" then
            _MY.tEvent[szEventName][szListenerId] = fnListener
        else
            table.insert(_MY.tEvent[szEventName], fnListener)
        end
    elseif type(szListenerId)=="string" then -- ע��ָ��ID���¼�����
        _MY.tEvent[szEventName][szListenerId] = nil
    elseif type(szListenerId)=="nil" then -- ע�������¼�����
        _MY.tEvent[szEventName] = {}
    end
end
--[[ �ػ�Tab���� ]]
MY.RedrawTabPanel = function()
    local nTop = 3
    local frame = Station.Lookup("Normal/MY/Window_Tabs"):GetFirstChild()
    while frame do
        local frame_d = frame
        frame = frame:GetNext()
        frame_d:Destroy()
    end
    local frame = Station.Lookup("Normal/MY/Window_Main"):GetFirstChild()
    while frame do
        local frame_d = frame
        frame = frame:GetNext()
        frame_d:Destroy()
    end
    for szName, tTab in pairs(_MY.tTabs) do 
        -- insert tab
        local fx = Wnd.OpenWindow(_MY.szIniFileTabBox, "aTabBox")
        if fx then    
            local item = fx:Lookup("TabBox")
            if item then
                item:ChangeRelation(Station.Lookup("Normal/MY/Window_Tabs"), true, true)
                item:SetName("TabBox_" .. szName)
                item:SetRelPos(0,nTop)
                item:Lookup("","Text_TabBox_Title"):SetText(tTab.szTitle)
                item:Lookup("","Text_TabBox_Title"):SetFontColor(unpack(tTab.rgbTitleColor))
                item:Lookup("","Text_TabBox_Title"):SetAlpha(tTab.alpha)
                item:Lookup("","Image_TabBox_Icon"):FromUITex(tTab.szIconTex, tTab.dwIconFrame)
                local w,h = item:GetSize()
                nTop = nTop + h
            end
        end
        Wnd.CloseWindow(fx)
        -- insert main panel
        fx = Wnd.OpenWindow(tTab.szIniFile, "aMainPanel")
        if fx then    
            local item = fx:Lookup("MainPanel")
            if item then
                item:ChangeRelation(Station.Lookup("Normal/MY/Window_Main"), true, true)
                item:SetName("MainPanel_" .. szName)
                item:SetRelPos(0,0)
                item:Hide()
            end
        end
        Wnd.CloseWindow(fx)
        -- register tab mouse event
        MY.UI.RegisterEvent("TabBox_" .. szName, {
            OnMouseEnter = function()
                this:Lookup("","Image_TabBox_Background"):Hide()
                this:Lookup("","Image_TabBox_Background_Hover"):Show()
            end,
            OnMouseLeave = function()
                this:Lookup("","Image_TabBox_Background"):Show()
                this:Lookup("","Image_TabBox_Background_Hover"):Hide()
            end,
            OnLButtonDown = function()
                local p = this:GetParent():GetFirstChild()
                while p do
                    p:Lookup("","Image_TabBox_Background_Sel"):Hide()
                    p = p:GetNext()
                end
                this:Lookup("","Image_TabBox_Background_Sel"):Show()
                local frame = Station.Lookup("Normal/MY/Window_Main"):GetFirstChild()
                while frame do
                    frame:Hide()
                    frame = frame:GetNext()
                end
                Station.Lookup("Normal/MY/Window_Main/MainPanel_" .. szName):Show()
            end,
        })
        -- call init function
        pcall(tTab.fnOnload)
    end
end
--[[ ע��ѡ�
    (void) MY.RegisterPanel( szName, szTitle, szIniFile, fnOnload, szIconTex, dwIconFrame, rgbaTitleColor )
    szName          ѡ�ΨһID
    szTitle         ѡ���ť����
    szIniFile       ѡ���ҳ��UI�ļ�
    fnOnload        ѡ�UI������ɺ�ִ�еĺ���
    szIconTex       ѡ�ͼ���ļ�
    dwIconFrame     ѡ�ͼ��֡
    rgbaTitleColor  ѡ�����rgba
    Ex�� MY.RegisterPanel( "TalkEx", "��������", "interface\\MY\\ui\\MainPanel.ini", "UI/Image/UICommon/ScienceTreeNode.UITex", 123, {255,255,0,200} )
 ]]
MY.RegisterPanel = function( szName, szTitle, szIniFile, fnOnload, szIconTex, dwIconFrame, rgbaTitleColor )
    if szTitle == nil then
        _MY.tTabs[szName] = nil
    else
        if type(szIniFile)~="string" then szIniFile = _MY.szIniFileMainPanel end
        if type(szIconTex)~="string" then szIniFile = 'UI/Image/Common/Logo.UITex' end
        if type(dwIconFrame)~="number" then dwIconFrame = 6 end
        if type(fnOnload)~="function" then fnOnload = function()end end
        if type(rgbaTitleColor)~="table" then rgbaTitleColor = { 255, 255, 255, 200 } end
        if type(rgbaTitleColor[1])~="number" then rgbaTitleColor[1] = 255 end
        if type(rgbaTitleColor[2])~="number" then rgbaTitleColor[2] = 255 end
        if type(rgbaTitleColor[3])~="number" then rgbaTitleColor[3] = 255 end
        if type(rgbaTitleColor[4])~="number" then rgbaTitleColor[4] = 200 end
        _MY.tTabs[szName] = { szTitle = szTitle, fnOnload = fnOnload, szIniFile = szIniFile, szIconTex = szIconTex, dwIconFrame = dwIconFrame, rgbTitleColor = {rgbaTitleColor[1],rgbaTitleColor[2],rgbaTitleColor[3]}, alpha = rgbaTitleColor[4] }
    end
    MY.RedrawTabPanel()
end
--[[ ��Ӹ�ѡ��
    MY.UI.AddCheckBox(szPanelName,szName,x,y,szText,col,bChecked)
    szPanelName Ҫ��Ӹ�ѡ��ı�ǩҳID
    szName      ��ѡ������
    x,y         ��ѡ������
    szText      ��ѡ�����
    col         ������ɫrgb
    bChecked    ��ѡ���Ƿ�ѡ
 ]]
MY.UI.AddCheckBox = function(szPanelName,szName,x,y,szText,col,bChecked)
	local fx = Wnd.OpenWindow(_MY.szIniFileCheckBox, "aCheckBox")
	if fx then    
		local item = fx:Lookup("WndCheckBox")
		if item then
			item:ChangeRelation(Station.Lookup("Normal/MY/Window_Main/MainPanel_"..szPanelName), true, true)
			item:SetName(szName)
			item:Check(bChecked)
			item:SetRelPos(x,y)
			item:Lookup("","CheckBox_Text"):SetText(szText)
			item:Lookup("","CheckBox_Text"):SetFontScheme(18)
			item:Lookup("","CheckBox_Text"):SetFontColor(unpack(col))
		end
	end
	Wnd.CloseWindow(fx)
end
--[[ ��Ӱ�ť
    MY.UI.AddButton(szPanelName,szName,x,y,szText,col)
    szPanelName Ҫ��Ӱ�ť�ı�ǩҳID
    szName      ��ť����
    x,y         ��ť����
    szText      ��ť����
    col         ������ɫrgb
 ]]
MY.UI.AddButton = function(szPanelName,szName,x,y,szText,col)
	local fx = Wnd.OpenWindow(_MY.szIniFileButton, "aWndButton")
	if fx then    
		local item = fx:Lookup("WndButton")
		if item then
			item:ChangeRelation(Station.Lookup("Normal/MY/Window_Main/MainPanel_"..szPanelName), true, true)
			item:SetName(szName)
			item:SetRelPos(x,y)
			item:Lookup("","Text_Default"):SetText(szText)
			item:Lookup("","Text_Default"):SetFontScheme(18)
			item:Lookup("","Text_Default"):SetFontColor(unpack(col))
		end
	end
	Wnd.CloseWindow(fx)
end
--[[ ����ı������
    MY.UI.AddButton(szPanelName,szName,x,y,w,h,bMultiLine)
    szPanelName Ҫ����ı������ı�ǩҳID
    szName      �ı����������
    x,y         �ı����������
    w,h         �ı�������С
    szText      �ı����ı�
    bMultiLine  �ı����Ƿ��������
 ]]
MY.UI.AddEdit = function(szPanelName,szName,x,y,w,h,szText,bMultiLine)
	local fx = Wnd.OpenWindow(_MY.szIniFileEditBox, "aEditBox")
	if fx then	
		local  item = fx:Lookup("WndEdit")
		if item then
			item:ChangeRelation(Station.Lookup("Normal/MY/Window_Main/MainPanel_"..szPanelName), true, true)
			item:SetName("WndEdit"..szName)
            item:SetSize(w,h)
			item:Lookup("Edit_Text"):SetSize(w-8,h-4)
			item:Lookup("Edit_Text"):SetMultiLine(bMultiLine)
			item:Lookup("Edit_Text"):SetText(szText or '')
			item:Lookup("Edit_Text"):SetName(szName)
			item:Lookup("","Edit_Image"):SetSize(w,h)
			item:SetRelPos(x,y)
		end
		Wnd.CloseWindow(fx)
	end 
end
--[[ Ѱ��ָ��panel�µ�ָ��id�Ŀؼ� ]]
MY.UI.Lookup = function(szPanelName, szLookupName, szLookupName2)
    if szLookupName2 then
        return _MY.frame:Lookup("Window_Main/MainPanel_"..szPanelName):Lookup(szLookupName,szLookupName2)
    else
        return _MY.frame:Lookup("Window_Main/MainPanel_"..szPanelName):Lookup(szLookupName)
    end
end
-----------------------------------------------------------------------------
-- UI Event Listener
-----------------------------------------------------------------------------
--[[ ע��UI��Ϣ��Ӧ����
    MY.UI.RegisterEvent(szName, fn) 
    szName ��Ӧ��������
    fn ��Ӧ��������
    Ex: MY.UI.RegisterEvent("TabBox", { OnMouseEnter = function() end } ) -- ע��TabBox��Ӧ����
    Ex: MY.UI.RegisterEvent("TabBox") -- ע��TabBox��Ӧ����
 ]]
MY.UI.RegisterEvent = function(szName, fn) 
    if type(szName) == "string" then
        if type(fn) == "table" then
            _MY.tUiEventListener[szName] = fn
        else
            _MY.tUiEventListener[szName] = nil
        end
    end
end

-----------------------------------------------
-- ���ں���
-----------------------------------------------
-- breathe
MY.OnFrameBreathe = function()
	-- run breathe calls
	local nFrame = GetLogicFrameCount()
	for k, v in pairs(_MY.tBreatheCall) do
		if nFrame >= v.nNext then
			v.nNext = nFrame + v.nFrame
			local res, err = pcall(v.fnAction)
			if not res then
				MY.Debug("BreatheCall#" .. k .." ERROR: " .. err)
			end
		end
	end
	-- run delay calls
	local nTime = GetTime()
	for k = #_MY.tDelayCall, 1, -1 do
		local v = _MY.tDelayCall[k]
		if v.nTime <= nTime then
			local res, err = pcall(v.fnAction)
			if not res then
				MY.Debug("DelayCall#" .. k .." ERROR: " .. err)
			end
			table.remove(_MY.tDelayCall, k)
		end
	end
end
-- create frame
MY.OnFrameCreate = function()
end
-- web page title changed
MY.OnTitleChanged = function()
	local szUrl, szTitle = this:GetLocationURL(), this:GetLocationName()
	if szUrl ~= szTitle and _MY.tRequest[szUrl] then
		local fnAction = _MY.tRequest[szUrl]
		fnAction(szTitle, this:GetDocument())
		_MY.tRequest[szUrl] = nil
	end
end
-- key down
MY.OnFrameKeyDown = function()
	if GetKeyName(Station.GetMessageKey()) == "Esc" then
		_MY.ClosePanel()
		return 1
	end
	return 0
end
---------------------------------------------------
--�򿪴���
_MY.frame = Wnd.OpenWindow(_MY.szIniFile, "MY")
---------------------------------------------------
---------------------------------------------------
-- �¼�����ݼ�ע��
RegisterEvent("NPC_ENTER_SCENE", function() if GetNpc(arg0) then _MY.tNearNpc[arg0] = GetNpc(arg0) end end)
RegisterEvent("NPC_LEAVE_SCENE", function() _MY.tNearNpc[arg0] = nil end)
RegisterEvent("PLAYER_ENTER_SCENE", function() if GetPlayer(arg0) then _MY.tNearPlayer[arg0] = GetPlayer(arg0) end end)
RegisterEvent("PLAYER_LEAVE_SCENE", function() _MY.tNearPlayer[arg0] = nil end)
RegisterEvent("DOODAD_ENTER_SCENE", function() if GetDoodad(arg0) then _MY.tNearDoodad[arg0] = GetDoodad(arg0) end end)
RegisterEvent("DOODAD_LEAVE_SCENE", function() _MY.tNearDoodad[arg0] = nil end)

AppendCommand("equip", MY.Equip)

RegisterEvent("CALL_LUA_ERROR", function() OutputMessage("MSG_SYS", arg0) end)
-- MY.RegisterEvent("CUSTOM_DATA_LOADED", _MY.Init)
MY.RegisterEvent("LOADING_END", _MY.Init)

