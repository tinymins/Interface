TMS = TMS or {}
-----------------------------------------------
-- ���غ����ͱ���
-----------------------------------------------
local _TMS = {
    szTitle = "�������",
    dwVersion = 0x0020000,
    szBuildDate = "20140227",
    szIniFile  = "Interface/TMS/TMS.ini",
    tNearNpcList = { },
    tNearPlayerList = { },
    tNearDoodadList = { },
    tLastTarget = { eTargetType = TARGET.NOT_TARGET, dwTargetID = 1 },
    tPlayerSkillList = { },
    tBreatheCall = { },
    tDelayCall = { },
}
-----------------------------------------------
-- �����ʼ��
-----------------------------------------------
_TMS.fnInit = function() 
    -- ���ؼ����б�
    local nCount = g_tTable.Skill:GetRowCount()
    for i = 1, nCount do
        local tLine = g_tTable.Skill:GetRow(i)
        if tLine~=nil and tLine.dwIconID~=nil and tLine.fSortOrder~=nil and tLine.szName~=nil and tLine.dwIconID~=13 and ( (not _TMS.tPlayerSkillList[tLine.szName]) or tLine.fSortOrder>_TMS.tPlayerSkillList[tLine.szName].fSortOrder) then
            _TMS.tPlayerSkillList[tLine.szName] = tLine
        end
    end
    --��һ�������Ǵ����ļ�·�����ڶ��������Ǵ�������Ҳ����.ini�ĵ�һ���Ǹ����֡�
    -- _TMS.frame = Station.Lookup("Normal/TMS") or Wnd.OpenWindow(_TMS.szIniFile, "TMS")
end
pcall(_TMS.fnInit)
-----------------------------------------------
-- ���ں���
-----------------------------------------------
-- breathe
TMS.OnFrameBreathe = function()
	-- run breathe calls
	local nFrame = GetLogicFrameCount()
	for k, v in pairs(_TMS.tBreatheCall) do
		if nFrame >= v.nNext then
			v.nNext = nFrame + v.nFrame
			local res, err = pcall(v.fnAction)
			if not res then
				TMS.Debug("BreatheCall#" .. k .." ERROR: " .. err)
			end
		end
	end
	-- run delay calls
	local nTime = GetTime()
	for k = #_TMS.tDelayCall, 1, -1 do
		local v = _TMS.tDelayCall[k]
		if v.nTime <= nTime then
			local res, err = pcall(v.fnAction)
			if not res then
				TMS.Debug("DelayCall#" .. k .." ERROR: " .. err)
			end
			table.remove(_TMS.tDelayCall, k)
		end
	end
end
-- create frame
TMS.OnFrameCreate = function()
	-- var
	_TMS.frame = Station.Lookup("Lowest/TMS") or Wnd.OpenWindow(_TMS.szIniFile, "TMS")
	_TMS.hTotal = this:Lookup("Wnd_Content", "")
	_TMS.hBox = _TMS.hTotal:Lookup("Box_1")
end
-----------------------------------------------
-- ͨ�ú���
-----------------------------------------------
-- (string, number) TMS.GetVersion()		-- HM�� ��ȡ�ַ����汾�� �޸ķ����ù�����
TMS.GetVersion = function()
	local v = _TMS.dwVersion
	local szVersion = string.format("%d.%d.%d", v/0x1000000,
		math.floor(v/0x10000)%0x100, math.floor(v/0x100)%0x100)
	if  v%0x100 ~= 0 then
		szVersion = szVersion .. "b" .. tostring(v%0x100)
	end
	return szVersion, v
end
-- (void) TMS.MenuTip(string str)	-- MenuTip
TMS.MenuTip = function(str)
	local szText="<image>path=\"ui/Image/UICommon/Talk_Face.UITex\" frame=25 w=24 h=24</image> <text>text=" .. EncodeComponentsString(str) .." font=207 </text>"
	local x, y = this:GetAbsPos()
	local w, h = this:GetSize()
	OutputTip(szText, 450, {x, y, w, h})
end
-- (void) TMS.print(optional nChannel, szText)   -- �����Ϣ
TMS.print = function(nChannel,szText)
	local me = GetClientPlayer()
	if szText == nil or type(nChannel) == "string" or type(nChannel) == "boolean" then
		szText = nChannel
		nChannel = PLAYER_TALK_CHANNEL.LOCAL_SYS
	end
    if type(szText) == "boolean" then szText = (szText and "true") or "false" end 
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
-- (void) TMS.print(optional nChannel,szText)    -- ���������Ϣ
TMS.println = function(nChannel,szText)
	if (type(nChannel) == "string" or type(nChannel) == "number") and szText == nil then
        TMS.print(nChannel .. "\n")
    elseif type(nChannel) == "boolean" then
        TMS.print(nChannel, (szText and "true\n") or "false\n" )
    else
        TMS.print(nChannel, szText.. "\n")
	end
