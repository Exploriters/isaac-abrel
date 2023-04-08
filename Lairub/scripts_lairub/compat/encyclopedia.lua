if Encyclopedia then
	local Enums = require("scripts_lairub/misc/enums")
	
	local Wiki = {
		LAIRUB = {
			{	--Start Data
				{str = "Start Data", fsize = 2, clr = 3, halign = 0},
				{str = "WARNING: CAN ONLY HAVE EMPTY BONEHEART", clr = 3, halign = 0},
				{str = "HP: 3 Empty BoneHearts + 1 BlackHeart"},
				{str = "Speed: 0.7 (0.5)"},
				{str = "Tears: 2.31 (1.43)"},
				{str = "Damage: 3.82 (5.00)"},
				{str = "Range: 6.50"},
				{str = "Shotspeed: 1.50"},
				{str = "Luck: -1"}
			},
			{	--Traits
				{str = "Traits", fsize = 2, clr = 3, halign = 0},
				{str = "Lairub has many different skills. You can press and hold [H] to view their information more intuitively."},
				{str = "When Lairub comes to stage13 (Home), the scope limit of her skill ReleaseSoul will be lifted, so as to better achieve the attack purpose."},
				{str = "Lairub comes from hell. When you try to enter Sheol and DarkRoom, she will be hunted down by her boss. If you can't clean the room within one minute, she will be irresistibly hurt until she dies."},
				{str = "Lairub is a demon, so it is difficult for her to enter the angel room."}
			},
			{ --Birthright
				{str = "Birthright", fsize = 2, clr = 3, halign = 0},
				{str = "WARNING: IN PROGRESS", clr = 3, halign = 0}
			},
			{ --Trivia
				{str = "Trivia", fsize = 2, clr = 3, halign = 0},
				{str = "Lairub is a female demon from hell. She looks like a white four-cornered goat, but more often, she maintains a human appearance-human body and face, but still has sheep ears and two pairs of huge horns, abnormal white skin. She is wearing a white cloak, a suit and high-heeled boots."},
				{str = "Lairub is a hired killer who works for money, but she is not happy in hell. She is not a high-level demon. She is sent to various places to do all kinds of annoying chores outside her job. And her real job is to harvest souls and send them to hell."},
				{str = "Lairub was a white goat who was sent to the altar before her death."},
				{str = "She is an out-and-out gambler, even if she spends all her savings. For her, even if she loses completely, she is happy, which is worthwhile."},
				{str = "Lairub has a bad temper. She is mean, arrogant, and likes to sneer at people and curse everything that doesn't suit her."}
			}
		},
		SOUL_OF_LAIRUB = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "WARNING: ADJUSTING", clr = 3, halign = 0},
				{str = "The instant of use causes a lot of damage to all monsters in the whole room, and the ReleaseSoul effect is automatically enabled for 1 min."}
			}
		}
	}
	Encyclopedia.AddCharacter({
		ModName = "LairubMod",
		Name = "Lairub",
		WikiDesc = Wiki.LAIRUB,
		ID = Enums.Characters.LAIRUB,
		--Sprite = Encyclopedia.RegisterSprite("../content/gfx/characterportraits.anm2", "Lairub", 0),
	})
	Encyclopedia.AddSoul({
		Class = "Lairub",
		ModName = "LairubMod",
		ID = Enums.Cards.SOUL_OF_LAIRUB,
		WikiDesc = Wiki.SOUL_OF_LAIRUB,
		--Spr = Encyclopedia.RegisterSprite("../content/gfx/ui_cardfronts.anm2", "Soul of Lairub", 0)
	})
end