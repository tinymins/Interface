MY = MY or {}
-----------------------------------------------
-- ���غ����ͱ���
-----------------------------------------------
local _MY = {
    szTitle = "�������",
    dwVersion = 0x0020000,
    szBuildDate = "20140227",
    szIniFile  = "Interface/MY/MY.ini",
}
-----------------------------------------------
-- �����ʼ��
-----------------------------------------------

-----------------------------------------------
-- ͨ�ú���
-----------------------------------------------
-- (number) MY.FrameToSecondLeft(nEndFrame)     -- ��ȡnEndFrameʣ������
MY.FrameToSecondLeft = function(nEndFrame)
	local nLeftFrame = nEndFrame - GetLogicFrameCount()
	return nLeftFrame / 16
end
