
LairubOverlayDatas = {}
function LairubOverlayDatas.ChangedToTakeSoul()
    local sprite = Sprite()
    sprite:Load("gfx/LairubAnm_ChangedToTakeSoul.anm2", true)
    sprite:Play("ChangedToTakeSoul", true)
    return sprite, Vector(0, 1)
end
function LairubOverlayDatas.ChangedToNormal()
    local sprite = Sprite()
    sprite:Load("gfx/LairubAnm_ChangedToNormal.anm2", true)
    sprite:Play("ChangedToNormal", true)
    return sprite, Vector(0, 1)
end
function LairubOverlayDatas.ReleaseSoul()
    local sprite = Sprite()
    sprite:Load("gfx/LairubAnm_ReleaseSoul.anm2", true)
    sprite:Play("ReleaseSoul", true)
    return sprite, Vector(0, 1)
end
function LairubOverlayDatas.ReadySpawnCross()
    local sprite = Sprite()
    sprite:Load("gfx/LairubAnm_ReadySpawnCross.anm2", true)
    sprite:Play("ReadySpawnCross", true)
    return sprite, Vector(0, 1)
end
function LairubOverlayDatas.TeleportToDevilRoom()
    local sprite = Sprite()
    sprite:Load("gfx/LairubAnm_TeleportToDevilRoom.anm2", true)
    sprite:Play("TeleportToDevilRoom", true)
    return sprite, Vector(0, -1)
end
function LairubOverlayDatas.TalkNormal()
    local sprite = Sprite()
    sprite:Load("gfx/LairubAnm_Talk_Normal.anm2", true)
    sprite:Play("TalkNormal", true)
    return sprite, Vector(0, 1)
end
function LairubOverlayDatas.TalkHappy()
    local sprite = Sprite()
    sprite:Load("gfx/LairubAnm_Talk_Happy.anm2", true)
    sprite:Play("TalkHappy", true)
    return sprite, Vector(0, 1)
end
function LairubOverlayDatas.TalkFear()
    local sprite = Sprite()
    sprite:Load("gfx/LairubAnm_Talk_Fear.anm2", true)
    sprite:Play("TalkFear", true)
    return sprite, Vector(0, 0)
end
function LairubOverlayDatas.TalkSigh()
    local sprite = Sprite()
    sprite:Load("gfx/LairubAnm_Talk_Sigh.anm2", true)
    sprite:Play("TalkSigh", true)
    return sprite, Vector(0, 0)
end

LairubDialogueDatas = {}
LairubDialogueDatas.InHome = {}
LairubDialogueDatas.InHome.flag = "DIALOGUE_OVER_INHOME"
LairubDialogueDatas.InHome.shouldFire = function ()
	return Game():GetLevel():GetStage() == 13
end
LairubDialogueDatas.InHome.steps = {}
LairubDialogueDatas.InHome.steps[1] = {}
LairubDialogueDatas.InHome.steps[1].emote = "Normal"
LairubDialogueDatas.InHome.steps[1].text = {"inhome_dialogue_1_1"}
LairubDialogueDatas.InHome.steps[2] = {}
LairubDialogueDatas.InHome.steps[2].emote = "Normal"
LairubDialogueDatas.InHome.steps[2].text = {"inhome_dialogue_2_1", "inhome_dialogue_2_2"}
LairubDialogueDatas.InHome.steps[3] = {}
LairubDialogueDatas.InHome.steps[3].emote = "Normal"
LairubDialogueDatas.InHome.steps[3].text = {"inhome_dialogue_3_1", "inhome_dialogue_3_2"}
LairubDialogueDatas.InHome.steps[4] = {}
LairubDialogueDatas.InHome.steps[4].emote = "Happy"
LairubDialogueDatas.InHome.steps[4].text = {"inhome_dialogue_4_1"}
LairubDialogueDatas.InHome.steps[5] = {}
LairubDialogueDatas.InHome.steps[5].emote = "Normal"
LairubDialogueDatas.InHome.steps[5].text = {"inhome_dialogue_5_1"}

LairubDialogueDatas.HuntDown = {}
LairubDialogueDatas.HuntDown.flag = "DIALOGUE_OVER_HUNTDOWN"
LairubDialogueDatas.HuntDown.shouldFire = function ()
	return LairubFlags:HasFlag("FIRE_HUNTDOWN_DIALOGUE")
end
LairubDialogueDatas.HuntDown.steps = {}
LairubDialogueDatas.HuntDown.steps[1] = {}
LairubDialogueDatas.HuntDown.steps[1].emote = "Fear"
LairubDialogueDatas.HuntDown.steps[1].text = {"huntdown_dialogue_1_1"}
LairubDialogueDatas.HuntDown.steps[2] = {}
LairubDialogueDatas.HuntDown.steps[2].emote = "Fear"
LairubDialogueDatas.HuntDown.steps[2].text = {"huntdown_dialogue_2_1"}
LairubDialogueDatas.HuntDown.steps[3] = {}
LairubDialogueDatas.HuntDown.steps[3].emote = "Fear"
LairubDialogueDatas.HuntDown.steps[3].text = {"huntdown_dialogue_3_1"}
LairubDialogueDatas.HuntDown.steps[4] = {}
LairubDialogueDatas.HuntDown.steps[4].emote = "Sigh"
LairubDialogueDatas.HuntDown.steps[4].text = {"huntdown_dialogue_4_1"}
LairubDialogueDatas.HuntDown.steps[5] = {}
LairubDialogueDatas.HuntDown.steps[5].emote = "Sigh"
LairubDialogueDatas.HuntDown.steps[5].text = {"huntdown_dialogue_5_1"}
