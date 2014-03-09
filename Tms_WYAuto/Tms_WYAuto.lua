Tms_WYAuto = Tms_WYAuto or {}
-----------------------------------------------
-- ���غ����ͱ���
-----------------------------------------------
local _WYAuto = {
	dwVersion = 0x0030000,
	szBuildDate = "20140209",
}
-----------------------------------------------
-- ����
-----------------------------------------------
_WYAutoDataDefault = {
    bAuto = true,
    bAutoJW = true,
    bAutoArea = false,
    bTabPvp = false,
    bAutoQKJY = false,  -- Ǭ�������Զ�ѡ�п���
    bAutoWDLD = false,  -- �ݶ�©���Զ�ѡ�п���
    bUnfocusJX = true,  -- ��ֹѡ�н��Ŀ���
    bEchoMsg = true,    -- ��Ϣ�����ܿ���
    cEchoChanel = PLAYER_TALK_CHANNEL.LOCAL_SYS,    -- ��Ϣ����Ƶ��
    bTargetLock = true, -- Ŀ����������
    bNoSelectSelf = true,   -- �Ƿ����������Լ�
    nTargetLockMode = 0, -- Ŀ������ģʽ�� 0 �Զ�ת�� 1 ���������ж�NPC 2 ���������ж�NPC 3 �Զ�������
    nTargetLockNearNpcDistance = 20,    -- ���������ж�NPC������
    nTargetLockNearNpcSortMode = 0,     -- �������/�ȼ����/δ��ս��/�ѽ�ս��/�����ҵ�/����˵�/Ѫ������/Ѫ���ٷֱ�����
    nTargetLockNearPlayerDistance = 20,    -- ���������ж�NPC������
    nTargetLockNearPlayerSortMode = 0,     -- �������/�ȼ����/δ��ս��/�ѽ�ս��/�����ҵ�/����˵�/Ѫ������/Ѫ���ٷֱ�����
    szBannedEnemyNames = {},                 -- ����ѡ�е�������
    szPriorEnemyNames = {},                  -- ����ѡ�е�������
    szBannedPlayerNames = {},                 -- ����ѡ�е����������
    szPriorPlayerNames = {},                  -- ����ѡ�е����������
    szAutoFocusNames = {                -- �Զ�����ѡ�е�Ŀ������
        ["������"] = true,
        ["����˿"] = true,
        ["��ħ"] = true,
        ["Ǭ������"] = true,
        ["����ʹ��"] = true,
        ["��������"] = true,
        ["�ݶ�©��"] = true,
        ["������"] = true,
        ["Ѫ��"] = true,
        ["����Ѫ��"] = true,
        ["���������"] = true,
        ["ڤ������"] = true,
        ["��������"] = false,
        ["ά��ʹ����췣��"] = true,
    }
}
_WYAutoData = _WYAutoData or _WYAutoDataDefault
for k, _ in pairs(_WYAutoData) do
	RegisterCustomData("_WYAutoData." .. k)
end
_WYAutoCache = {
    loaded = false,
    tMenuAutoFocusTarget = { },
    tMenuBannedEnemyNames = { },
    tMenuPriorEnemyNames = { },
    tMenuBannedPlayerNames = { },
    tMenuPriorPlayerNames = { },
}
----------------------------------------------------
-- ���ݳ�ʼ��
Tms_WYAuto.Loaded = function()
    if(_WYAutoCache.loaded) then return end
    _WYAutoCache.loaded = true
    
    local tMenu = {
        function()
            return {Tms_WYAuto.GetMenuList()}
        end,
    }
    Player_AppendAddonMenu(tMenu)
    Target_AppendAddonMenu({ function(dwID)
        return {
            Tms_WYAuto.GetTargetMenu(dwID),
        }
    end })
    Tms_WYAuto.Reload()
    
    -- Tms_WYAuto.println(PLAYER_TALK_CHANNEL.LOCAL_SYS, "[�ֲи���]���ݼ��سɹ�����ӭʹ���������ֲи�����")
    OutputMessage("MSG_SYS", "[�ֲи���]���ݼ��سɹ�����ӭʹ���������ֲи�����\n")
