local ExploriteMod = Explorite.ExploriteMod

local SCREEN_SCALE = Vector(480.0, 270.0)

local HUDoffset = 10

local completionMarksStruct = {
    heart = 0,      -- Mom's heart or It lives
    cross = 0,      -- Isaac
    cross_down = 0, -- Satan
    star = 0,       -- Boss rush
    polaroid = 0,   -- ???
    negative = 0,   -- The Lamb
    brimstone = 0,  -- Mega Satan
    greed = 0,      -- Greed
    hush = 0,       -- Hush
    knife = 0,      -- Mother
    dads_note = 0,  -- The Beast
    delirium = 0,   -- Delirium
    tainted = false
    }

completionMarksStruct.__index = completionMarksStruct
function Explorite.CompletionMarksStruct()
	return completionMarksStruct:ctor()
end
function completionMarksStruct:ctor()
	local cted = {}
	setmetatable(cted, completionMarksStruct)
	return cted
end

-- 渲染完成度标记
local function DrawCompletionWidget(pos, sortNum, marks)
	pos = pos + Vector(-sortNum*35/2, 0)
	
	local paper = Sprite()
	
	paper:Load("gfx/ui/completion_widget.anm2", false)
    paper:ReplaceSpritesheet(0,"gfx/ui/completion_widget_pause.png")
    paper:ReplaceSpritesheet(1,"gfx/ui/completion_widget_pause.png")
    paper:ReplaceSpritesheet(2,"gfx/ui/completion_widget_pause.png")
    paper:ReplaceSpritesheet(3,"gfx/ui/completion_widget_pause.png")
    paper:ReplaceSpritesheet(4,"gfx/ui/completion_widget_pause.png")
    paper:ReplaceSpritesheet(5,"gfx/ui/completion_widget_pause.png")
    paper:ReplaceSpritesheet(6,"gfx/ui/completion_widget_pause.png")
    paper:ReplaceSpritesheet(7,"gfx/ui/completion_widget_pause.png")
    paper:ReplaceSpritesheet(8,"gfx/ui/completion_widget_pause.png")
    paper:ReplaceSpritesheet(9,"gfx/ui/completion_widget_pause.png")
    paper:ReplaceSpritesheet(10,"gfx/ui/completion_widget_pause.png")
    paper:ReplaceSpritesheet(11,"gfx/ui/completion_widget_pause.png")
    paper:ReplaceSpritesheet(12,"gfx/ui/completion_widget_pause.png")
    paper:LoadGraphics()
    paper:SetFrame("Idle", 0)

	local paperframe = marks.delirium
    if marks.tainted then
        paperframe = paperframe + 3
    end
    paper:SetLayerFrame( 0, paperframe)  -- Paper, Delirium and Tainted
	paper:SetLayerFrame( 1, marks.heart)  -- Heart, Mom's heart or It lives
	paper:SetLayerFrame( 2, marks.cross)  -- Cross, Isaac
	paper:SetLayerFrame( 3, marks.cross_down)  -- UpSideDownCross, Satan
	paper:SetLayerFrame( 4, marks.star)  -- Star, Boss rush
	paper:SetLayerFrame( 5, marks.polaroid)  -- Polaroid, ???
	paper:SetLayerFrame( 6, marks.negative)  -- Negative, The Lamb
	paper:SetLayerFrame( 7, marks.brimstone)  -- MegaSatan (Brimstone)
	paper:SetLayerFrame( 8, marks.greed)  -- Greed
	paper:SetLayerFrame( 9, marks.hush)  -- Hush
	paper:SetLayerFrame(10, marks.knife)  -- Knife, Mother
	paper:SetLayerFrame(11, marks.dads_note)  -- DadsNote
	
	paper:Render(pos, Vector(0,0), Vector(0,0))

    local EternalChargeSprite = Sprite()
    EternalChargeSprite:Load("gfx/ui/EternalChargeX.anm2", true)
    EternalChargeSprite:SetFrame("Base", 0)
    EternalChargeSprite:Render(pos, Vector(0,0), Vector(0,0))
end

-- 渲染器，每一帧执行
function ExploriteMod:CompletionMarksUtility_PostRender()
	local baseOffset = SCREEN_SCALE - Vector(80, 88)
	local hudOffset = Vector(2 * HUDoffset, 1.2 * HUDoffset)
    --DrawCompletionWidget(baseOffset - hudOffset, 0)
end
ExploriteMod:AddCallback(ModCallbacks.MC_POST_RENDER, ExploriteMod.CompletionMarksUtility_PostRender)

local Database = Explorite.ExploriteMod