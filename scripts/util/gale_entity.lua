local GaleCommon = require("util/gale_common")
local FunctionPriorityList = GaleCommon.FunctionPriorityList

-- CreateNormalEntity data params:
------------common------------
-- assets
-- animfilename
-- prefabname
-- tags
-- bank
-- build
-- anim
-- loop_anim
-- persists
-- animover_remove
-- clientfn_priority
-- serverfn_priority
-- clientfn
-- serverfn 

local function CreateNormalEntity(data)
    local assets = data.assets or {
        Asset("ANIM", "anim/"..(data.animfilename or data.prefabname)..".zip"),
    }
	local function FxFn()
		local inst = CreateEntity()
		inst.entity:AddTransform()
		inst.entity:AddSoundEmitter() 
		inst.entity:AddNetwork()

        local has_anim = data.bank or data.build
		
        if has_anim then
            inst.entity:AddAnimState()

            if data.bank then
                inst.AnimState:SetBank(data.bank)
            end
            if data.build then
                inst.AnimState:SetBuild(data.build)
            end

            if data.lightoverride then 
                inst.AnimState:SetLightOverride(data.lightoverride)
            end 
    
            if data.final_offset then 
                inst.AnimState:SetFinalOffset(data.final_offset)
            end 

            if not data.loop_anim then 
                local anim_queue = {}
                
                if data.anim then 
                    if type(data.anim) == "string" then 
                        table.insert(anim_queue,data.anim)
                    elseif type(data.anim) == "function" then 
                        local result = data.anim(inst)
                        if type(result) == "string" then 
                            table.insert(anim_queue,result)
                        elseif type(result) == "table" then 
                            anim_queue = ArrayUnion(anim_queue,result)
                        end
                    end 
                    
                    for k,v in pairs(anim_queue) do 
                        if k == 1 then 
                            inst.AnimState:PlayAnimation(v)
                        else
                            inst.AnimState:PushAnimation(v,false)
                        end
                    end
                end 
            else
                if data.anim then 
                    if type(data.anim) == "string" then 
                        inst.AnimState:PlayAnimation(data.anim,true)
                    elseif type(data.anim) == "function" then 
                        inst.AnimState:PlayAnimation(data.anim(inst),true)
                    end 
                end 
            end    
        end

        for k,v in pairs(data.tags or {}) do 
            inst:AddTag(v)
        end

        FunctionPriorityList(data.clientfn_priority):Execute(inst)

        if data.clientfn then 
			data.clientfn(inst) 
		end

		inst.entity:SetPristine()
	
		if not TheWorld.ismastersim then
			return inst
		end

        inst.persists = (data.persists == nil) and true or data.persists
		
        if data.animover_remove then 
			inst:ListenForEvent("animover",inst.Remove)
		end 

        FunctionPriorityList(data.serverfn_priority):Execute(inst)

        if data.serverfn then 
			data.serverfn(inst) 
		end
		
		return inst
	end

	return Prefab(data.prefabname,FxFn,assets)
end

local function CreateNormalFx(data)
    data.persists = (data.persists == nil) and false or data.persists
    data.animover_remove = (data.animover_remove == nil) and true or data.animover_remove
    data.tags = ArrayUnion(data.tags or {},{"FX","NOCLICK","NOBLOCK"})

    return CreateNormalEntity(data)
end

local function CreateClientFX(data)
    local assets = data.assets or {
        Asset("ANIM", "anim/"..(data.animfilename or data.prefabname)..".zip"),
    }

    local function startfx(proxy)
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()

        local parent = proxy.entity:GetParent()
        if parent ~= nil then
            inst.entity:SetParent(parent.entity)
        end

        inst.Transform:SetFromProxy(proxy.GUID)

        if data.faced == 2 then
            inst.Transform:SetTwoFaced()
        elseif data.faced == 8 then
            inst.Transform:SetEightFaced()
        elseif data.faced == 6 then
            inst.Transform:SetSixFaced()
        elseif data.faced == 4 then
            inst.Transform:SetFourFaced()
        end
        

        inst:AddTag("FX")

        inst.entity:SetCanSleep(false)
        inst.persists = false

        inst.AnimState:SetBank(data.bank)
        inst.AnimState:SetBuild(data.build)

        if data.anim then
            inst.AnimState:PlayAnimation(data.anim) 
        end
        


	    if data.animover_remove == nil or data.animover_remove == true then 
			inst:ListenForEvent("animover",inst.Remove)
		end 

        if data.clientfn_fx then
            data.clientfn_fx(inst)
        end
    end

	local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddNetwork()

        --Dedicated server does not need to spawn the local fx
        if not TheNet:IsDedicated() then
            inst:DoTaskInTime(0, startfx, inst)
        end

        inst:AddTag("FX")

        if data.clientfn then
            data.clientfn(inst)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false
        inst:DoTaskInTime(data.server_remove_time or 1, inst.Remove)

        if data.serverfn then
            data.serverfn(inst)
        end

        return inst
    end

	return Prefab(data.prefabname,fn,assets)
