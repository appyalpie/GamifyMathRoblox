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

-- fraction reduce (takes in a numerator and a denominator)
function MathUtilities.reduceFraction(a, b)
    local divisor = MathUtilities.greatestCommonDivisor(a, b)
    a = a / divisor
    b = b / divisor
    if b == 1 then
        return a
    end
    return a .. "/" .. b
end

-- fraction addition (takes in two pairs of numerator and denominators)
function MathUtilities.addFractions(a, b, x, y)
    -- find GCD of of both denominator
    local gcd = MathUtilities.greatestCommonDivisor(b, y)

    -- denominator of final fraction = LCM
    -- LCM * GCD = b * y
    local newDenominator = ( b * y ) / gcd

    -- adjust fractions to new denominator and add
    local newNumerator = (a * (newDenominator / b)) + (x * (newDenominator / y))
    return MathUtilities.reduceFraction(newNumerator, newDenominator)
end

-- fraction subtraction (takes in two pairs of numerator and denominators in order, left operand then right)
function MathUtilities.subtractFractions(a, b, x, y)
    -- find GCD of of both denominator
    local gcd = MathUtilities.greatestCommonDivisor(b, y)

    -- denominator of final fraction = LCM
    -- LCM * GCD = b * y
    local newDenominator = ( b * y ) / gcd

    -- adjust fractions to new denominator and add
    local newNumerator = (a * (newDenominator / b)) - (x * (newDenominator / y))
    return MathUtilities.reduceFraction(newNumerator, newDenominator)
end

return MathUtilities