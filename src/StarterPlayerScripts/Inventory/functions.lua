-- initalizes the Server Function so when Server invokes the function the data can be sent back to the server
-- reformated so scoping won't get confusing
local functions= {}
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

    function functions.store(InventoryData)
        functions["InvData"] = InventoryData
    end
    function functions.AddItem(Accessory)
        table.insert(functions["InvData"],Accessory.Name)
        print(functions["InvData"])
    end
    -- since this has the on Server Invoke when it is supposed to send it returns to server
    -- this may need to be moved to a client script local script    


function functions.SendSavedToServer()
    print(functions["InvData"])
    return functions["InvData"]
end
return functions



