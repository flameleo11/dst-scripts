local function makeassetlist(name)
    return {
        Asset("ANIM", "anim/"..name..".zip")
    }
end

local function costSanity(inst, delta)
    if inst and inst.components
      and inst.components.sanity 
    then
      inst.components.sanity:DoDelta(0-delta)
    end
end


local function onhit(inst, worker)
  -- inst.AnimState:PlayAnimation("hit")
  -- inst.AnimState:PushAnimation("idle")
end

local shadow_chess = {
  "shadow_rook",
  "shadow_knight",
  "shadow_bishop",
}

local function OnWorkFinished(inst, worker)
xpcall(function ()
print(222, inst, worker)
  local pt = inst:GetPosition()
  SpawnPrefab("rock_break_fx").Transform:SetPosition(pt:Get())
  inst.components.lootdropper:DropLoot(pt)    

  local x, y, z = inst.Transform:GetWorldPosition()
  if ( worker:HasTag("hostile") 
    and worker and worker.components 
    and worker.components.combat
    and worker.components.combat.target ) 
  then
    local i = math.random(1, 10)
    local nightmare = shadow_chess[i%3]
    local ghost = SpawnAt(nightmare, inst)
    local target = worker.components.combat.target
    costSanity(target, TUNING.SANITY_HUGE)
    ghost.components.combat:SetTarget(target)
  else
    costSanity(worker, TUNING.SANITY_HUGE)
  end

  local fx = SpawnPrefab("collapse_big")
  fx.Transform:SetPosition(x, y, z)
  fx:SetMaterial("stone")

  inst.components.workable.workleft = 0
  inst:Remove()
end, print)
end

local function OnWork(inst, worker, workleft)
xpcall(function ()
print(1111, inst, worker, workleft)
  inst.components.workable.workleft = 1

  if not (worker:HasTag("epic")) then
    return 
  end

  local x, y, z = inst.Transform:GetWorldPosition()
  SpawnPrefab("ash").Transform:SetPosition(x, y, z)
  SpawnPrefab("rocks").Transform:SetPosition(x, y, z)

  local my_workleft = inst.components.workable.my_workleft or TUNING.MOONBASE_DAMAGED_WORK
  my_workleft = my_workleft - 1
  if (my_workleft > 0) then
    local x = 3
    for i=1, x do
      SpawnAt("bat", inst)
    end

    local pt = inst:GetPosition()
    SpawnPrefab("rock_break_fx").Transform:SetPosition(pt:Get())
    -- shake screen and earthquake
    if ( worker:HasTag("hostile") 
      and worker and worker.components 
      and worker.components.combat
      and worker.components.combat.target ) 
    then
      local target = worker.components.combat.target
      costSanity(target, TUNING.SANITY_SMALL)
      local x = math.random()
      local nightmare = "crawlingnightmare"
      if (x < 0.25) then
        nightmare = "nightmarebeak"
      end
      local ghost = SpawnAt(nightmare, inst)
      ghost.components.combat:SetTarget(target)
    else
      costSanity(worker, TUNING.SANITY_SMALL)
    end
  else
    OnWorkFinished(inst, worker)
  end
  inst.components.workable.my_workleft = my_workleft

end, print)

end


local function makefn(name, collide)
    return function()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        if collide then
            MakeObstaclePhysics(inst, 2.35)
        end

        inst.AnimState:SetBank(name)
        inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation("idle", true)
-------------------------
xpcall(function ()
  inst.name = name;
  inst:AddComponent("inspectable")
  -- inst.components.inspectable:SetDescription("")

  -- only epic can workable
  -- if (name == "pillar_ruins") then
  inst:AddComponent("lootdropper")
  -- inst.components.lootdropper:SetLoot({ "thulecite", "thulecite_pieces", "thulecite_pieces" })
  inst.components.lootdropper:SetLoot({ 
      "nightmarefuel", 
      "rocks", "rocks", "log", "ash", "ash",
      "thulecite", "thulecite_pieces", "thulecite_pieces",
  })

  inst:AddComponent("workable")
  inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
  inst.components.workable:SetWorkLeft(TUNING.MOONBASE_COMPLETE_WORK)
  inst.components.workable:SetOnWorkCallback(OnWork)
  inst.components.workable:SetOnFinishCallback(onhit)
  -- end

end, print)    

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        return inst
    end
end

local function pillar(name, collide)
    return Prefab(name, makefn(name, collide), makeassetlist(name))
end

return pillar("pillar_ruins", true),
       pillar("pillar_algae", true),
       pillar("pillar_cave", true),
       pillar("pillar_cave_flintless", true),
       pillar("pillar_cave_rock", true),
       pillar("pillar_stalactite")--,
       --pillar("pillar_cave_moon", true),
       --pillar("pillar_stalactite_moon"),
