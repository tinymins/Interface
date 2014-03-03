Tms_WYAuto = Tms_WYAuto or {}
-----------------------------------------------
-- ���غ����ͱ���
-----------------------------------------------
local _WYAuto = {
	dwVersion = 0x0010000,
	szBuildDate = "20131221",
}
-----------------------------------------------
-- ����
-----------------------------------------------
_WYAutoData = {
    bAuto = true,
    bAutoFY = false,
    bAutoCY = false,
    bAutoJW = true,
    bAutoArea = false,
    bTabPvp = false,
    bAutoQKJY = false,
    bUnfocusJX = true,
    bEchoMsg = true,
    cEchoChanel = PLAYER_TALK_CHANNEL.LOCAL_SYS,
}
for k, _ in pairs(_WYAutoData) do
	RegisterCustomData("_WYAutoData." .. k)
end
local _WYAutoCache = {
    loaded = false,
}
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
	elseif nChannel == PLAYER_TALK_CHANNEL.LOCAL_SYS then
		OutputMessage("MSG_SYS", szText)
	else
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
		assert(fnAction)
		fnAction()
	end
end
Tms_WYAuto.OnFrameBreathe=Tms_WYAuto.Breathe
----------------------------------------------------
local _SelectPoint = UserSelect.SelectPoint ---HOOK����ѡ�к��� ��ΪĬ��ֱ��ѡ��----
function UserSelect.SelectPoint(fnAction, fnCancel, fnCondition, box) --��ȡ�ͷŵ� ����
	_SelectPoint(fnAction, fnCancel, fnCondition, box) --��ʾ����ѡ��
	if  _WYAutoData.bAutoArea then
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
        OnAddOnUseSkill(dwSkillID, 1)
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
-- (void)��ҡ�Զ���
function AutoFY()
	if stand() and not buff(208) then
		InvalidCast(9002)
	end
end
---------------------------------------------------
-- (void)Ǭ�������Զ�ѡ��
_WYAutoCache.J_NpcList = {}
_WYAutoCache.LastTarget = {
    eTargetType = TARGET.NOT_TARGET,
    dwTargetID = 1,
}

RegisterEvent("NPC_ENTER_SCENE",function()
    local player = GetClientPlayer()
    local tar = GetTargetHandle(player.GetTarget())
    if(tar and tar.szName and tar.szName ~= "Ǭ������") then
        _WYAutoCache.LastTarget.eTargetType, _WYAutoCache.LastTarget.dwTargetID = player.GetTarget()
    end
    -- println(_WYAutoCache.LastTarget.eTargetType, _WYAutoCache.LastTarget.dwTargetID,tar.szName,"DEFAULT TAR")
    local tar = GetNpc(arg0)
    -- println("NPC_ENTER_SCENE",tar.szName)
    if tar.szName=="Ǭ������" then
        -- println("NPC_ADDED",arg0,tar.szName)
        _WYAutoCache.J_NpcList[arg0] = tar
    end
end)
RegisterEvent("NPC_LEAVE_SCENE",function()
    -- local tar = GetNpc(arg0)
    -- println("NPC_LEAVE_SCENE",tar.szName)
    _WYAutoCache.J_NpcList[arg0] = nil
end)
function AutoQKJY()
    local player = GetClientPlayer()
    local tar = GetTargetHandle(player.GetTarget())
    for tid,ttar in pairs(_WYAutoCache.J_NpcList) do
        if(tar and tar.nCurrentLife > 0 and tar.szName == ttar.szName) then
            return
        elseif ttar and ttar.nCurrentLife > 0 then
            SetTarget(TARGET.NPC,tid)
            -- println(tid,ttar.szName,"SELECTED")
            return
        end
    end
    if(not tar) then SetTarget(_WYAutoCache.LastTarget.eTargetType, _WYAutoCache.LastTarget.dwTargetID) end
end
---------------------------------------------------
-- (void)��ֹѡ�н���
function AutoUnfocusJX()
    if _WYAutoData.bUnfocusJX then -- ��ֹѡ�н��Ŀ��ش�
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
-- (void)�����Զ�����
function AutoJW()
    -- ��ȡ��ǰ���װ�����ڹ�ID
	local Kungfu = UI_GetPlayerMountKungfuID() --GetClientPlayer().GetKungfuMount().dwSkillID
	if Kungfu and Kungfu ~= 10080 and Kungfu ~= 10081 then
		return
	end
	if stand() and not buff(409) then
		InvalidCast(537)
	end
