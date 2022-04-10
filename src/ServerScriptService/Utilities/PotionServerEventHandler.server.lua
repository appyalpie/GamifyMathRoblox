local Players = require(game:GetService("ServerScriptService"):WaitForChild("PlayerTable"))
local RemoteEvents = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents")
local PotionStatus = RemoteEvents.PotionStatus
local PotionParticleRE = RemoteEvents.PotionParticleRE


PotionStatus.OnServerEvent:Connect(
	function(player, status)
		Players[player.UserId] = status
	end)


local function MarkParticles(player,color)
    print("Particle Function Fired")
    local powerParticle = Instance.new("ParticleEmitter")
	powerParticle.Parent = player.Character:FindFirstChild("HumanoidRootPart")
	powerParticle.Size = NumberSequence.new(.5, .5)
	powerParticle.Color = color
	powerParticle.Lifetime = NumberRange.new(2, 2)
	powerParticle.Rate = 100
	powerParticle.Speed = NumberRange.new(5, 5)
	powerParticle.SpreadAngle = Vector2.new(1000, 1000)
	task.wait(2)
	powerParticle.Rate = 0
	task.wait(5)
	powerParticle:Destroy()
end

PotionParticleRE.OnServerEvent:Connect(MarkParticles)
