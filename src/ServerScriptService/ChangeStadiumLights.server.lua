local lights = {}

for i,v in pairs(game.Workspace.Island_2.Gym:GetDescendants()) do
    if v:IsA("BasePart") then
        if v.Name == "Light" then
            table.insert(lights, v)
        end
    end
end

while(true) do
    for i,v in pairs(lights) do
        local rand = math.random(1,3)
        if rand == 1 then
            v.BrickColor = BrickColor.new(1013)
        elseif rand == 2 then
            v.BrickColor = BrickColor.new(1015)
        else
            v.BrickColor = BrickColor.new(1020)
        end
        if v:FindFirstChildWhichIsA("SurfaceLight") then
            local surfaceLights = v:GetDescendants()
            for i, x in pairs (surfaceLights) do
                x.Brightness = 5
                if rand == 1 then
                    x.Color = Color3.fromRGB(0, 247, 255)
                elseif rand == 2 then
                    x.Color = Color3.new(170, 0, 170)
                else
                    x.Color = Color3.new(0, 255, 0)
                end
            end
        end

    end
    wait(1.791)
end