end
---------------------------------------------------
-- (void)�����Զ�������
function AutoCY()
    -- ��ȡ��ǰ���װ�����ڹ�ID
	local Kungfu = UI_GetPlayerMountKungfuID() --GetClientPlayer().GetKungfuMount().dwSkillID
	if Kungfu and Kungfu ~= 10015 and Kungfu ~= 10014 then
		return
	end
	if not buff(2781)  and (not buff(1376) or not buff(2983) ) then  --2781
		InvalidCast(312)
	end
	local player=GetClientPlayer()
	local n=player.nCurrentMana/player.nMaxMana
	local q=GetClientPlayer().nAccumulateValue
	if n<=0.7 and q==10 and not buff(2781) then
		InvalidCast(316)
	end
end
---------------------------------------------------
--skName    skID	buffID
--��������  312		1376 2983
--��Ԫ��ȱ  316
--��ҡֱ��  9002	208
----------------------------------------------------

----------------------------------------------------
-- ���ݳ�ʼ��
Tms_WYAuto.Load = function()
    if(_WYAutoCache.loaded) then return end
    _WYAutoCache.loaded = true
    
    local tMenu = {
        function()
            return {Tms_WYAuto.GetMenuList()}
        end,
    }
    Player_AppendAddonMenu(tMenu)
    
    if _WYAutoData.bAutoFY == true then
        Tms_WYAuto.tBreatheAction["FY"]=AutoFY
    else
        Tms_WYAuto.tBreatheAction["FY"]=nil
    end
    if _WYAutoData.bAutoJW == true then
        Tms_WYAuto.tBreatheAction["JW"]=AutoJW
    else
        Tms_WYAuto.tBreatheAction["JW"]=nil
    end
    if _WYAutoData.bAutoCY == true then
        Tms_WYAuto.tBreatheAction["CY"]=AutoCY
    else
        Tms_WYAuto.tBreatheAction["CY"]=nil
    end
    if _WYAutoData.bAutoQKJY == true then
        Tms_WYAuto.tBreatheAction["QKJY"]=AutoQKJY
    else
        Tms_WYAuto.tBreatheAction["QKJY"]=nil
    end
    
    println(PLAYER_TALK_CHANNEL.LOCAL_SYS, "[�ֲи���]���ݼ��سɹ�����ӭʹ���������ֲи�����")
