local MathUtilities = {}

function MathUtilities.formatTime(timeLeft)
    --local minutes = math.floor(timeLeft / 60)
    local seconds = math.floor(timeLeft % 60)
    --local hundreths = math.floor(timeLeft % 1 * 100)
    --return string.format("%02i:%02i:%02i", minutes, seconds, hundreths)
    return string.format("%02i", seconds)
end

return MathUtilities