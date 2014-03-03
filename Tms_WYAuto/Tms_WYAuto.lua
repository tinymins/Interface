Tms_WYAuto = Tms_WYAuto or {}
-----------------------------------------------
-- ���غ����ͱ���
-----------------------------------------------
local _WYAuto = {
	dwVersion = 0x0020000,
	szBuildDate = "20140129",
}
-----------------------------------------------
-- ����
-----------------------------------------------
_WYAutoData = {
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
    nTargetLockMode = 0, -- Ŀ������ģʽ�� 0 �Զ�ת�� 1 ���������ж�NPC 2 �Զ�������
    nTargetLockNearNpcDistance = 20,    -- ���������ж�NPC������
    nTargetLockNearNpcSortMode = 0,     -- �������/�ȼ����/δ��ս��/�ѽ�ս��/�����ҵ�/����˵�/Ѫ������/Ѫ���ٷֱ�����
}
for k, _ in pairs(_WYAutoData) do
	RegisterCustomData("_WYAutoData." .. k)
end
_WYAutoCache = {
    loaded = false,
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
    Tms_WYAuto.Reload()
    
    -- println(PLAYER_TALK_CHANNEL.LOCAL_SYS, "[�ֲи���]���ݼ��سɹ�����ӭʹ���������ֲи�����")
    OutputMessage("MSG_SYS", "[�ֲи���]���ݼ��سɹ�����ӭʹ���������ֲи�����\n")
end
Tms_WYAuto.Reload = function()
    Tms_WYAuto.tBreatheAction["JW"]=nil
    Tms_WYAuto.tBreatheAction["QKJY"]=nil
    Tms_WYAuto.tBreatheAction["LockNearNpc"]=nil
    if not _WYAutoData.bAuto then return end
    if _WYAutoData.bAutoJW == true then Tms_WYAuto.tBreatheAction["JW"]=AutoJW end
    if _WYAutoData.bTargetLock then 
        if _WYAutoData.nTargetLockMode == 0 then 
            if _WYAutoData.bAutoQKJY == true then
                Tms_WYAuto.tBreatheAction["QKJY"] = AutoQKJY
            end
        elseif _WYAutoData.nTargetLockMode == 1 then 
            Tms_WYAuto.tBreatheAction["LockNearNpc"] = AutoSelectNearTarget
        elseif _WYAutoData.nTargetLockMode == 2 then 
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

--(void) print(optional nChannel, szText)     -- �����Ϣ
local function print(nChannel,szText)
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
--(void) print(optional nChannel,szText)     -- ���������Ϣ
local function println(nChannel,szText)
	if type(nChannel) == "string" then
        print(nChannel .. "\n")
    else
        print(nChannel, szText .. "\n")
	end
end

-----------------------------------------------
--
-----------------------------------------------
Tms_WYAuto.tBreatheAction = {}
Tms_WYAuto.OnFrameCreate =function() end
Tms_WYAuto.Breathe=function()
	if _WYAutoData.bAuto == false then
		return
	end
	for szKey, fnAction in pairs(Tms_WYAuto.tBreatheAction) do
        -- println(szKey)
		-- assert(fnAction)
		if type(fnAction) == "function" then fnAction() end
	end
end
Tms_WYAuto.OnFrameBreathe=Tms_WYAuto.Breathe
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
        -- println(dwSkillID,"  ",dwSkillLevel)
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
function AutoUnfocusJX()
    if _WYAutoData.bAuto and _WYAutoData.bUnfocusJX then -- ��ֹѡ�н��Ŀ��ش�
        local player = GetClientPlayer()
        local tar = GetTargetHandle(player.GetTarget())
        if(tar and tar.szName == "����") then
            player.StopCurrentAction()
            SetTarget(TARGET.PLAYER,player.dwID)
        end
    end
end
RegisterEvent("DO_SKILL_PREPARE_PROGRESS",AutoUnfocusJX) -- ���ܿ�ʼ���� -- arg0=����׼��֡�� -- arg1=����ID -- arg2=���ܵȼ�
RegisterEvent("DO_SKILL_CAST",AutoUnfocusJX) -- �����ͷ� -- arg0=����ID -- arg1=����ID -- arg2=���ܵȼ�
RegisterEvent("PLAYER_STATE_UPDATE",AutoUnfocusJX)
RegisterEvent("SYNC_ROLE_DATA_END",AutoUnfocusJX)

---------------------------------------------------
-- Ŀ������ �¼���
_WYAutoCache.J_NpcList = {}
_WYAutoCache.NearEnemyNpcList = {}
_WYAutoCache.LastTarget = {
    eTargetType = TARGET.NOT_TARGET,
    dwTargetID = 1,
}

RegisterEvent("NPC_ENTER_SCENE",function()
    local player = GetClientPlayer()
    -- local tar = GetTargetHandle(player.GetTarget())
    -- println(_WYAutoCache.LastTarget.eTargetType, _WYAutoCache.LastTarget.dwTargetID,tar.szName,"DEFAULT TAR")
    local tar = GetNpc(arg0)
    -- println("NPC_ENTER_SCENE".."\t"..tar.szName)
    if tar.szName=="Ǭ������" then
        -- println("NPC_ADDED",arg0,tar.szName)
        _WYAutoCache.J_NpcList[arg0] = tar
    end
    -- println("dwID"..player.dwID.." "..tar.szName.." "..arg0)
    -- if IsEnemy(player.dwID, tar.dwID) then println("Enemy") else println("Friend") end
    -- if tar.szName ~= "����" then println("~=����") else println("=����") end
    if IsEnemy(player.dwID, tar.dwID) and tar.szName ~= "����" and tar.szName ~= "ѵ��ľ׮" then _WYAutoCache.NearEnemyNpcList[arg0] = tar end
end)
RegisterEvent("NPC_LEAVE_SCENE",function()
    -- local tar = GetNpc(arg0)
    -- println("NPC_LEAVE_SCENE",tar.szName)
    _WYAutoCache.J_NpcList[arg0] = nil
    _WYAutoCache.NearEnemyNpcList[arg0] = nil
end)

---------------------------------------------------
-- (void)Ǭ�������Զ�ѡ��
function AutoQKJY()
    local player = GetClientPlayer()
    local tar = GetTargetHandle( player.GetTarget() )
    for tid,ttar in pairs(_WYAutoCache.J_NpcList) do
        if(tar and tar.nCurrentLife > 0 and tar.szName == ttar.szName) then
            return
        elseif ttar and ttar.nCurrentLife > 0 then
            if ( tar and tar.szName ) then
                _WYAutoCache.LastTarget.eTargetType, _WYAutoCache.LastTarget.dwTargetID = player.GetTarget()
            end
            SetTarget(TARGET.NPC,tid)
            -- println(tid,ttar.szName,"SELECTED")
            return
        end
    end
    if(not tar) then SetTarget(_WYAutoCache.LastTarget.eTargetType, _WYAutoCache.LastTarget.dwTargetID) end
end
---------------------------------------------------
-- (void)�Զ�ѡ��ָ����Χ�ڵж�NPC
function AutoSelectNearTarget()
    local player = GetClientPlayer()
    if _WYAutoData.bTargetLock and _WYAutoData.nTargetLockMode == 1 then 
        local dwNpcID = 0            -- ��¼ �������/�ȼ����/δ��ս��/�ѽ�ս��/�����ҵ�/Ѫ������/Ѫ���ٷֱ����� ��NPC��ID
        local nLowestNpcPropertiesValue = 9999 -- �ο�������Сֵ
        local dwNearestNpcID = 0
        local nNearestDistance = 9999
        for npcid,npc in pairs(_WYAutoCache.NearEnemyNpcList) do
            -- println(""..npcid.." "..npc.dwID)
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
                    if npc.bFightState and npc.GetTarget() and npc.GetTarget().dwID == player.dwID then return -2 else return -1 end
                end,
                [5] = function(player,npc)    -- ����˵�
                    if npc.bFightState and npc.GetTarget() and npc.GetTarget().dwID ~= player.dwID then return -2 else return -1 end
                end,
                [6] = function(player,npc)    -- Ѫ������
                    return npc.nCurrentLife
                end,
                [7] = function(player,npc)    -- Ѫ���ٷֱ�����
                    return npc.nCurrentLife*100/npc.nMaxLife
                end,
            }
            local f = switch[_WYAutoData.nTargetLockNearNpcSortMode]
            if(f) then
                local nNpcPropertiesValue = f(player,npc)
                local nDistance = GetCharacterDistance(player.dwID, npc.dwID)
                if (npc and nDistance/64 < _WYAutoData.nTargetLockNearNpcDistance and (npc.nCurrentLife > 0 and nNpcPropertiesValue < nLowestNpcPropertiesValue) ) then
                    nLowestNpcPropertiesValue = nNpcPropertiesValue
                    dwNpcID = npcid
                end
                if dwNearestNpcID == 0 or nDistance < nNearestDistance and nDistance/64 < _WYAutoData.nTargetLockNearNpcDistance then
                    nNearestDistance = nDistance
                    dwNearestNpcID = npcid
                end
            -- else                -- for case default
                -- print "Case default."
            end
        end
        -- ѡ�з���Ҫ������Ŀ�� û����ѡ�������Ŀ��
        if dwNpcID ~= 0 and nLowestNpcPropertiesValue ~= -1 then SetTarget(TARGET.NPC,dwNpcID) else SetTarget(TARGET.NPC,dwNearestNpcID) end
    end
