local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remoteEvent = ReplicatedStorage:WaitForChild("RemoteEvents",5):WaitForChild("InventoryEvents",5)
local remoteServerFunction = Instance.new("RemoteFunction")
-- initalizes the Server Function so when Server invokes the function the data can be sent back to the server
remoteServerFunction.Parent = ReplicatedStorage
remoteServerFunction.Name = "remoteServerFunction"
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

    function functions.store(InvDat)
        functions["InvData"] = InvDat
        return functions["InvData"]
    end

    function functions.Equip(Accessory)
        functions.UnEquip(Accessory)
        functions["inventory"].Equipped[Accessory.Type] = Accessory
        remoteEvent:WaitForChild("InventoryEquip"):FireServer(Accessory.Name)
    end
    function functions.UnEquip(Accessory)
        functions["inventory"].Equipped[Accessory.Type] = nil
    end

    remoteEvent.InventoryStore.OnClientEvent:Connect(function(Inventory)
        functions.store(Inventory)
    end)

    -- since this has the on Server Invoke when it is supposed to send it returns to server
local function SendtoServer()
      return functions["InvData"]
end
     
-- this may need to be moved to a client script local script    
remoteServerFunction.OnServerInvoke = SendtoServer
return functions



