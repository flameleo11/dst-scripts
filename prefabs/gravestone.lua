local assets =
{
    Asset("ANIM", "anim/gravestones.zip"),
    Asset("MINIMAP_IMAGE", "gravestones"),
}

local prefabs =
{
    "smallghost",
    "mound",
    "ghost",
}

local function on_child_mound_dug(mound, data)
end

local function onload(inst, data, newents)
    if data then
        if inst.mound and data.mounddata then
            if newents and data.mounddata.id then
                newents[data.mounddata.id] = {entity=inst.mound, data=data.mounddata} 
            end
            inst.mound:SetPersistData(data.mounddata.data, newents)
        end

        if data.setepitaph then
            --this handles custom epitaphs set in the tile editor
            inst.components.inspectable:SetDescription("'"..data.setepitaph.."'")
            inst.setepitaph = data.setepitaph
        end
    end
end

local function onsave(inst, data)
    if inst.mound then
        data.mounddata = inst.mound:GetSaveRecord()
    end
    data.setepitaph = inst.setepitaph

    local ents = {}
    if inst.ghost ~= nil then
        data.ghost_id = inst.ghost.GUID
        table.insert(ents, data.ghost_id)
    end

    return ents
end

-- Ghosts on a quest (following someone) shouldn't block other ghost spawns!
local CANTHAVE_GHOST_TAGS = {"questing"}
local MUSTHAVE_GHOST_TAGS = {"ghostkid"}
local function on_day_change(inst)
    if inst.ghost == nil or not inst.ghost:IsValid() and #AllPlayers > 0 then
        local ghost_spawn_chance = 0
        for _, v in ipairs(AllPlayers) do
            if v:HasTag("ghostlyfriend") then
                ghost_spawn_chance = ghost_spawn_chance + TUNING.GHOST_GRAVESTONE_CHANCE
            end
        end
        ghost_spawn_chance = math.max(ghost_spawn_chance, TUNING.GHOST_GRAVESTONE_CHANCE)

        if math.random() < ghost_spawn_chance then
            local gx, gy, gz = inst.Transform:GetWorldPosition()
            local nearby_ghosts = TheSim:FindEntities(gx, gy, gz, TUNING.UNIQUE_SMALLGHOST_DISTANCE, MUSTHAVE_GHOST_TAGS, CANTHAVE_GHOST_TAGS)
            if #nearby_ghosts == 0 then
                inst.ghost = SpawnPrefab("smallghost")
                inst.ghost.Transform:SetPosition(gx + 0.3, gy, gz + 0.3)
                inst.ghost:LinkToHome(inst)
            end
        end
    end
end

local function onloadpostpass(inst, newents, savedata)
    inst.ghost = nil
    if savedata ~= nil then
        if savedata.ghost_id ~= nil and newents[savedata.ghost_id] ~= nil then
            inst.ghost = newents[savedata.ghost_id].entity
			inst.ghost:LinkToHome(inst)
        end
    end
end

local function OnHaunt(inst)
    if inst.setepitaph == nil and #STRINGS.EPITAPHS > 1 then
        --change epitaph (if not a set custom epitaph)
        --guarantee it's not the same as b4!
        local oldepitaph = inst.components.inspectable.description
        local newepitaph = STRINGS.EPITAPHS[math.random(#STRINGS.EPITAPHS - 1)]
        if newepitaph == oldepitaph then
            newepitaph = STRINGS.EPITAPHS[#STRINGS.EPITAPHS]
        end
        inst.components.inspectable:SetDescription(newepitaph)
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_SMALL
    else
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_TINY
    end
    return true
end

local function costSanity(inst, delta)
    if inst and inst.components
      and inst.components.sanity 
    then
      inst.components.sanity:DoDelta(0-delta)
    end
end


local function OnWorkFinished(inst, worker)
  xpcall(function ()      
print(2222, inst, worker)    
    inst.components.lootdropper:DropLoot()
    local x, y, z = inst.Transform:GetWorldPosition()
    SpawnPrefab("rocks").Transform:SetPosition(x, y, z)

    local ghost = SpawnAt("ghost", inst)
    if (worker:HasTag("hostile") 
        and worker and worker.components 
        and worker.components.combat
        and worker.components.combat.target) then
        local target = worker.components.combat.target
        costSanity(target, TUNING.SANITY_SMALL)    
        ghost.components.combat:SetTarget(target)
    else
        costSanity(worker, TUNING.SANITY_SMALL)    
    end    

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(x, y, z)
    fx:SetMaterial("stone")

    inst:Remove()
  end, print)            
end
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .25)

    inst.MiniMapEntity:SetIcon("gravestones.png")

    inst:AddTag("grave")

    inst.AnimState:SetBank("gravestone")
    inst.AnimState:SetBuild("gravestones")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.AnimState:PlayAnimation("grave"..tostring(math.random(4)))

    inst:AddComponent("inspectable")
    inst.components.inspectable:SetDescription(STRINGS.EPITAPHS[math.random(#STRINGS.EPITAPHS)])

xpcall(function ()    
    inst:AddComponent("workable")
    inst:AddComponent("lootdropper")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    -- inst.components.workable:SetOnWorkCallback(onhit)
    inst.components.workable:SetOnFinishCallback(OnWorkFinished)
end, print)   

    inst.mound = inst:SpawnChild("mound")
    inst.mound.ghost_of_a_chance = 0.0
    inst:ListenForEvent("worked", on_child_mound_dug, inst.mound)
    inst.mound.Transform:SetPosition((TheCamera:GetDownVec()*.5):Get())

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetOnHauntFn(OnHaunt)

    inst:WatchWorldState("cycles", on_day_change)

    inst.OnLoad = onload
    inst.OnSave = onsave
    inst.OnLoadPostPass = onloadpostpass

    return inst
end

return Prefab("gravestone", fn, assets, prefabs)
