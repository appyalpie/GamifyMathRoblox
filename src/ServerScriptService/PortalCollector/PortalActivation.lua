local PortalActivation = {}
-- this confirms the Selection and would play any animation or VFX event
function PortalActivation:SelectPortal(TargetPortal, Player)
    
    --Play animation or FX here
    wait(3)
    self:Teleport(TargetPortal, Player)
end

function PortalActivation:Teleport(TargetPortal, Player)
    local targetposition = Vector3.new(TargetPortal.Exit.Position.X, TargetPortal.Exit.Position.Y+1,TargetPortal.Exit.Position.z)
    Player:FindFirstChild("HumanoidRootPart").CFrame = targetposition.CFrame + Vector3.new(targetposition)
end

return PortalActivation