end

---------------------------------------------------
-- (void)�����Զ�����
function AutoJW()
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
function Tms_WYAuto.GetMenuList()
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
                    println("[�������ֲ�ר��]�ֲ�ģʽ�ѿ���")
                else
                    println("[�������ֲ�ר��]�ֲ�ģʽ�ѹر�")
                end
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
                    println("[�������ֲ�ר��]���÷����ѿ���")
                else
                    println("[�������ֲ�ר��]���÷����ѹر�")
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
                println("[�������ֲ�ר��]Ŀ������/��ǿ�ѿ���")
            else
                println("[�������ֲ�ר��]Ŀ������/��ǿ�ѹر�")
            end
        end,
        fnAutoClose = function() return true end,
        {  -- �Զ�ת��
            szOption = "�Զ�ת�� ",
            szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=119;szLayer = "ICON_RIGHT",
            bMCheck = true,
            bCheck = true,
            bChecked = _WYAutoData.nTargetLockMode == 0,
            fnAction = function()
                _WYAutoData.nTargetLockMode = 0
                println("[�������ֲ�ר��]Ŀ������/��ǿ��ģʽ�л����Զ�ת��")
                if _WYAutoData.bAutoQKJY then println("[�������ֲ�ר��]Ŀ������/��ǿ����ǰģʽ���Զ�ת��Ǭ������") end
                Tms_WYAuto.Reload()
            end,
            fnAutoClose = function() return true end,
            {  -- �Զ�ѡ��Ǭ������
                szOption = "�Զ�ѡ��Ǭ������ ",
                szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=49;szLayer = "ICON_RIGHT",
                bCheck = true,
                bChecked = _WYAutoData.bAutoQKJY,
                fnAction = function()
                    _WYAutoData.bAutoQKJY = not _WYAutoData.bAutoQKJY
                    Tms_WYAuto.Reload()
                    if _WYAutoData.bAutoQKJY == true then
                        println("[�������ֲ�ר��]Ŀ������/��ǿ���Զ�ѡ��Ǭ�������ѿ���")
                    else
                        println("[�������ֲ�ר��]Ŀ������/��ǿ���Զ�ѡ��Ǭ�������ѹر�")
                    end
                end,
                fnMouseEnter = function()
                    Tms_WYAuto.MenuTip("���ֲ�ר��ר�θ����ֲл���\n�Զ�ѡ��Ǭ�����⣬����л�����/����״̬��")
                end,
                fnAutoClose = function() return true end
            },
            
        }, 
        {  -- ���������ж�NPC
            szOption = "���������ж�NPC ",
            szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=119;szLayer = "ICON_RIGHT",
            bMCheck = true,
            bCheck = true,
            bChecked = _WYAutoData.nTargetLockMode == 1,
            fnAction = function()
                _WYAutoData.nTargetLockMode = 1
                println("[�������ֲ�ר��]Ŀ������/��ǿ��ģʽ�л������������ж�NPC")
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
        }, 
        {  -- �Զ���Ŀ������
            szOption = "�Զ���Ŀ������ ",
            szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=119;szLayer = "ICON_RIGHT",
            bMCheck = true,
            bCheck = true,
            bChecked = _WYAutoData.nTargetLockMode == 2,
            fnAction = function()
                _WYAutoData.nTargetLockMode = 2
                println("[�������ֲ�ר��]Ŀ������/��ǿ��ģʽ�л����Զ���Ŀ������")
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
                    println("[�������ֲ�ר��]��ֹѡ�н����ѿ���")
                else
                    println("[�������ֲ�ר��]��ֹѡ�н����ѹر�")
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
                    println("[�������ֲ�ר��]�Զ������ѿ���")
                else
                    println("[�������ֲ�ר��]�Զ������ѹر�")
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
                    println("[�������ֲ�ר��]��Χ���ܸ����ѿ���")
                else
                    println("[�������ֲ�ר��]��Χ���ܸ����ѹر�")
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
                    println("[�������ֲ�ר��]ֻTab����ѿ���")
                else
                    println("[�������ֲ�ר��]ֻTab����ѹر�")
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
                for tid,tar in pairs(tTMS.NearPlayerList) do
                    if tar and tar.dwSchoolID == 2 then
                        local tSay = {
                            {type = "name", name = GetClientPlayer().szName},
                            {type = "text", text = "�����İι���"},
                            {type = "name", name = tar.szName},
                            {type = "text", text = "����ë��"},
                        }
                        GetClientPlayer().Talk( _WYAutoData.cEchoChanel or PLAYER_TALK_CHANNEL.NEARBY, "", tSay)
                        -- print(PLAYER_TALK_CHANNEL.NEARBY, "[" .. GetClientPlayer().szName .. "]�����İι���[" .. tar.szName .. "]����ë��")
                    end
                end
                local tSay = {
                    {type = "name", name = GetClientPlayer().szName},
                    {type = "text", text = "��ʰ��һ�±��������ë��ϣ�������������ü�Ǯ��"},
                }
                GetClientPlayer().Talk( _WYAutoData.cEchoChanel or PLAYER_TALK_CHANNEL.NEARBY, "", tSay)
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
println(PLAYER_TALK_CHANNEL.LOCAL_SYS, "[�ֲи���]��������С���")

---------------------------------------------------
--��һ�������÷���lua�ļ���ĩβ��Ҳ�����㶨��ĺ����ĺ���
Wnd.OpenWindow("Interface/Tms_WYAuto/Tms_WYAuto.ini","Tms_WYAuto")
--��һ�������Ǵ����ļ�·�����ڶ��������Ǵ�������Ҳ����WYAuto.ini�ĵ�һ���Ǹ����֡�
---------------------------------------------------