end
Tms_WYAuto.Reload = function()
    -- �Զ�ת���趨
    _WYAutoCache.tMenuAutoFocusTarget = {
        szOption = "�Զ�ת�� ",
        szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=119;szLayer = "ICON_RIGHT",
        bMCheck = true,
        bCheck = true,
        bChecked = _WYAutoData.nTargetLockMode == 0,
        fnAction = function()
            _WYAutoData.nTargetLockMode = 0
            Tms_WYAuto.println("[����������������ֲ�ר��]Ŀ������/��ǿ��ģʽ�л����Զ�ת��")
            Tms_WYAuto.Reload()
        end,
        fnAutoClose = function() return true end,
        {  -- ����µļ���Ŀ��
            szOption = "��� ",
            bCheck = false,
            bChecked = false,
            fnAction = function()
                GetUserInput("����Զ�ת��Ŀ��", function(nVal)
                    nVal = string.gsub(nVal, "^%s*(.-)%s*$", "%1")
                    if nVal~="" then _WYAutoData.szAutoFocusNames[nVal]=true end
                    Tms_WYAuto.Reload()
                end)
            end,
            fnMouseEnter = function()
                Tms_WYAuto.MenuTip("���ֲ�ר��ר�θ����ֲл���\n����µ��Զ�ת��Ŀ�ꡣ")
            end,
            fnAutoClose = function() return true end
        },
        {bDevide = true},
    }
    for szName, bFocus in pairs(_WYAutoData.szAutoFocusNames) do
        table.insert(_WYAutoCache.tMenuAutoFocusTarget, {  -- �Զ�ѡ�м���Ŀ��
            szOption = szName,
            bCheck = true,
            bChecked = bFocus,
            fnAction = function()
                _WYAutoData.szAutoFocusNames[szName] = not _WYAutoData.szAutoFocusNames[szName]
                if _WYAutoData.szAutoFocusNames[szName] == true then
                    Tms_WYAuto.println("[����������������ֲ�ר��]Ŀ������/��ǿ���Զ�ѡ��["..szName.."]�ѿ���")
                else
                    Tms_WYAuto.println("[����������������ֲ�ר��]Ŀ������/��ǿ���Զ�ѡ��["..szName.."]�ѹر�")
                end
                Tms_WYAuto.Reload()
            end,
            fnMouseEnter = function()
                Tms_WYAuto.MenuTip("���ֲ�ר��ר�θ����ֲл���\n�Զ�ѡ��["..szName.."]������л�����/����״̬��")
            end,
            fnAutoClose = function() return true end,
            { szOption="ɾ��", fnAction = function() _WYAutoData.szAutoFocusNames[szName]=nil Tms_WYAuto.Reload() end, fnAutoClose=function() return true end }
        })
    end
    -- Ŀ��������������
    _WYAutoCache.tMenuBannedEnemyNames = {
        szOption = "�������� ",
        szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=49;szLayer = "ICON_RIGHT",
        bMCheck = false,
        bCheck = false,
        bChecked = false,
        fnAction = function() end,
        fnAutoClose = function() return true end,
        {  -- ����µ���������
            szOption = "��� ",
            bCheck = false,
            bChecked = false,
            fnAction = function()
                GetUserInput("�����������", function(nVal)
                    nVal = string.gsub(nVal, "^%s*(.-)%s*$", "%1")
                    if nVal~="" then _WYAutoData.szBannedEnemyNames[nVal]=true end
                    Tms_WYAuto.Reload()
                end)
            end,
            fnMouseEnter = function()
                Tms_WYAuto.MenuTip("���ֲ�ר��ר�θ����ֲл���\n����µ��������ơ�")
            end,
            fnAutoClose = function() return true end
        },
        {bDevide = true},
    }
    for szName, bBanned in pairs(_WYAutoData.szBannedEnemyNames) do
        table.insert(_WYAutoCache.tMenuBannedEnemyNames, {  -- �Զ�ѡ�м���Ŀ��
            szOption = szName,
            bCheck = true,
            bChecked = bBanned,
            fnAction = function()
                _WYAutoData.szBannedEnemyNames[szName] = not _WYAutoData.szBannedEnemyNames[szName]
                if _WYAutoData.szBannedEnemyNames[szName] == true then
                    Tms_WYAuto.println("[����������������ֲ�ר��]Ŀ������/��ǿ����������["..szName.."]�ѿ���")
                else
                    Tms_WYAuto.println("[����������������ֲ�ר��]Ŀ������/��ǿ����������["..szName.."]�ѹر�")
                end
                Tms_WYAuto.Reload()
            end,
            fnMouseEnter = function()
                Tms_WYAuto.MenuTip("���ֲ�ר��ר�θ����ֲл���\n��������["..szName.."]������л�����/����״̬��")
            end,
            fnAutoClose = function() return true end,
            { szOption="ɾ��", fnAction = function() _WYAutoData.szBannedEnemyNames[szName]=nil Tms_WYAuto.Reload() end, fnAutoClose=function() return true end }
        })
    end
    -- Ŀ��������������
    _WYAutoCache.tMenuPriorEnemyNames = {
        szOption = "�������� ",
        szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=49;szLayer = "ICON_RIGHT",
        bMCheck = false,
        bCheck = false,
        bChecked = false,
        fnAction = function() end,
        fnAutoClose = function() return true end,
        {  -- ����µ���������
            szOption = "��� ",
            bCheck = false,
            bChecked = false,
            fnAction = function()
                GetUserInput("�����������", function(nVal)
                    nVal = string.gsub(nVal, "^%s*(.-)%s*$", "%1")
                    if nVal~="" then _WYAutoData.szPriorEnemyNames[nVal]=true end
                    Tms_WYAuto.Reload()
                end)
            end,
            fnMouseEnter = function()
                Tms_WYAuto.MenuTip("���ֲ�ר��ר�θ����ֲл���\n����µ��������ơ�")
            end,
            fnAutoClose = function() return true end
        },
        {bDevide = true},
    }
    for szName, bPrior in pairs(_WYAutoData.szPriorEnemyNames) do
        table.insert(_WYAutoCache.tMenuPriorEnemyNames, {  -- �Զ�ѡ�м���Ŀ��
            szOption = szName,
            bCheck = true,
            bChecked = bPrior,
            fnAction = function()
                _WYAutoData.szPriorEnemyNames[szName] = not _WYAutoData.szPriorEnemyNames[szName]
                if _WYAutoData.szPriorEnemyNames[szName] == true then
                    Tms_WYAuto.println("[����������������ֲ�ר��]Ŀ������/��ǿ����������["..szName.."]�ѿ���")
                else
                    Tms_WYAuto.println("[����������������ֲ�ר��]Ŀ������/��ǿ����������["..szName.."]�ѹر�")
                end
                Tms_WYAuto.Reload()
            end,
            fnMouseEnter = function()
                Tms_WYAuto.MenuTip("���ֲ�ר��ר�θ����ֲл���\n��������["..szName.."]������л�����/����״̬��")
            end,
            fnAutoClose = function() return true end,
            { szOption="ɾ��", fnAction = function() _WYAutoData.szPriorEnemyNames[szName]=nil Tms_WYAuto.Reload() end, fnAutoClose=function() return true end }
        })
    end
    -- ���������������
    _WYAutoCache.tMenuBannedPlayerNames = {
        szOption = "�������� ",
        szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=49;szLayer = "ICON_RIGHT",
        bMCheck = false,
        bCheck = false,
        bChecked = false,
        fnAction = function() end,
        fnAutoClose = function() return true end,
        {  -- ����µ���������
            szOption = "��� ",
            bCheck = false,
            bChecked = false,
            fnAction = function()
                GetUserInput("�����������", function(nVal)
                    nVal = string.gsub(nVal, "^%s*(.-)%s*$", "%1")
                    if nVal~="" then _WYAutoData.szBannedPlayerNames[nVal]=true end
                    Tms_WYAuto.Reload()
                end)
            end,
            fnMouseEnter = function()
                Tms_WYAuto.MenuTip("���ֲ�ר��ר�θ����ֲл���\n����µ��������ơ�")
            end,
            fnAutoClose = function() return true end
        },
        {bDevide = true},
    }
    for szName, bBanned in pairs(_WYAutoData.szBannedPlayerNames) do
        table.insert(_WYAutoCache.tMenuBannedPlayerNames, {  -- �Զ�ѡ�м���Ŀ��
            szOption = szName,
            bCheck = true,
            bChecked = bBanned,
            fnAction = function()
                _WYAutoData.szBannedPlayerNames[szName] = not _WYAutoData.szBannedPlayerNames[szName]
                Tms_WYAuto.Reload()
                if _WYAutoData.szBannedPlayerNames[szName] == true then
                    Tms_WYAuto.println("[����������������ֲ�ר��]Ŀ������/��ǿ����������["..szName.."]�ѿ���")
                else
                    Tms_WYAuto.println("[����������������ֲ�ר��]Ŀ������/��ǿ����������["..szName.."]�ѹر�")
                end
            end,
            fnMouseEnter = function()
                Tms_WYAuto.MenuTip("���ֲ�ר��ר�θ����ֲл���\n��������["..szName.."]������л�����/����״̬��")
            end,
            fnAutoClose = function() return true end,
            { szOption="ɾ��", fnAction = function() _WYAutoData.szBannedPlayerNames[szName]=nil Tms_WYAuto.Reload() end, fnAutoClose=function() return true end }
        })
    end
    -- ���������������
    _WYAutoCache.tMenuPriorPlayerNames = {
        szOption = "�������� ",
        szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=49;szLayer = "ICON_RIGHT",
        bMCheck = false,
        bCheck = false,
        bChecked = false,
        fnAction = function() end,
        fnAutoClose = function() return true end,
        {  -- ����µ���������
            szOption = "��� ",
            bCheck = false,
            bChecked = false,
            fnAction = function()
                GetUserInput("�����������", function(nVal)
                    nVal = string.gsub(nVal, "^%s*(.-)%s*$", "%1")
                    if nVal~="" then _WYAutoData.szPriorPlayerNames[nVal]=true end
                    Tms_WYAuto.Reload()
                end)
            end,
            fnMouseEnter = function()
                Tms_WYAuto.MenuTip("���ֲ�ר��ר�θ����ֲл���\n����µ��������ơ�")
            end,
            fnAutoClose = function() return true end
        },
        {bDevide = true},
    }
    for szName, bPrior in pairs(_WYAutoData.szPriorPlayerNames) do
        table.insert(_WYAutoCache.tMenuPriorPlayerNames, {  -- �Զ�ѡ�м���Ŀ��
            szOption = szName,
            bCheck = true,
            bChecked = bPrior,
            fnAction = function()
                _WYAutoData.szPriorPlayerNames[szName] = not _WYAutoData.szPriorPlayerNames[szName]
                if _WYAutoData.szPriorPlayerNames[szName] == true then
                    Tms_WYAuto.println("[����������������ֲ�ר��]Ŀ������/��ǿ����������["..szName.."]�ѿ���")
                else
                    Tms_WYAuto.println("[����������������ֲ�ר��]Ŀ������/��ǿ����������["..szName.."]�ѹر�")
                end
                Tms_WYAuto.Reload()
            end,
            fnMouseEnter = function()
                Tms_WYAuto.MenuTip("���ֲ�ר��ר�θ����ֲл���\n��������["..szName.."]������л�����/����״̬��")
            end,
            fnAutoClose = function() return true end,
            { szOption="ɾ��", fnAction = function() _WYAutoData.szPriorPlayerNames[szName]=nil Tms_WYAuto.Reload() end, fnAutoClose=function() return true end }
        })
    end
    TMS.BreatheCall("JW")
    TMS.BreatheCall("AutoFocusTarget")
    TMS.BreatheCall("LockNearTarget")
    if not _WYAutoData.bAuto then return end
    if _WYAutoData.bAutoJW == true then TMS.BreatheCall("JW", Tms_WYAuto.AutoJW) end
    if _WYAutoData.bTargetLock then 
        if _WYAutoData.nTargetLockMode == 0 then 
            TMS.BreatheCall("AutoFocusTarget", Tms_WYAuto.AutoFocusTarget)
        elseif _WYAutoData.nTargetLockMode == 1 then 
            TMS.BreatheCall("LockNearTarget", Tms_WYAuto.AutoLockNearTarget)
        elseif _WYAutoData.nTargetLockMode == 2 then 
            TMS.BreatheCall("LockNearTarget", Tms_WYAuto.AutoLockNearTarget)
        elseif _WYAutoData.nTargetLockMode == 3 then 
            return
        end
    end
