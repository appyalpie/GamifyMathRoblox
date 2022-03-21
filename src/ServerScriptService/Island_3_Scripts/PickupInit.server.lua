local ServerStorage = game:GetService("ServerStorage")

local redIngredient = ServerStorage.Island_3.ingredients:WaitForChild("red")
local greenIngredient = ServerStorage.Island_3.ingredients:WaitForChild("green")
local blueIngredient = ServerStorage.Island_3.ingredients:WaitForChild("blue")

for _,part in pairs(workspace.Island_3.test_zone.ingredients:GetDescendants()) do
    if part:IsA("BasePart") then
        -- what happens for red block
        if part.Name == "red" then 
            part.Touched:Connect(function(objectHit)
                local playerBackback = game.Players:GetPlayerFromCharacter(objectHit.Parent):WaitForChild("Backpack")
                local backpackContents = playerBackback:GetChildren()
                local hasIngredient = false

                for _, backpackItem in pairs(backpackContents) do
                    if backpackItem.Name == "red" then
                        backpackItem:SetAttribute("quantity", backpackItem:GetAttribute("quantity") + 1)
                        hasIngredient = true
                    end
                end

                if not hasIngredient then
                    local redClone = redIngredient:Clone()
                    redClone.Parent = playerBackback
                end

                part:Destroy()
            end)
        end
        -- what happens for blue block
        if part.Name == "blue" then 
            part.Touched:Connect(function(objectHit)
                local playerBackback = game.Players:GetPlayerFromCharacter(objectHit.Parent):WaitForChild("Backpack")
                local blueClone = blueIngredient:Clone()
                blueClone.Parent = playerBackback
                part:Destroy()
            end)
        end
        -- what happens for green block
        if part.Name == "green" then 
            part.Touched:Connect(function(objectHit)
                local playerBackback = game.Players:GetPlayerFromCharacter(objectHit.Parent):WaitForChild("Backpack")
                local greenClone = greenIngredient:Clone()
                greenClone.Parent = playerBackback
                part:Destroy()
            end)
        end
    end
end