end
-- (void)TMS.Gebug(szText)
TMS.Debug = function(szText)
end
-- (number) TMS.FrameToSecondLeft(nEndFrame)     -- ��ȡnEndFrameʣ������
TMS.FrameToSecondLeft = function(nEndFrame)
	local nLeftFrame = nEndFrame - GetLogicFrameCount()
	return nLeftFrame / 16
end
-- (void) TMS.Equip(szName)
TMS.Equip = function(szName)                    -- װ����ΪszName��װ��
    local me = GetClientPlayer()
    for i=1,6 do
        if me.GetBoxSize(i)>0 then
            for j=0, me.GetBoxSize(i)-1 do
                local item = me.GetItem(i,j)
                if item == nil then
                    j=j+1
                elseif GetItemNameByItem(item)==szName then
                    local eRetCode, nEquipPos = me.GetEquipPos(i, j)
                    if szName=="����" or szName=="���" then
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
-- (number) TMS.GetFaceToTargetDegree(nX,nY,nFace,nTX,nTY)   --  ����N1����������Լ�N2���� ��N2��N1�������
TMS.GetFaceToTargetDegree = function(nX,nY,nFace,nTX,nTY)
    local a = nFace * math.pi / 128
    return math.acos( ( (nTX-nX)*math.cos(a) + (nTY-nY)*math.sin(a) ) / ( (nTX-nX)^2 + (nTY-nY)^2) ^ 0.5 ) * 180 / math.pi
end
-- (bool) TMS.IsFaceToTarget(oT1,oT2)   --  ��oT2��oT1�����滹�Ǳ���
TMS.IsFaceToTarget = function(oT1,oT2)
    local a = oT1.nFaceDirection * math.pi / 128
    return (oT2.nX-oT1.nX)*math.cos(a) + (oT2.nY-oT1.nY)*math.sin(a) > 0
end
-- (table) TMS.GetBuffList(obj)
TMS.GetBuffList = function(obj)
    local aBuffTable = {}
    local nCount = obj.GetBuffCount()
    for i=1,nCount,1 do
        local dwID, nLevel, bCanCancel, nEndFrame, nIndex, nStackNum, dwSkillSrcID, bValid = obj.GetBuff(i - 1)
        if dwID then
            table.insert(aBuffTable,{dwID = dwID, nLevel = nLevel, bCanCancel = bCanCancel, nEndFrame = nEndFrame, nIndex = nIndex, nStackNum = nStackNum, dwSkillSrcID = dwSkillSrcID, bValid = bValid})
        end
    end
    return aBuffTable
end
-- (table) TMS.GetNearNpcList(void)
TMS.GetNearNpcList = function() return _TMS.tNearNpcList end
-- (table) TMS.GetNearPlayerList(void)
TMS.GetNearPlayerList = function() return _TMS.tNearPlayerList end
-- (table) TMS.GetLastTarget(void)
TMS.GetLastTarget = function() return _TMS.tLastTarget.eTargetType, _TMS.tLastTarget.dwTargetID end
-- (bool) TMS.IsValidSkill(szName)
TMS.IsValidSkill = function(szName)
    if _TMS.tPlayerSkillList[szName]==nil then return false else return true end
    -- local nCount = g_tTable.Skill:GetRowCount()
    -- for i = 1, nCount do
        -- local tLine = g_tTable.Skill:GetRow(i)
        -- if tLine.szName == szName then
            -- return true
        -- end
    -- end
    -- return false
end
-- (table) TMS.GetSkillByName(szName)
TMS.GetSkillByName = function(szName)
    return _TMS.tPlayerSkillList[szName]
    -- local nCount = g_tTable.Skill:GetRowCount()
    -- for i = 1, nCount do
        -- local tLine = g_tTable.Skill:GetRow(i)
        -- if tLine.szName == szName then
            -- return tLine
        -- end
    -- end
    -- return false
end
-- �жϵ�ǰ�û��Ƿ����ĳ������
-- (bool) TMS.CanUseSkill(number dwSkillID[, dwLevel])
TMS.CanUseSkill = function(dwSkillID, dwLevel)
    _TMS.frame = Station.Lookup("Lowest/TMS") or Wnd.OpenWindow(_TMS.szIniFile, "TMS")
    -- �жϼ����Ƿ���Ч ����������ת��Ϊ����ID
    if type(dwSkillID) == "string" then if TMS.IsValidSkill(dwSkillID) then dwSkillID = TMS.GetSkillByName(dwSkillID).dwSkillID else return false end end
	local me, box = GetClientPlayer(), _TMS.hBox
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