end
-----------------------------------------------
-- ͨ�ú���
-----------------------------------------------
-- (string, number) Tms_WYAuto.GetVersion()		-- HM�� ��ȡ�ַ����汾�� �޸ķ����ù�����
Tms_WYAuto.GetVersion = function()
	local v = _WYAuto.dwVersion
	local szVersion = string.format("%d.%d.%d", v/0x1000000,
		math.floor(v/0x10000)%0x100, math.floor(v/0x100)%0x100)
	if  v%0x100 ~= 0 then
		szVersion = szVersion .. "b" .. tostring(v%0x100)
	end
	return szVersion, v
end
-- (void) Tms_WYAuto.MenuTip(string str)	-- MenuTip
Tms_WYAuto.MenuTip = function(str)
	local szText="<image>path=\"ui/Image/UICommon/Talk_Face.UITex\" frame=25 w=24 h=24</image> <text>text=" .. EncodeComponentsString(str) .." font=207 </text>"
	local x, y = this:GetAbsPos()
	local w, h = this:GetSize()
	OutputTip(szText, 450, {x, y, w, h})
end

--(void) Tms_WYAuto.print(optional nChannel, szText)     -- �����Ϣ
Tms_WYAuto.print = function(nChannel,szText)
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
--(void) Tms_WYAuto.println(optional nChannel,szText)     -- ���������Ϣ
Tms_WYAuto.println = function(nChannel,szText)
	if type(nChannel) == "string" then
        Tms_WYAuto.print(nChannel .. "\n")
    else
        Tms_WYAuto.print(nChannel, szText .. "\n")
	end
end

----------------------------------------------------
local _SelectPoint = UserSelect.SelectPoint ---HOOK����ѡ�к��� ��ΪĬ��ֱ��ѡ��----
function UserSelect.SelectPoint(fnAction, fnCancel, fnCondition, box) --��ȡ�ͷŵ� ����
	_SelectPoint(fnAction, fnCancel, fnCondition, box) --��ʾ����ѡ��
	if _WYAutoData.bAuto and _WYAutoData.bAutoArea then -- ���ش�
		local t = GetTargetHandle(GetClientPlayer().GetTarget()) or GetClientPlayer()
		UserSelect.DoSelectPoint(t.nX, t.nY, t.nZ)
	end
end
----------------------------------------------------
--ע�� Tms_WYAuto.tBreatheAction["A"]=B	A���� B����
--ע�� Tms_WYAuto.tBreatheAction["A"]=nil
----------------------------------------------------
--��Ŀ�꼼���ͷ�--
function InvalidCast(dwSkillID, dwSkillLevel)
	local player = GetClientPlayer()
	local oTTP, oTID = player.GetTarget()
    dwSkillLevel = dwSkillLevel or player.GetSkillLevel(dwSkillID)
	local bCool, nLeft, nTotal = player.GetSkillCDProgress(dwSkillID, dwSkillLevel)
	if not bCool or nLeft == 0 and nTotal == 0 then
		SetTarget(TARGET.NOT_TARGET, 0)
		OnAddOnUseSkill(dwSkillID, dwSkillLevel)
        -- Tms_WYAuto.println(dwSkillID,"  ",dwSkillLevel)
        -- OnAddOnUseSkill(dwSkillID, 1)
		if player.dwID == oTID then
			SetTarget(TARGET.PLAYER, player.dwID)
		else
			SetTarget(oTTP, oTID)
		end
	end
end
---------------------------------------------------
-- (bool)��������Ƿ�ӵ��ָ��id��buff
function buff(id)
    for _,v in pairs(GetClientPlayer().GetBuffList() or {}) do
		if v.dwID == id then
      		return true
    	end
    end
    return false
end
---------------------------------------------------
-- (bool)��������Ƿ��ڿɹҷ�ҡ״̬
function stand()
 	local N = GetClientPlayer()
	if N then
		local state = N.nMoveState
		if state == MOVE_STATE.ON_STAND or state == MOVE_STATE.ON_FLOAT or state == MOVE_STATE.ON_FREEZE or state == MOVE_STATE.ON_ENTRAP then
			return true
		end
	end
	return false
end

---------------------------------------------------
-- (void)��ֹѡ�н���
Tms_WYAuto.AutoUnfocusJX = function()
    if _WYAutoData.bAuto and _WYAutoData.bUnfocusJX then -- ��ֹѡ�н��Ŀ��ش�
        local player = GetClientPlayer()
        local tar = GetTargetHandle(player.GetTarget())
        if(tar and tar.szName == "����") then
            player.StopCurrentAction()
            SetTarget(TARGET.PLAYER,player.dwID)
        end
    end
