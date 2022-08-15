DesperabbitOverlayDatas = {}

function DesperabbitOverlayDatas.DeathAnimation()
    local sprite = Sprite()
    sprite:Load("gfx/characters/animations/animation_Death_desperabbit.anm2", true)
    sprite:Play("DeathAnimation", true)
    return sprite, Vector(0, 1)
end