end

-- CreateNormalInventoryItem data params:
-- inventoryitem_data = {
--     imagename
--     atlasname
--     atlasname_override
--     floatable_param
--     use_gale_item_desc
-- }
-- finiteuses_data = {
--     maxuse
--     onfinished
-- }
local function CreateNormalInventoryItem(data)    
    data.inventoryitem_data = data.inventoryitem_data or {}
    local function HackFnClient(inst)
        MakeInventoryPhysics(inst)
        if data.inventoryitem_data.floatable_param == nil then
            MakeInventoryFloatable(inst, "med", 0.2, {1.1, 0.5, 1.1})
        elseif data.inventoryitem_data.floatable_param ~= false then
            MakeInventoryFloatable(inst,unpack(data.inventoryitem_data.floatable_param))
        end
    end

    local function HackFnServer(inst)
        inst:AddComponent("inspectable")

        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.imagename = data.inventoryitem_data.imagename or data.prefabname
        inst.components.inventoryitem.atlasname = data.inventoryitem_data.atlasname_override or ("images/inventoryimages/"..(data.inventoryitem_data.atlasname or data.prefabname)..".xml")

        if data.inventoryitem_data.use_gale_item_desc then
            inst:AddComponent("gale_item_desc")
        end

        if data.finiteuses_data then 
            inst:AddComponent("finiteuses")
			inst.components.finiteuses:SetMaxUses(data.finiteuses_data.maxuse)
			inst.components.finiteuses:SetUses(data.finiteuses_data.maxuse)
			inst.components.finiteuses:SetOnFinished(data.finiteuses_data.onfinished or inst.Remove)
        end 

        MakeHauntableLaunch(inst)
    end

    data.clientfn_priority = data.clientfn_priority or {}
    data.serverfn_priority = data.serverfn_priority or {}

    table.insert(data.clientfn_priority,{HackFnClient,1})
    table.insert(data.serverfn_priority,{HackFnServer,1})
    return CreateNormalEntity(data)
end

-- CreateNormalEquipedItem data param:
-- equippable_data = {
--     equipslot
--     owner_listeners
--     onequip_priority
--     onunequip_priority
-- }
local function CreateNormalEquipedItem(data)
    local function OnEquip(inst, owner) 
        FunctionPriorityList(data.equippable_data.onequip_priority):Execute(inst,owner)
        if data.equippable_data.owner_listeners then 
			for k,v in pairs(data.equippable_data.owner_listeners) do 
				inst:ListenForEvent(v[1],v[2],owner)
			end
		end
    end

    local function OnUnEquip(inst, owner) 
        FunctionPriorityList(data.equippable_data.onunequip_priority):Execute(inst,owner)
        if data.equippable_data.owner_listeners then 
			for k,v in pairs(data.equippable_data.owner_listeners) do 
				inst:RemoveEventCallback(v[1],v[2],owner)
			end
		end
    end

    local function HackFn(inst)
        inst:AddComponent("equippable")
        inst.components.equippable.equipslot = data.equippable_data.equipslot or EQUIPSLOTS.HANDS
        inst.components.equippable:SetOnEquip(OnEquip)
        inst.components.equippable:SetOnUnequip(OnUnEquip)
    end 

    data.serverfn_priority = data.serverfn_priority or {}
    table.insert(data.serverfn_priority,{HackFn,2})
    return CreateNormalInventoryItem(data)
end

-- weapon_data = {
--     swapanims
--     onequip_anim_override
--     onunequip_anim_override
--     damage
--     ranges
-- }
local function CreateNormalWeapon(data)
    local swapanims = nil 
    if data.weapon_data.swapanims == false then
    
    else 
        swapanims = data.weapon_data.swapanims or {"swap_"..data.prefabname,"swap_"..data.prefabname}
    end
    data.equippable_data = data.equippable_data or {}
    data.equippable_data.equipslot = EQUIPSLOTS.HANDS
    data.equippable_data.onequip_priority = data.equippable_data.onequip_priority or {}
    data.equippable_data.onunequip_priority = data.equippable_data.onunequip_priority or {}

    table.insert(data.equippable_data.onequip_priority,{
        data.weapon_data.onequip_anim_override or 
        function (inst,owner)
            if swapanims then
                owner.AnimState:OverrideSymbol("swap_object", swapanims[1],swapanims[2])
            end
            owner.AnimState:Show("ARM_carry") 
            owner.AnimState:Hide("ARM_normal") 
        end
        ,-1
    })
    table.insert(data.equippable_data.onunequip_priority,{
        data.weapon_data.onunequip_anim_override or 
        function (inst,owner)
            owner.AnimState:Hide("ARM_carry") 
            owner.AnimState:Show("ARM_normal") 
        end
        ,-1
    })

    local function HackFn(inst)
        inst:AddComponent("weapon")
		inst.components.weapon:SetDamage(data.weapon_data.damage)	
		if data.weapon_data.ranges then 
			if type(data.weapon_data.ranges) == "table"	then 
				inst.components.weapon:SetRange(data.weapon_data.ranges[1],data.weapon_data.ranges[2])
			else
				inst.components.weapon:SetRange(data.weapon_data.ranges)
			end 
		end 
    end

    data.serverfn_priority = data.serverfn_priority or {}
    table.insert(data.serverfn_priority,{HackFn,3})
    return CreateNormalEquipedItem(data)