end
RegisterEvent("DO_SKILL_PREPARE_PROGRESS",Tms_WYAuto.AutoUnfocusJX) -- ���ܿ�ʼ���� -- arg0=����׼��֡�� -- arg1=����ID -- arg2=���ܵȼ�
RegisterEvent("DO_SKILL_CAST",Tms_WYAuto.AutoUnfocusJX) -- �����ͷ� -- arg0=����ID -- arg1=����ID -- arg2=���ܵȼ�
RegisterEvent("PLAYER_STATE_UPDATE",Tms_WYAuto.AutoUnfocusJX)
RegisterEvent("SYNC_ROLE_DATA_END",Tms_WYAuto.AutoUnfocusJX)

---------------------------------------------------
-- Ŀ������ �¼���
_WYAutoCache.LastTarget = {
    eTargetType = TARGET.NOT_TARGET,
    dwTargetID = 1,
    bRefocused = true,
}

---------------------------------------------------
-- (void)�Զ�ת��
Tms_WYAuto.AutoFocusTarget = function()
    if not _WYAutoData.bAuto then return end
    local me = GetClientPlayer() if not me then return end
    local tar = GetTargetHandle( me.GetTarget() )
    local tNearNpcList = TMS.GetNearNpcList()
    if tar and tar.nCurrentLife > 0 and _WYAutoData.szAutoFocusNames[tar.szName] then return end -- �����ǰĿ����ת�������ﲢ�Ҵ�� �򷵻�
    for tid,ttar in pairs(tNearNpcList) do
        if ttar and ttar.nCurrentLife > 0 and _WYAutoData.szAutoFocusNames[ttar.szName] then
            if ( tar and tar.szName ) then _WYAutoCache.LastTarget.eTargetType, _WYAutoCache.LastTarget.dwTargetID = me.GetTarget() _WYAutoCache.LastTarget.bRefocused=false end
            SetTarget(TARGET.NPC,tid)
            return
        end
    end
    if(not tar)and(not _WYAutoCache.LastTarget.bRefocused) then SetTarget(_WYAutoCache.LastTarget.eTargetType, _WYAutoCache.LastTarget.dwTargetID) _WYAutoCache.LastTarget.bRefocused=true end
end
---------------------------------------------------
-- (void)�Զ�ѡ��ָ����Χ�ڵж�NPC
Tms_WYAuto.AutoLockNearTarget = function()
    local player = GetClientPlayer() if not player then return end
    if _WYAutoData.bTargetLock and ( _WYAutoData.nTargetLockMode == 1 or _WYAutoData.nTargetLockMode == 2 ) then 
        local dwNpcID = 0            -- ��¼ �������/�ȼ����/δ��ս��/�ѽ�ս��/�����ҵ�/Ѫ������/Ѫ���ٷֱ����� ��NPC��ID
        local nLowestNpcPropertiesValue = 9999  -- ��ǰ�ο�������Сֵ
        local nMaxBanPriorOffset = -1           -- ��ǰ����˳������ֵ
        local dwNearestNpcID = 0                -- �������NPC ID
        local nNearestDistance = 9999           -- �������NPC����
        local nThisDistance = 9999              -- ��ǰNPC����
        local nearTargetList = (_WYAutoData.nTargetLockMode==1 and TMS.GetNearNpcList()) or TMS.GetNearPlayerList()
        if _WYAutoData.bNoSelectSelf then nearTargetList[player.dwID]=nil end
        local nTargetLockNearNpcDistance = (_WYAutoData.nTargetLockMode==1 and _WYAutoData.nTargetLockNearNpcDistance) or _WYAutoData.nTargetLockNearPlayerDistance
        for npcid,npc in pairs(nearTargetList) do
            if IsEnemy(player.dwID, npcid) or _WYAutoData.nTargetLockMode==2 then
                local switch = {
                    [0] = function(player,npc)    -- �������
                        return GetCharacterDistance(player.dwID, npc.dwID)
                    end,
                    [1] = function(player,npc)    -- �ȼ����
                        return npc.nLevel
                    end,
                    [2] = function(player,npc)    -- δ��ս��
                        if npc.bFightState then return -1 else return -2 end
                    end,
                    [3] = function(player,npc)    -- �ѽ�ս��
                        if npc.bFightState then return -2 else return -1 end
                    end,
                    [4] = function(player,npc)    -- �����ҵ�
                        if npc.bFightState and GetTargetHandle(npc.GetTarget()) and GetTargetHandle(npc.GetTarget()).dwID == player.dwID then return -2 else return -1 end
                    end,
                    [5] = function(player,npc)    -- ����˵�
                        if npc.bFightState and GetTargetHandle(npc.GetTarget()) and GetTargetHandle(npc.GetTarget()).dwID ~= player.dwID then return -2 else return -1 end
                    end,
                    [6] = function(player,npc)    -- Ѫ������
                        return npc.nCurrentLife
                    end,
                    [7] = function(player,npc)    -- Ѫ���ٷֱ�����
                        return npc.nCurrentLife*100/npc.nMaxLife
                    end,
                }
                local fnGetBanPriorOffset = (_WYAutoData.nTargetLockMode==1 and function(szName)    -- ��ȡѡ��˳����ֵ�ӳ�
                    if _WYAutoData.szBannedEnemyNames[szName] then   -- ���ε�
                        return  -1
                    elseif _WYAutoData.szPriorEnemyNames[szName] then-- ���ȵ�
                        return 1
                    else                                        -- Ĭ�ϵ�
                        return 0
                    end
                end) or function(szName)    -- ��ȡѡ��˳����ֵ�ӳ�
                    if _WYAutoData.szBannedPlayerNames[szName] then   -- ���ε�
                        return  -1
                    elseif _WYAutoData.szPriorPlayerNames[szName] then-- ���ȵ�
                        return 1
                    else                                        -- Ĭ�ϵ�
                        return 0
                    end
                end
                local f = (_WYAutoData.nTargetLockMode==1 and switch[_WYAutoData.nTargetLockNearNpcSortMode]) or switch[_WYAutoData.nTargetLockNearPlayerSortMode]
                if(f) then
                    -- ��Ŀ������/�����б�Ȩ��
                    local nBanPriorOffset = fnGetBanPriorOffset(npc.szName)
                    -- ��Ŀ����㹫ʽ����Ŀ������Ȩ��
                    local nNpcPropertiesValue = f(player,npc)
                    -- ��Ŀ�����
                    local nDistance = GetCharacterDistance(player.dwID, npc.dwID)
                    if ( npc and nDistance/64 < nTargetLockNearNpcDistance  -- ��Ŀ����벻��������趨ֵ
                         and ( npc.nCurrentLife > 0 and nBanPriorOffset > -1    -- Ŀ�����û�б���������
                            and ( nBanPriorOffset > nMaxBanPriorOffset   -- ���ȼ�����
                                  or ( nNpcPropertiesValue < nLowestNpcPropertiesValue and nBanPriorOffset == nMaxBanPriorOffset ) -- ���ȼ���ͬ�ο���С
                                  or ( nNpcPropertiesValue == nLowestNpcPropertiesValue and nBanPriorOffset == nMaxBanPriorOffset and nDistance < nThisDistance )       -- ���ȼ���ͬ�ο�����ͬ�������
                                ) 
                             ) 
                    ) then
                        nMaxBanPriorOffset = nBanPriorOffset
                        nLowestNpcPropertiesValue = nNpcPropertiesValue
                        nThisDistance = nDistance
                        dwNpcID = npcid
                    end
                    if nBanPriorOffset > -1 and ( dwNearestNpcID == 0 or ( nDistance < nNearestDistance and nDistance/64 < nTargetLockNearNpcDistance ) ) then
                        nNearestDistance = nDistance
                        dwNearestNpcID = npcid
                    end
                -- else                -- for case default
                    -- Tms_WYAuto.print "Case default."
                end
            end
        end
        -- ѡ�з���Ҫ������Ŀ�� û����ѡ�������Ŀ��
        local nTargetType = (_WYAutoData.nTargetLockMode==1 and TARGET.NPC) or TARGET.PLAYER
        if dwNpcID ~= 0 and nLowestNpcPropertiesValue ~= -1 then SetTarget(nTargetType,dwNpcID) elseif dwNearestNpcID~=0 then SetTarget(nTargetType,dwNearestNpcID) end
    end