end
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
				BuffCheck.MenuTip("���ֲ�ר��ר�θ����ֲл���\n�ܿ��أ�����л�״̬��")
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
				-- BuffCheck.MenuTip("���ֲ�ר��ר�θ����ֲл���\n�ܿ��أ�����л�״̬��")
			-- end,
			fnAutoClose = function() return true end,
		}
	local menu_b_1 = {  -- �Զ�����ҡ
			szOption = "�Զ�����ҡ ",
			szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=49;szLayer = "ICON_RIGHT",
			bCheck = true,
			bChecked = _WYAutoData.bAutoFY,
			fnAction = function()
                _WYAutoData.bAutoFY = not _WYAutoData.bAutoFY
                if _WYAutoData.bAutoFY == true then
                    Tms_WYAuto.tBreatheAction["FY"]=AutoFY
                    println("[�������ֲ�ר��]�Զ�����ҡ�ѿ���")
                else
                    Tms_WYAuto.tBreatheAction["FY"]=nil
                    println("[�������ֲ�ר��]�Զ�����ҡ�ѹر�")
                end
			end,
			fnMouseEnter = function()
				Tms_WYAuto.MenuTip("���ֲ�ר��ר�θ����ֲл���\n��ҡ���˾Ͳ�������л�����/����״̬��")
			end,
			fnAutoClose = function() return true end
		}
	local menu_b_2 = {  -- �Զ�����
			szOption = "�Զ����� ",
			szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=49;szLayer = "ICON_RIGHT",
			bCheck = true,
			bChecked = _WYAutoData.bAutoJW,
			fnAction = function()
                _WYAutoData.bAutoJW = not _WYAutoData.bAutoJW
                if _WYAutoData.bAutoJW == true then
                    Tms_WYAuto.tBreatheAction["JW"]=AutoJW
                    println("[�������ֲ�ר��]�Զ������ѿ���")
                else
                    Tms_WYAuto.tBreatheAction["JW"]=nil
                    println("[�������ֲ�ר��]�Զ������ѹر�")
                end
			end,
			fnMouseEnter = function()
				Tms_WYAuto.MenuTip("���ֲ�ר��ר�θ����ֲл���\n�Զ����裬����л�����/����״̬��")
			end,
			fnAutoClose = function() return true end
		}
	local menu_b_3 = {  -- �Զ�����������
			szOption = "�Զ����������� ",
			szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=49;szLayer = "ICON_RIGHT",
			bCheck = true,
			bChecked = _WYAutoData.bAutoCY,
			fnAction = function()
                _WYAutoData.bAutoCY = not _WYAutoData.bAutoCY
                if _WYAutoData.bAutoCY == true then
                    Tms_WYAuto.tBreatheAction["CY"]=AutoCY
                    println("[�������ֲ�ר��]�����Զ��������ѿ���")
                else
                    Tms_WYAuto.tBreatheAction["CY"]=nil
                    println("[�������ֲ�ר��]�����Զ��������ѹر�")
                end
			end,
			fnMouseEnter = function()
				Tms_WYAuto.MenuTip("���ֲ�ר��ר�θ����ֲл���\n�����������¹ʱ�Ԫ�Զ���������л�����/����״̬��")
			end,
			fnAutoClose = function() return true end
		}
	local menu_b_4 = {  -- �Զ�ѡ��Ǭ������
			szOption = "�Զ�ѡ��Ǭ������ ",
			szIcon = "ui/Image/UICommon/Talk_Face.UITex";nFrame=49;szLayer = "ICON_RIGHT",
			bCheck = true,
			bChecked = _WYAutoData.bAutoQKJY,
			fnAction = function()
                _WYAutoData.bAutoQKJY = not _WYAutoData.bAutoQKJY
                if _WYAutoData.bAutoQKJY == true then
                    Tms_WYAuto.tBreatheAction["QKJY"]=AutoQKJY
                    println("[�������ֲ�ר��]�Զ�ѡ��Ǭ�������ѿ���")
                else
                    Tms_WYAuto.tBreatheAction["QKJY"]=nil
                    println("[�������ֲ�ר��]�Զ�ѡ��Ǭ�������ѹر�")
                end
			end,
			fnMouseEnter = function()
				Tms_WYAuto.MenuTip("���ֲ�ר��ר�θ����ֲл���\n�Զ�ѡ��Ǭ�����⣬����л�����/����״̬��")
			end,
			fnAutoClose = function() return true end
		}
	local menu_b_5 = {  -- ��ֹѡ�н���
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
		}
	local menu_b_6 = {  -- ��Χ���ܸ���
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
	local menu_b_7 = {  -- ֻTab���
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
	-- table.insert(menu, menu_b_1)
	table.insert(menu, menu_b_2)
	-- table.insert(menu, menu_b_3)
	table.insert(menu, menu_b_4)
	table.insert(menu, menu_b_5)
	table.insert(menu, menu_b_6)
	table.insert(menu, menu_b_7)
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
RegisterEvent("CUSTOM_DATA_LOADED", Tms_WYAuto.Load)
-- RegisterEvent("BUFF_UPDATE", Tms_WYAuto.Breathe)
println(PLAYER_TALK_CHANNEL.LOCAL_SYS, "[�ֲи���]��������С���")

---------------------------------------------------
--��һ�������÷���lua�ļ���ĩβ��Ҳ�����㶨��ĺ����ĺ���
Wnd.OpenWindow("Interface/Tms_WYAuto/Tms_WYAuto.ini","Tms_WYAuto")
--��һ�������Ǵ����ļ�·�����ڶ��������Ǵ�������Ҳ����WYAuto.ini�ĵ�һ���Ǹ����֡�
---------------------------------------------------