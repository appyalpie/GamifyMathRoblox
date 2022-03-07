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
        functions["InvData"]:Destroy()
        functions["InvData"] = {}
    end

    function functions.store(player,InvDat)
        functions["InvData"] = InvDat
        return functions["InvData"]
    end

    function functions.Equip(Accessory,Type)
        functions.UnEquip(Type)
        functions["inventory"].Equipped[Type] = Accessory
    end
    function functions.UnEquip(Type)
        functions["inventory"].Equipped[Type] = {}
    end 
    function functions.AddItem(Accessory)
        table.insert(functions["InvData"],Accessory.Name)
        print(functions["InvData"])
    end
    -- since this has the on Server Invoke when it is supposed to send it returns to server
    -- this may need to be moved to a client script local script    


function functions.SendSavedToServer()
    return functions["InvData"]
end
function functions.SendEquippedToServer()
    return functions["inventory"].Equipped
end
return functions