end

---------------------------------------------------
-- (void)�����Զ�����
Tms_WYAuto.AutoJW = function()
    -- ��ȡ��ǰ���װ�����ڹ�ID
	-- local Kungfu = UI_GetPlayerMountKungfuID() --GetClientPlayer().GetKungfuMount().dwSkillID
	-- if Kungfu and Kungfu ~= 10080 and Kungfu ~= 10081 then
		-- return
	-- end
	local me = GetClientPlayer()
	if not me or not me.GetKungfuMount() or me.GetOTActionState() ~= 0 then
		return
	end
	-- 7x
	if me.GetKungfuMount().dwMountType == 4 then
		-- auto dance
        if stand() and not buff(409) then
            InvalidCast(537)
        end
    end
end
----------------------------------------------------

---------------------------------------------------
-- �����˵�
Tms_WYAuto.GetMenuList = function()
	local szVersion,v  = Tms_WYAuto.GetVersion()
	local menu = {  -- ���˵�
			szOption = "�������ֲе�����",szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=119;szLayer = "ICON_LEFT",{
				szOption = "��ǰ�汾 "..szVersion.."  ".._WYAuto.szBuildDate,bDisable = true,
			}
		}
	local menu_a_0 = {  -- �ֲ�ģʽ�ܿ���
			szOption = "���ֲ�ģʽ�ܿ��ء� ",
			szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=119;szLayer = "ICON_RIGHT",
			bCheck = true,
			bChecked = _WYAutoData.bAuto,
			fnAction = function()
                _WYAutoData.bAuto = not _WYAutoData.bAuto
                if _WYAutoData.bAuto == true then
                    Tms_WYAuto.println("[����������������ֲ�ר��]�ֲ�ģʽ�ѿ���")
                else
                    Tms_WYAuto.println("[����������������ֲ�ר��]�ֲ�ģʽ�ѹر�")
                end
                Tms_WYAuto.Reload()
			end,
			fnMouseEnter = function()
				Tms_WYAuto.MenuTip("���ֲ�ר��ר�θ����ֲл���\n�ܿ��أ�����л�״̬��")
			end,
			fnAutoClose = function() return true end
		}
	local menu_a_1 = {  -- ����Ƶ��
			szOption = "������Ƶ���� ",
            --SYS
            {szOption = "ϵͳƵ��", bMCheck = true, bChecked = _WYAutoData.cEchoChanel == PLAYER_TALK_CHANNEL.LOCAL_SYS, rgb = GetMsgFontColor("MSG_SYS", true), fnAction = function() _WYAutoData.cEchoChanel = PLAYER_TALK_CHANNEL.LOCAL_SYS end, fnAutoClose = function() return true end},
            --����Ƶ��
            {szOption = g_tStrings.tChannelName.MSG_NORMAL, bMCheck = true, bChecked = _WYAutoData.cEchoChanel == PLAYER_TALK_CHANNEL.NEARBY, rgb = GetMsgFontColor("MSG_NORMAL", true), fnAction = function() _WYAutoData.cEchoChanel = PLAYER_TALK_CHANNEL.NEARBY end, fnAutoClose = function() return true end},
            --�Ŷ�Ƶ��
            {szOption = g_tStrings.tChannelName.MSG_TEAM, bMCheck = true, bChecked = _WYAutoData.cEchoChanel == PLAYER_TALK_CHANNEL.RAID, rgb = GetMsgFontColor("MSG_TEAM", true), fnAction = function() _WYAutoData.cEchoChanel = PLAYER_TALK_CHANNEL.RAID end, fnAutoClose = function() return true end},
            --���Ƶ��
            {szOption = g_tStrings.tChannelName.MSG_GUILD, bMCheck = true, bChecked = _WYAutoData.cEchoChanel == PLAYER_TALK_CHANNEL.TONG, rgb = GetMsgFontColor("MSG_GUILD", true), fnAction = function() _WYAutoData.cEchoChanel = PLAYER_TALK_CHANNEL.TONG end, fnAutoClose = function() return true end},
			szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=119;szLayer = "ICON_RIGHT",
			bCheck = true,
			bChecked = _WYAutoData.bEchoMsg,
			fnAction = function()
                _WYAutoData.bEchoMsg = not _WYAutoData.bEchoMsg
                if _WYAutoData.bEchoMsg == true then
                    Tms_WYAuto.println("[����������������ֲ�ר��]���÷����ѿ���")
                else
                    Tms_WYAuto.println("[����������������ֲ�ר��]���÷����ѹر�")
                end
			end,
			-- fnMouseEnter = function()
				-- Tms_WYAuto.MenuTip("���ֲ�ר��ר�θ����ֲл���\n�ܿ��أ�����л�״̬��")
			-- end,
			fnAutoClose = function() return true end,
		}
	local menu_b_1 = {  -- Ŀ������/��ǿ
        szOption = "Ŀ������/��ǿ ",
        szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=119;szLayer = "ICON_RIGHT", 
        bCheck = true,
        bChecked = _WYAutoData.bTargetLock,
        fnAction = function()
            _WYAutoData.bTargetLock = not _WYAutoData.bTargetLock
            if _WYAutoData.bTargetLock == true then
                Tms_WYAuto.println("[����������������ֲ�ר��]Ŀ������/��ǿ�ѿ���")
            else
                Tms_WYAuto.println("[����������������ֲ�ר��]Ŀ������/��ǿ�ѹر�")
            end
        end,
        fnAutoClose = function() return true end,
        -- �Զ�ת��
        _WYAutoCache.tMenuAutoFocusTarget,
        {  -- ���������ж�NPC
            szOption = "���������ж�NPC ",
            szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=119;szLayer = "ICON_RIGHT",
            bMCheck = true,
            bCheck = true,
            bChecked = _WYAutoData.nTargetLockMode == 1,
            fnAction = function()
                _WYAutoData.nTargetLockMode = 1
                Tms_WYAuto.println("[����������������ֲ�ר��]Ŀ������/��ǿ��ģʽ�л������������ж�NPC")
                Tms_WYAuto.Reload()
            end,
            fnAutoClose = function() return true end,
            {  -- ����������
                szOption = "��������������� ",
                bCheck = false,
                bChecked = false,
                fnAction = function()
                    -- ��������
                    GetUserInputNumber(_WYAutoData.nTargetLockNearNpcDistance, 100, nil, function(num) _WYAutoData.nTargetLockNearNpcDistance = num end, function() end, function() end)
                end,
                fnMouseEnter = function()
                    Tms_WYAuto.MenuTip("���ֲ�ר��ר�θ����ֲл���\n���������롣")
                end,
                fnAutoClose = function() return true end
            },
            { bDevide = true }, 
            {  -- ����ѡ��
                szOption = "����ѡ�У� ",
                fnAutoClose = function() return true end,
                szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=49;szLayer = "ICON_RIGHT",
                -- �������
                {szOption = "�������", bMCheck = true, bChecked = _WYAutoData.nTargetLockNearNpcSortMode == 0, rgb = GetMsgFontColor("MSG_GUILD", true), fnAction = function() _WYAutoData.nTargetLockNearNpcSortMode = 0 end, fnAutoClose = function() return true end},
                -- �ȼ����
                {szOption = "�ȼ����", bMCheck = true, bChecked = _WYAutoData.nTargetLockNearNpcSortMode == 1, rgb = GetMsgFontColor("MSG_GUILD", true), fnAction = function() _WYAutoData.nTargetLockNearNpcSortMode = 1 end, fnAutoClose = function() return true end},
                -- δ��ս��
                {szOption = "δ��ս��", bMCheck = true, bChecked = _WYAutoData.nTargetLockNearNpcSortMode == 2, rgb = GetMsgFontColor("MSG_GUILD", true), fnAction = function() _WYAutoData.nTargetLockNearNpcSortMode = 2 end, fnAutoClose = function() return true end},
                -- �ѽ�ս��
                {szOption = "�ѽ�ս��", bMCheck = true, bChecked = _WYAutoData.nTargetLockNearNpcSortMode == 3, rgb = GetMsgFontColor("MSG_GUILD", true), fnAction = function() _WYAutoData.nTargetLockNearNpcSortMode = 3 end, fnAutoClose = function() return true end},
                -- �����ҵ�
                {szOption = "�����ҵ�", bMCheck = true, bChecked = _WYAutoData.nTargetLockNearNpcSortMode == 4, rgb = GetMsgFontColor("MSG_GUILD", true), fnAction = function() _WYAutoData.nTargetLockNearNpcSortMode = 4 end, fnAutoClose = function() return true end},
                -- ����˵�
                {szOption = "����˵�", bMCheck = true, bChecked = _WYAutoData.nTargetLockNearNpcSortMode == 5, rgb = GetMsgFontColor("MSG_GUILD", true), fnAction = function() _WYAutoData.nTargetLockNearNpcSortMode = 5 end, fnAutoClose = function() return true end},
                -- Ѫ������
                {szOption = "Ѫ������", bMCheck = true, bChecked = _WYAutoData.nTargetLockNearNpcSortMode == 6, rgb = GetMsgFontColor("MSG_GUILD", true), fnAction = function() _WYAutoData.nTargetLockNearNpcSortMode = 6 end, fnAutoClose = function() return true end},
                -- Ѫ���ٷֱ�����
                {szOption = "Ѫ���ٷֱ�����", bMCheck = true, bChecked = _WYAutoData.nTargetLockNearNpcSortMode == 7, rgb = GetMsgFontColor("MSG_GUILD", true), fnAction = function() _WYAutoData.nTargetLockNearNpcSortMode = 7 end, fnAutoClose = function() return true end},
            },
            _WYAutoCache.tMenuBannedEnemyNames,
            _WYAutoCache.tMenuPriorEnemyNames,
        }, 
        {  -- �����������
            szOption = "����������� ",
            szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=119;szLayer = "ICON_RIGHT",
            bMCheck = true,
            bCheck = true,
            bChecked = _WYAutoData.nTargetLockMode == 2,
            fnAction = function()
                _WYAutoData.nTargetLockMode = 2
                Tms_WYAuto.println("[����������������ֲ�ר��]Ŀ������/��ǿ��ģʽ�л��������������")
                Tms_WYAuto.Reload()
            end,
            fnAutoClose = function() return true end,
            {  -- ����������
                szOption = "��������������� ",
                bCheck = false,
                bChecked = false,
                fnAction = function()
                    -- ��������
                    GetUserInputNumber(_WYAutoData.nTargetLockNearPlayerDistance, 100, nil, function(num) _WYAutoData.nTargetLockNearPlayerDistance = num end, function() end, function() end)
                end,
                fnMouseEnter = function()
                    Tms_WYAuto.MenuTip("���ֲ�ר��ר�θ����ֲл���\n���������롣")
                end,
                fnAutoClose = function() return true end
            },
            {  -- ����������
                szOption = "�����������Լ�ΪĿ�� ",
                bCheck = true,
                bChecked = _WYAutoData.bNoSelectSelf ,
                fnAction = function()
                    _WYAutoData.bNoSelectSelf = not _WYAutoData.bNoSelectSelf
                end,
                fnMouseEnter = function()
                    Tms_WYAuto.MenuTip("���ֲ�ר��ר�θ����ֲл���\n���������Լ���������ʱ�����Լ�ΪĿ�ꡣ")
                end,
                fnAutoClose = function() return true end
            },
            { bDevide = true }, 
            {  -- ����ѡ��
                szOption = "����ѡ�У� ",
                fnAutoClose = function() return true end,
                szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=49;szLayer = "ICON_RIGHT",
                -- �������
                {szOption = "�������", bMCheck = true, bChecked = _WYAutoData.nTargetLockNearPlayerSortMode == 0, rgb = GetMsgFontColor("MSG_GUILD", true), fnAction = function() _WYAutoData.nTargetLockNearPlayerSortMode = 0 end, fnAutoClose = function() return true end},
                -- �ȼ����
                {szOption = "�ȼ����", bMCheck = true, bChecked = _WYAutoData.nTargetLockNearPlayerSortMode == 1, rgb = GetMsgFontColor("MSG_GUILD", true), fnAction = function() _WYAutoData.nTargetLockNearPlayerSortMode = 1 end, fnAutoClose = function() return true end},
                -- δ��ս��
                {szOption = "δ��ս��", bMCheck = true, bChecked = _WYAutoData.nTargetLockNearPlayerSortMode == 2, rgb = GetMsgFontColor("MSG_GUILD", true), fnAction = function() _WYAutoData.nTargetLockNearPlayerSortMode = 2 end, fnAutoClose = function() return true end},
                -- �ѽ�ս��
                {szOption = "�ѽ�ս��", bMCheck = true, bChecked = _WYAutoData.nTargetLockNearPlayerSortMode == 3, rgb = GetMsgFontColor("MSG_GUILD", true), fnAction = function() _WYAutoData.nTargetLockNearPlayerSortMode = 3 end, fnAutoClose = function() return true end},
                -- �����ҵ�
                {szOption = "�����ҵ�", bMCheck = true, bChecked = _WYAutoData.nTargetLockNearPlayerSortMode == 4, rgb = GetMsgFontColor("MSG_GUILD", true), fnAction = function() _WYAutoData.nTargetLockNearPlayerSortMode = 4 end, fnAutoClose = function() return true end},
                -- ����˵�
                {szOption = "����˵�", bMCheck = true, bChecked = _WYAutoData.nTargetLockNearPlayerSortMode == 5, rgb = GetMsgFontColor("MSG_GUILD", true), fnAction = function() _WYAutoData.nTargetLockNearPlayerSortMode = 5 end, fnAutoClose = function() return true end},
                -- Ѫ������
                {szOption = "Ѫ������", bMCheck = true, bChecked = _WYAutoData.nTargetLockNearPlayerSortMode == 6, rgb = GetMsgFontColor("MSG_GUILD", true), fnAction = function() _WYAutoData.nTargetLockNearPlayerSortMode = 6 end, fnAutoClose = function() return true end},
                -- Ѫ���ٷֱ�����
                {szOption = "Ѫ���ٷֱ�����", bMCheck = true, bChecked = _WYAutoData.nTargetLockNearPlayerSortMode == 7, rgb = GetMsgFontColor("MSG_GUILD", true), fnAction = function() _WYAutoData.nTargetLockNearPlayerSortMode = 7 end, fnAutoClose = function() return true end},
            },
            _WYAutoCache.tMenuBannedPlayerNames,
            _WYAutoCache.tMenuPriorPlayerNames,
        }, 
        {  -- �Զ���Ŀ������
            szOption = "�Զ���Ŀ������ ",
            szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=119;szLayer = "ICON_RIGHT",
            bMCheck = true,
            bCheck = true,
            bChecked = _WYAutoData.nTargetLockMode == 3,
            fnAction = function()
                _WYAutoData.nTargetLockMode = 3
                Tms_WYAuto.println("[����������������ֲ�ר��]Ŀ������/��ǿ��ģʽ�л����Զ���Ŀ������")
                Tms_WYAuto.Reload()
            end,
            fnAutoClose = function() return true end,
            {  -- �����༭��
                szOption = "�����༭�� ",
                szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=49;szLayer = "ICON_RIGHT",
                bCheck = false,
                bChecked = false,
                fnAction = function()
                    -- ��������
                end,
                fnMouseEnter = function()
                    Tms_WYAuto.MenuTip("���ֲ�ר��ר�θ����ֲл���\n�Զ���Ŀ�����������༭����")
                end,
                fnAutoClose = function() return true end
            },
        }, 
        { bDevide = true }, 
        {  -- ��ֹѡ�н���
            szOption = "��ֹѡ�н��� ",
            szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=49;szLayer = "ICON_RIGHT",
            bCheck = true,
            bChecked = _WYAutoData.bUnfocusJX,
            fnAction = function()
                _WYAutoData.bUnfocusJX = not _WYAutoData.bUnfocusJX
                if _WYAutoData.bUnfocusJX == true then
                    Tms_WYAuto.println("[����������������ֲ�ר��]��ֹѡ�н����ѿ���")
                else
                    Tms_WYAuto.println("[����������������ֲ�ר��]��ֹѡ�н����ѹر�")
                end
            end,
            fnMouseEnter = function()
                Tms_WYAuto.MenuTip("���ֲ�ר��ר�θ����ֲл���\n��ֹѡ�н��ķ�ֹ���ˣ�����л�����/����״̬��")
            end,
            fnAutoClose = function() return true end
        },
    }
	local menu_b_2 = {  -- �Զ�����
			szOption = "�Զ����� ",
			szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=49;szLayer = "ICON_RIGHT",
			bCheck = true,
			bChecked = _WYAutoData.bAutoJW,
			fnAction = function()
                _WYAutoData.bAutoJW = not _WYAutoData.bAutoJW
                Tms_WYAuto.Reload()
                if _WYAutoData.bAutoJW == true then
                    Tms_WYAuto.println("[����������������ֲ�ר��]�Զ������ѿ���")
                else
                    Tms_WYAuto.println("[����������������ֲ�ר��]�Զ������ѹر�")
                end
			end,
			fnMouseEnter = function()
				Tms_WYAuto.MenuTip("���ֲ�ר��ר�θ����ֲл���\n�Զ����裬����л�����/����״̬��")
			end,
			fnAutoClose = function() return true end
		}
	local menu_b_3 = {  -- ��Χ���ܸ���
			szOption = "��Χ���ܸ��� ",
			szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=49;szLayer = "ICON_RIGHT",
			bCheck = true,
			bChecked = _WYAutoData.bAutoArea,
			fnAction = function()
                _WYAutoData.bAutoArea = not _WYAutoData.bAutoArea
                if _WYAutoData.bAutoArea==true then
                    Tms_WYAuto.println("[����������������ֲ�ר��]��Χ���ܸ����ѿ���")
                else
                    Tms_WYAuto.println("[����������������ֲ�ר��]��Χ���ܸ����ѹر�")
                end
			end,
			fnMouseEnter = function()
				Tms_WYAuto.MenuTip("���ֲ�ר��ר�θ����ֲл���\n��Χ������Ŀ�����Լ��ͷţ�����л�����/����״̬��")
			end,
			fnAutoClose = function() return true end
		}
	local menu_b_4 = {  -- ֻTab���
			szOption = "ֻTab��� ",
			szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=49;szLayer = "ICON_RIGHT",
			bCheck = true,
			bChecked = _WYAutoData.bTabPvp,
			fnAction = function()
                _WYAutoData.bTabPvp = not _WYAutoData.bTabPvp
                if _WYAutoData.bTabPvp == true then
                    Tms_WYAuto.println("[����������������ֲ�ר��]ֻTab����ѿ���")
                else
                    Tms_WYAuto.println("[����������������ֲ�ר��]ֻTab����ѹر�")
                end
                --true����������� --pvp
                SearchTarget_SetOtherSettting("OnlyPlayer",_WYAutoData.bTabPvp, "Enmey")
			end,
			fnMouseEnter = function()
				Tms_WYAuto.MenuTip("���ֲ�ר��ר�θ����ֲл���\nֻTab��ң�����л�����/����״̬��")
			end,
			fnAutoClose = function() return true end
		}
	local menu_b_5 = {  -- ����
			szOption = "���� ",
			szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=49;szLayer = "ICON_RIGHT",
			bCheck = false,
			fnAction = function() end,
			fnAutoClose = function() return true end,
            {  -- �޼���������ë
			szOption = "�޼���������ë ",
			szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=49;szLayer = "ICON_RIGHT",
			bCheck = false,
			fnAction = function() 
                local me = GetClientPlayer()
                for tid,tar in pairs(TMS.GetNearPlayerList()) do
                    if tar and tar.dwSchoolID == 2 and tar.dwID~=me.dwID then
                        local tSay = {
                            {type = "name", name = me.szName},
                            {type = "text", text = "�����İι���"},
                            {type = "name", name = tar.szName},
                            {type = "text", text = "����ë��"},
                        }
                        me.Talk( _WYAutoData.cEchoChanel or PLAYER_TALK_CHANNEL.NEARBY, "", tSay)
                    end
                end
                local tSay = {
                    {type = "name", name = me.szName},
                    {type = "text", text = "��ʰ��һ�±��������ë��ϣ�������������ü�Ǯ��"},
                }
                me.Talk( _WYAutoData.cEchoChanel or PLAYER_TALK_CHANNEL.NEARBY, "", tSay)
            end,
			fnMouseEnter = function()
				Tms_WYAuto.MenuTip("���ֲ�ר��ר�θ����ֲл���\n�޼�һ�¸������еĴ���")
			end,
			fnAutoClose = function() return true end
		}
		}
	local menu_c_1 = {  -- �˻ؽ�ɫ�б�
			szOption = "�˻ؽ�ɫ�б� ",
			szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=119;szLayer = "ICON_RIGHT",
			bCheck = false,
			bChecked = false,
			fnAction = function()
                ReInitUI(LOAD_LOGIN_REASON.RETURN_ROLE_LIST)
			end,
			fnMouseEnter = function()
				Tms_WYAuto.MenuTip("���ؽ�ɫѡ��ҳ��")
			end,
			fnAutoClose = function() return true end
		}
	local menu_c_2 = {  -- �˻ص�¼����
			szOption = "�˻ص�¼���� ",
			szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=119;szLayer = "ICON_RIGHT",
			bCheck = false,
			bChecked = false,
			fnAction = function()
                ReInitUI(LOAD_LOGIN_REASON.RETURN_GAME_LOGIN)
			end,
			fnMouseEnter = function()
				Tms_WYAuto.MenuTip("�����˺ŵ�¼ҳ��")
			end,
			fnAutoClose = function() return true end
		}
	--table.insert(menu_0_0, menu_0_0_0)
    -- table.insert(menu_0, menu_0_0)
    table.insert(menu, menu_a_0)
    table.insert(menu, menu_a_1)
	table.insert(menu, {bDevide = true})
	table.insert(menu, menu_b_1)
	table.insert(menu, menu_b_2)
	table.insert(menu, menu_b_3)
	table.insert(menu, menu_b_4)
	table.insert(menu, menu_b_5)
	table.insert(menu, {bDevide = true})
	table.insert(menu, menu_c_1)
	table.insert(menu, menu_c_2)
	return menu