-- (bool)TMS.UseSkill(dwSkillID, bForceStopCurrentAction, eTargetType, dwTargetID)  -- ���뼼��ID, �Ƿ��ϵ�ǰ�˹�, �ͷ�Ŀ������, �ͷ�Ŀ��ID -- �ͷż���. �ͷųɹ�����true
TMS.UseSkill = function(dwSkillID, bForceStopCurrentAction, eTargetType, dwTargetID)
    -- �жϼ����Ƿ���Ч ����������ת��Ϊ����ID
    if type(dwSkillID) == "string" then if TMS.IsValidSkill(dwSkillID) then dwSkillID = TMS.GetSkillByName(dwSkillID).dwSkillID else return false end end
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
-- (void) TMS.LogOff(bCompletely)
TMS.LogOff = function(bCompletely)
    if bCompletely then
        ReInitUI(LOAD_LOGIN_REASON.RETURN_GAME_LOGIN)
    else
        ReInitUI(LOAD_LOGIN_REASON.RETURN_ROLE_LIST)
    end
end
-- (void) TMS.DelayCall(func fnAction, number nDelay)		-- �ӳٵ���
-- fnAction	-- ���ú���
-- nTime		-- �ӳٵ���ʱ�䣬��λ�����룬ʵ�ʵ����ӳ��ӳ��� 62.5 ��������
TMS.DelayCall = function(fnAction, nDelay)
	local nTime = nDelay + GetTime()
	table.insert(_TMS.tDelayCall, { nTime = nTime, fnAction = fnAction })
end
-- (void) TMS.BreatheCall(string szKey, func fnAction[, number nTime])  -- ע�����ѭ�����ú���
-- szKey		-- ���ƣ�����Ψһ���ظ��򸲸�
-- fnAction	-- ѭ���������ú�������Ϊ nil ���ʾȡ����� key �µĺ���������
-- nTime		-- ���ü������λ�����룬Ĭ��Ϊ 62.5����ÿ����� 16�Σ���ֵ�Զ�������� 62.5 ��������
TMS.BreatheCall = function(szKey, fnAction, nTime)
	local key = StringLowerW(szKey)
	if type(fnAction) == "function" then
		local nFrame = 1
		if nTime and nTime > 0 then
			nFrame = math.ceil(nTime / 62.5)
		end
		_TMS.tBreatheCall[key] = { fnAction = fnAction, nNext = GetLogicFrameCount() + 1, nFrame = nFrame }
	else
		_TMS.tBreatheCall[key] = nil
	end
end
-- (void) TMS.BreatheCallDelay(string szKey, nTime) -- �ı��������Ƶ��
-- nTime		-- �ӳ�ʱ�䣬ÿ 62.5 �ӳ�һ֡
TMS.BreatheCallDelay = function(szKey, nTime)
	local t = _TMS.tBreatheCall[StringLowerW(szKey)]
	if t then
		t.nFrame = math.ceil(nTime / 62.5)
		t.nNext = GetLogicFrameCount() + t.nFrame
	end
end
-- (void) TMS.BreatheCallDelayOnce(string szKey, nTime) -- �ӳ�һ�κ��������ĵ���Ƶ��
-- nTime		-- �ӳ�ʱ�䣬ÿ 62.5 �ӳ�һ֡
TMS.BreatheCallDelayOnce = function(szKey, nTime)
	local t = _TMS.tBreatheCall[StringLowerW(szKey)]
	if t then
		t.nNext = GetLogicFrameCount() + math.ceil(nTime / 62.5)
	end
end
-----------------------------------------------
-- Ŀ���� �¼���
-----------------------------------------------
RegisterEvent("NPC_ENTER_SCENE", function() if GetNpc(arg0) then _TMS.tNearNpcList[arg0] = GetNpc(arg0) end end)
RegisterEvent("NPC_LEAVE_SCENE", function() _TMS.tNearNpcList[arg0] = nil end)
RegisterEvent("PLAYER_ENTER_SCENE", function() if GetPlayer(arg0) then _TMS.tNearPlayerList[arg0] = GetPlayer(arg0) end end)    -- ��ҽ��볡�������б� _TMS.tNearPlayerList
RegisterEvent("PLAYER_LEAVE_SCENE", function() _TMS.tNearPlayerList[arg0] = nil end)                                            -- ����˳������Ƴ��б� _TMS.tNearPlayerList
RegisterEvent("DOODAD_ENTER_SCENE", function() if GetDoodad(arg0) then _TMS.tNearDoodadList[arg0] = GetDoodad(arg0) end end)
RegisterEvent("DOODAD_LEAVE_SCENE", function() _TMS.tNearDoodadList[arg0] = nil end)
AppendCommand("equip", TMS.Equip)
OutputMessage("MSG_SYS", "[�������]���Ĺ��ܼ����С���")
---------------------------------------------------
--��һ�������÷���lua�ļ���ĩβ��Ҳ�����㶨��ĺ����ĺ���
Wnd.OpenWindow(_TMS.szIniFile,"TMS")
--��һ�������Ǵ����ļ�·�����ڶ��������Ǵ�������Ҳ����.ini�ĵ�һ���Ǹ����֡�
---------------------------------------------------
-- DEBUG
RegisterEvent("CALL_LUA_ERROR", function() OutputMessage("MSG_SYS", arg0) end)