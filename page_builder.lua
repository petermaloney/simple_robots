--BUILDER PAGE

local PLACETIME=0.5 --Time taken to place.

--"PLACE ELSE GOTO" "PLACE UP ELSE GOTO" "PLACE DOWN ELSE GOTO"

-- gets the place sound of a node

local function vm_get_node_place_sound(name)
    local sound = minetest.registered_nodes[name]
    if not sound then
        return
    end
    sound = sound.sounds
    if not sound then
        return
    end
    sound = sound.place
    if not sound then
        return
    end
    return sound
end

local function vm_place(pos1,dir,arg)
    local meta=minetest.get_meta(pos1)
    local pos2=vector.add(pos1,dir)
    if not simple_robots.vm_is_air(minetest.get_node(pos2)) then return simple_robots.vm_lookup(pos1,arg,0) end
    local owner=meta:get_string("robot_owner")
    local stk=meta:get_inventory():get_stack("main",meta:get_int("robot_slot"))
    if stk:is_empty() then return simple_robots.vm_lookup(pos1,arg,0) end
    local fp=simple_robots.vm_fakeplayer(owner,pos1,{sneak=true},meta:get_int("robot_slot"))
    if not fp then return simple_robots.vm_lookup(pos1,arg,0) end
    local stackdef=stk:get_definition()
    local res,tf=stackdef.on_place(stk,fp,{type="node",under=pos1,above=pos2})
    fp:remove()
    meta:get_inventory():set_stack("main",meta:get_int("robot_slot"),res)
    if not tf then return simple_robots.vm_lookup(pos1,arg,PLACETIME) end
    local name = stackdef.name
    if name then
        local sound = vm_get_node_place_sound(name)
        if sound then
            minetest.sound_play(sound.name, {pos=pos2, gain=sound.gain})
        end
    end
    return simple_robots.vm_advance(pos1,PLACETIME)
end

simple_robots.commands["PLACE ELSE GOTO"]=function (pos,arg)
    return vm_place(pos,minetest.facedir_to_dir(minetest.get_node(pos).param2),arg)
end
simple_robots.commands["PLACE UP ELSE GOTO"]=function (pos,arg)
    return vm_place(pos,{x=0,y=1,z=0},arg)
end
simple_robots.commands["PLACE DOWN ELSE GOTO"]=function (pos,arg)
    return vm_place(pos,{x=0,y=-1,z=0},arg)
end

--PAGE DEFINITION

simple_robots.commandpages["builder"]={"PLACE ELSE GOTO","PLACE UP ELSE GOTO","PLACE DOWN ELSE GOTO"}
