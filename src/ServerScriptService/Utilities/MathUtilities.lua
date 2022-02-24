local MathUtilities = {}

function MathUtilities.formatTime(timeLeft)
    --local minutes = math.floor(timeLeft / 60)
    local seconds = math.floor(timeLeft % 60)
    --local hundreths = math.floor(timeLeft % 1 * 100)
    --return string.format("%02i:%02i:%02i", minutes, seconds, hundreths)
    return string.format("%02i", seconds)
end

-- greatest common devisor
function MathUtilities.greatestCommonDivisor(a, b)
    if b ~= 0 then
        return MathUtilities.greatestCommonDivisor(b, a % b)
    else
        return math.abs(a)
    end
end

-- fraction reduce
function MathUtilities.reduceFraction(a, b)
    local divisor = MathUtilities.greatestCommonDivisor(a, b)
    a = a / divisor
    b = b / divisor
    if b == 1 then
        return a
    end
    return a .. "/" .. b
end

return MathUtilities