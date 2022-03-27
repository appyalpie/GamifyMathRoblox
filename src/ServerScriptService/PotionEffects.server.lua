--[[local db = false
local direction
local debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ThrowPotion = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("ThrowPotion")
local potion = script.Parent.PotionBottle

ThrowPotion.OnServerEvent:Connect(function(player, mousePos)
direction = mousePos
end)
local function PotionEffects(PotionName,PlayerHumanoid)

end

script.Parent.Activated:Connect(function ()
    if  not db then
        db = true

        local humanoid = script.Parent.Parent:FindFirstChild("Humanoid")
        local throwAnim = humanoid:LoadAnimation(script.Throw)
        throwAnim:Play()

        wait(.5)

        script.Parent.Handle.Throw:Play()
        script.Parent:Destroy() -- remove from player instead
        local Item = potion:Clone()
        Item.CFrame = CFrame.new(script.Parent.PotionBottle.Handle.Position + script.Parent.PotionBottle.Handle.CFrame.LookVector *3 , direction)

        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
        bv.P = 3000
        local ori = 0

        spawn(function()
            while wait() do
                ori = ori - .1
                Item.CFrame = Item.CFrame + Item.CFrame.LookVector *4
                Item.Orientation = Vector3.new(Item.Orientation.X + ori, Item.Orientation.Y, Item.Orientation.Z)
            end
        end)
        Item.Touched:Connect(function(hit)
            local AOE = Instance.new("Part")
            AOE.CanCollide = false
            AOE.Anchored = true
            AOE.Transparency = 1
            AOE.Shape = "Ball"
            AOE.Size = Vector3.new(10,10,10)
            AOE.Parent = Item
            AOE.Position = hit
            
            AOE.Touched:Connect(function(Player)
                local Player = game.Players:GetPlayerFromCharcter(Player.Parent)
                wait(.5)
                AOE:Destroy()
                if Player then
                    local char = Player.Character
                    local Humanoid = char:FindFirstChild("Humanoid")
                    PotionEffects(Item.Name,Humanoid)
                end
            end)
           

        end)
    end
end)]]



