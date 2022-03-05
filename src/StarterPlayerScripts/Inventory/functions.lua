local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remoteEvent = ReplicatedStorage:WaitForChild("RemoteEvents",5):WaitForChild("InventoryEvents",5)
local remoteServerFunction = remoteEvent:WaitForChild("InventorySave")
-- reformated so scoping won't get confusing
functions["inventory"] = {
        Equipped = {
                ["Head"] = {},
                ["Legs"] = {},
                ["Arms"] = {},
                ["Body"] = {}
        },
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

    function functions.store(InvDat)
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

    remoteEvent.InventoryStore.OnClientEvent:Connect(function(Inventory)
        functions.store(Inventory)
    end)
local function SendtoServer()
      return functions["InvData"]
end
     
    
remoteServerFunction.OnServerInvoke = SendtoServer



