CreateClientConVar("hearingability", "H", true, false)
CreateClientConVar("hearingability_distance", "500", true, false)
CreateClientConVar("hearingability_cooldown", "1", true, false)

print("Ignore this first error, it ain't serious. I can't be bothered to fix this shit I'm done")

local alpha = 0
local time = CurTime()
local target = {}

hook.Add("Think", "fuckYouGarry", function()

    keyBind = GetConVar("hearingability"):GetString()
    maxTargetDist = GetConVar("hearingability_distance"):GetInt()
    abilityCooldown = GetConVar("hearingability_cooldown"):GetInt()

end)

hook.Add( "PreDrawHalos", "addingGlow", function()

    for _, ent in ipairs(ents.FindByClass('npc_*')) do
        local dist = LocalPlayer():EyePos():DistToSqr(ent:GetPos() + ent:OBBCenter())
        if dist > maxTargetDist ^2 then 
            if target[ent] then 
                target[ent] = nil 
            end
        else
            local alphaIndi = 1 - dist / maxTargetDist ^2
            target[ent] = Color(255, 255, 255, alphaIndi * 70)
        end
    end
    for _, ply in ipairs(player.GetAll()) do
        local dist = LocalPlayer():EyePos():DistToSqr(ply:GetPos() + ply:OBBCenter())
        if dist > maxTargetDist ^2 then 
            if target[ply] then 
                target[ply] = nil 
            end
        else
            local alphaIndi = 1 - dist / maxTargetDist ^2
            target[ply] = Color(255, 255, 255, alphaIndi * 70)
        end
    end

    if input.IsKeyDown( input.GetKeyCode(keyBind) ) && CurTime() - time > abilityCooldown then
        alpha = math.Approach( alpha, 1, FrameTime() / 1.20 )
        local color = Color( 255, 255, 255, 70 * alpha )

        surface.SetDrawColor(0, 0 ,0, 200 * alpha)
        surface.DrawRect(-200, -200, ScrW(), ScrH())

        for ent, col in pairs(target) do
            if not IsValid(ent) or col == nil then continue end
            halo.Add({ent}, col, 6, 4, 1, true, true)
        end

        hook.Add("EntityEmitSound", "mufflingSounds", function( tab )
            tab.Volume = tab.Volume * 0.3
            tab.Pitch = tab.Pitch * 0.95
            tab.SoundLevel = tab.SoundLevel * 0.8

            return true
        end)
    end
end )
hook.Add( "PlayerButtonUp", "shittingMyPants", function( _, button )
    if button == input.GetKeyCode(keyBind) && CurTime() - time > abilityCooldown then
        time = CurTime()
        alpha = 0
    end
    hook.Remove("EntityEmitSound", "mufflingSounds")
end)