end

---------------------------------------------------
-- �����˵�
Tms_WYAuto.GetTargetMenu = function(dwID)
    local tar = GetNpc(dwID)
    local bIsNpc = true
    if not tar then tar = GetPlayer(dwID) bIsNpc = false end
    local szName = false
    if tar then szName = tar.szName end
	return {  -- Ŀ��˵�
        szOption = "[Ŀ��ѡ��]���������б�",
        szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=119;szLayer = "ICON_RIGHT",
        bCheck = true,
        bChecked = (bIsNpc and _WYAutoData.szBannedEnemyNames[szName]) or _WYAutoData.szBannedPlayerNames[szName],
        fnAction = function()
            if not szName then return end
            if bIsNpc then _WYAutoData.szBannedEnemyNames[szName] = not _WYAutoData.szBannedEnemyNames[szName]
            else _WYAutoData.szBannedPlayerNames[szName] = not _WYAutoData.szBannedPlayerNames[szName] end
            if (bIsNpc and _WYAutoData.szBannedEnemyNames[szName]) or _WYAutoData.szBannedPlayerNames[szName] then
                Tms_WYAuto.println("[����������������ֲ�ר��]�Ѽ���Ŀ��ѡ�������б�"..szName)
            else
                Tms_WYAuto.println("[����������������ֲ�ר��]���Ƴ�Ŀ��ѡ�������б�"..szName)
            end
            Tms_WYAuto.Reload()
        end,
        fnMouseEnter = function()
            Tms_WYAuto.MenuTip("���ֲ�ר��ר�θ����ֲл���\n����/�Ƴ� Ŀ���Զ�ѡ���б�")
        end,
        fnAutoClose = function() return true end
    }
	,{  -- Ŀ��˵�
        szOption = "[Ŀ��ѡ��]���������б�",
        szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=119;szLayer = "ICON_RIGHT",
        bCheck = true,
        bChecked = (bIsNpc and _WYAutoData.szPriorEnemyNames[szName]) or _WYAutoData.szPriorPlayerNames[szName],
        fnAction = function()
            if not szName then return end
            if bIsNpc then _WYAutoData.szPriorEnemyNames[szName] = not _WYAutoData.szPriorEnemyNames[szName]
            else _WYAutoData.szPriorPlayerNames[szName] = not _WYAutoData.szPriorPlayerNames[szName] end
            if (bIsNpc and _WYAutoData.szPriorEnemyNames[szName]) or _WYAutoData.szPriorPlayerNames[szName] then
                Tms_WYAuto.println("[����������������ֲ�ר��]�Ѽ���Ŀ��ѡ�������б�"..szName)
            else
                Tms_WYAuto.println("[����������������ֲ�ר��]���Ƴ�Ŀ��ѡ�������б�"..szName)
            end
            Tms_WYAuto.Reload()
        end,
        fnMouseEnter = function()
            Tms_WYAuto.MenuTip("���ֲ�ר��ר�θ����ֲл���\n����/�Ƴ� Ŀ���Զ�ѡ���б�")
        end,
        fnAutoClose = function() return true end
    }
    ,{  -- Ŀ��ת��
        szOption = "[Ŀ��ת��]����ת���б�",
        szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=119;szLayer = "ICON_RIGHT",
        bCheck = true,
        bChecked = _WYAutoData.szAutoFocusNames[szName],
        fnAction = function()
            if not szName then return end
            _WYAutoData.szAutoFocusNames[szName] = not _WYAutoData.szAutoFocusNames[szName]
            if _WYAutoData.szAutoFocusNames[szName] then
                Tms_WYAuto.println("[����������������ֲ�ר��]�Ѽ���Ŀ�꼯���б�"..szName)
            else
                Tms_WYAuto.println("[����������������ֲ�ר��]���Ƴ�Ŀ�꼯���б�"..szName)
            end
            Tms_WYAuto.Reload()
        end,
        fnMouseEnter = function()
            Tms_WYAuto.MenuTip("���ֲ�ר��ר�θ����ֲл���\n����/�Ƴ� Ŀ���Զ������б�")
        end,
        fnAutoClose = function() return true end
    }
end
---------------------------------------------------
-- �¼�ע��
-- RegisterEvent("LOGIN_GAME", function()
	-- local tMenu = {
		-- function()
			-- return {Tms_WYAuto.GetMenuList()}
		-- end,
	-- }
	-- Player_AppendAddonMenu(tMenu)
-- end)
RegisterEvent("CUSTOM_DATA_LOADED", Tms_WYAuto.Loaded)
-- RegisterEvent("BUFF_UPDATE", Tms_WYAuto.Breathe)
RegisterEvent("CUSTOM_DATA_LOADED", Tms_WYAuto.Reload)
Tms_WYAuto.println(PLAYER_TALK_CHANNEL.LOCAL_SYS, "[�ֲи���]��������С���")

---------------------------------------------------
--��һ�������÷���lua�ļ���ĩβ��Ҳ�����㶨��ĺ����ĺ���
-- Wnd.OpenWindow("Interface/Tms_WYAuto/Tms_WYAuto.ini","Tms_WYAuto")
--��һ�������Ǵ����ļ�·�����ڶ��������Ǵ�������Ҳ����WYAuto.ini�ĵ�һ���Ǹ����֡�
---------------------------------------------------