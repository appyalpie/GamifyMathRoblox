-- initalizes the Server Function so when Server invokes the function the data can be sent back to the server
-- reformated so scoping won't get confusing
local functions= {
    ["inventory"] = {
        Equipped = {
                ["Head"] = {},
                ["Legs"] = {},
                ["Arms"] = {},
                ["Body"] = {},
        },
    }
}
functions["InvData"] = {}

-- displays the items description as a function
    function functions.DisplayDescription()
        print("Display Description worked")
    end
    --resets Inventory as a function
    function functions.Reset()
        functions["InvData"] = nil
    end

    function functions.store(player,InvDat)
        functions["InvData"] = InvDat
        return functions["InvData"]
    end

    function functions.Equip(Accessory)
        functions.UnEquip(Accessory)
        functions["inventory"].Equipped[Accessory.Type] = Accessory
    end
    function functions.UnEquip(Accessory)
        functions["inventory"].Equipped[Accessory.Type] = nil
    end 
    -- since this has the on Server Invoke when it is supposed to send it returns to server
    -- this may need to be moved to a client script local script    


function functions.SendtoServer()
    return functions["InvData"]
end

return functions