end

local function CreateNormalHat(data)
    local swapanims = data.hat_data.swapanims or {"swap_"..data.prefabname,"swap_"..data.prefabname}
    data.tags = data.tags or {}
    table.insert(data.tags,"hat")
    
    data.equippable_data = data.equippable_data or {}
    data.equippable_data.equipslot = EQUIPSLOTS.HEAD
    data.equippable_data.onequip_priority = data.equippable_data.onequip_priority or {}
    data.equippable_data.onunequip_priority = data.equippable_data.onunequip_priority or {}

    table.insert(data.equippable_data.onequip_priority,{
        data.hat_data.onequip_anim_override or 
        function (inst,owner)
            owner.AnimState:OverrideSymbol("swap_hat", swapanims[1],swapanims[2])
		
            if data.hat_data.is_top then 
                owner.AnimState:Show("HAT")
                owner.AnimState:Hide("HAIR_HAT")
                owner.AnimState:Show("HAIR_NOHAT")
                owner.AnimState:Show("HAIR")

                owner.AnimState:Show("HEAD")
                owner.AnimState:Hide("HEAD_HAT")
            else
                owner.AnimState:Show("HAT")
                owner.AnimState:Show("HAIR_HAT")
                owner.AnimState:Hide("HAIR_NOHAT")
                owner.AnimState:Hide("HAIR")

                if owner:HasTag("player") then
                    owner.AnimState:Hide("HEAD")
                    owner.AnimState:Show("HEAD_HAT")
                end
            end 
        
        end
        ,-1
    })
    table.insert(data.equippable_data.onunequip_priority,{
        data.hat_data.onunequip_anim_override or 
        function (inst,owner)
            owner.AnimState:ClearOverrideSymbol("swap_hat")
            owner.AnimState:Hide("HAT")
            owner.AnimState:Hide("HAIR_HAT")
            owner.AnimState:Show("HAIR_NOHAT")
            owner.AnimState:Show("HAIR")

            if owner:HasTag("player") then
                owner.AnimState:Show("HEAD")
                owner.AnimState:Hide("HEAD_HAT")
            end
        end
        ,-1
    })

    return CreateNormalEquipedItem(data)
end

local function CreateClientAnim(data)
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()

    local has_anim = data.bank or data.build
		
    if has_anim then
        inst.entity:AddAnimState()

        if data.bank then
            inst.AnimState:SetBank(data.bank)
        end
        if data.build then
            inst.AnimState:SetBuild(data.build)
        end

        if data.lightoverride then 
            inst.AnimState:SetLightOverride(data.lightoverride)
        end 

        if data.final_offset then 
            inst.AnimState:SetFinalOffset(data.final_offset)
        end 

        if not data.loop_anim then 
            local anim_queue = {}
            
            if data.anim then 
                if type(data.anim) == "string" then 
                    table.insert(anim_queue,data.anim)
                elseif type(data.anim) == "function" then 
                    local result = data.anim(inst)
                    if type(result) == "string" then 
                        table.insert(anim_queue,result)
                    elseif type(result) == "table" then 
                        anim_queue = ArrayUnion(anim_queue,result)
                    end
                end 
                
                for k,v in pairs(anim_queue) do 
                    if k == 1 then 
                        inst.AnimState:PlayAnimation(v)
                    else
                        inst.AnimState:PushAnimation(v,false)
                    end
                end
            end 
        else
            if data.anim then 
                if type(data.anim) == "string" then 
                    inst.AnimState:PlayAnimation(data.anim,true)
                elseif type(data.anim) == "function" then 
                    inst.AnimState:PlayAnimation(data.anim(inst),true)
                end 
            end 
        end    
    end

    for k,v in pairs(data.tags or {}) do 
        inst:AddTag(v)
    end

    return inst
end


-- Unfinished
local function CreateNormalArmor(data)
    return CreateNormalEquipedItem(data)
end

return {
    CreateNormalEntity = CreateNormalEntity,
    CreateNormalFx = CreateNormalFx,
    CreateClientFX = CreateClientFX,
    CreateClientAnim = CreateClientAnim,
    CreateNormalInventoryItem = CreateNormalInventoryItem,
    CreateNormalEquipedItem = CreateNormalEquipedItem,
    CreateNormalWeapon = CreateNormalWeapon,
    CreateNormalHat = CreateNormalHat,
    -- CreateNormalArmor = CreateNormalArmor,
}