local lights = {}

for i,v in pairs(game.Workspace.Gym:GetDescendants()) do
    if v:IsA("BasePart") then
        if v.Name == "Light" then
            --v.UsePartColor = true
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
    end
    wait(1.791)
end