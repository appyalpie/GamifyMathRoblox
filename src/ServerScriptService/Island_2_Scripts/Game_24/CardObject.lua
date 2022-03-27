local ServerScriptService = game:GetService("ServerScriptService")
local MathUtilities = require(ServerScriptService.Utilities.MathUtilities)

local Card = {}
Card.__index = Card

--[[
add = "➕",
subtract = "➖",
multiply = "✖️",
divide = "➗"
]]

local operatorTranslations = {
    add = "+",
    subtract = "-",
    multiply = "x",
    divide = "/"
}

local ColorHexDepthTable = { -- [1] = Top level node
    "#eb4034", -- Red
    "#eded2b", -- Yellow
    "#2bed31", -- Green
    "#2ee7ff", -- Teal
    "#423ade" -- Indigo
}

function Card.new()
	local self
	self = setmetatable({}, Card)
	self._cardTable = {"add", 0, 0} -- {operator, num1, num2}
	self._cardObject = nil
	self._selected = false
	self._startingPosition = nil
	self._operatorSetObject = nil
	--self._combinedCard = false [ we can tell if a card is combined by checking if the card table has table values for either 2 or 3 ]
	--self._positionChangedSignal = nil
	--self._operators = nil
	
	return self
end

function Card.calculateValue(value)
	if type(value) == "table" then
        if value[1] == "add" then
            local calculatedSecondValue = Card.calculateValue(value[2])
            local calculatedThirdValue = Card.calculateValue(value[3])
            if type(calculatedSecondValue) == "string" and type(calculatedThirdValue) == "string" then -- adding two fractions
                local firstFraction = calculatedSecondValue:split("/")
                local secondFraction = calculatedThirdValue:split("/")
                return MathUtilities.addFractions(firstFraction[1], firstFraction[2], secondFraction[1] ,secondFraction[2])
            end
            if type(calculatedSecondValue) == "string" then -- add fraction and a number
                local fraction = calculatedSecondValue:split("/")
                return MathUtilities.addFractions(fraction[1],  fraction[2], calculatedThirdValue, 1)
            end
            if type(calculatedThirdValue) == "string" then -- add number and fraction
                local fraction = calculatedThirdValue:split("/")
                return MathUtilities.addFractions(calculatedSecondValue, 1, fraction[1], fraction[2])
            end
            return calculatedSecondValue + calculatedThirdValue -- add normally
        elseif value[1] == "subtract" then
            local calculatedSecondValue = Card.calculateValue(value[2])
            local calculatedThirdValue = Card.calculateValue(value[3])
            if type(calculatedSecondValue) == "string" and type(calculatedThirdValue) == "string" then -- adding two fractions
                local firstFraction = calculatedSecondValue:split("/")
                local secondFraction = calculatedThirdValue:split("/")
                return MathUtilities.subtractFractions(firstFraction[1], firstFraction[2], secondFraction[1] ,secondFraction[2])
            end
            if type(calculatedSecondValue) == "string" then -- add fraction and a number
                local fraction = calculatedSecondValue:split("/")
                return MathUtilities.subtractFractions(fraction[1],  fraction[2], calculatedThirdValue, 1)
            end
            if type(calculatedThirdValue) == "string" then -- add number and fraction
                local fraction = calculatedThirdValue:split("/")
                return MathUtilities.subtractFractions(calculatedSecondValue, 1, fraction[1], fraction[2])
            end
            return calculatedSecondValue - calculatedThirdValue
        elseif value[1] == "multiply" then
            local calculatedSecondValue = Card.calculateValue(value[2])
            local calculatedThirdValue = Card.calculateValue(value[3])
            if type(calculatedSecondValue) == "string" and type(calculatedThirdValue) == "string" then -- multiply two fractions
                local firstFraction = calculatedSecondValue:split("/")
                local secondFraction = calculatedThirdValue:split("/")
                return MathUtilities.reduceFraction(firstFraction[1] * secondFraction[1], firstFraction[2] * secondFraction[2])
            end
            if type(calculatedSecondValue) == "string" then -- multiply fraction and number
                local fraction = calculatedSecondValue:split("/")
                return MathUtilities.reduceFraction(fraction[1] * calculatedThirdValue, fraction[2])
            end
            if type(calculatedThirdValue) == "string" then -- multiply number and fraction
                local fraction = calculatedThirdValue:split("/")
                return MathUtilities.reduceFraction(calculatedSecondValue * fraction[1], fraction[2])
            end
            return calculatedSecondValue * calculatedThirdValue -- multiply normally (number and number)
        elseif value[1] == "divide" then
            local calculatedSecondValue = Card.calculateValue(value[2])
            local calculatedThirdValue = Card.calculateValue(value[3])
            if type(calculatedSecondValue) == "string" and type(calculatedThirdValue) == "string" then -- divide two fractions (similar to multiply)
                local firstFraction = calculatedSecondValue:split("/")
                local secondFraction = calculatedThirdValue:split("/")
                return MathUtilities.reduceFraction(firstFraction[1] * secondFraction[2], firstFraction[2] * secondFraction[1])
            end
            if type(calculatedSecondValue) == "string" then -- divide a fraction by a number
                local fraction = calculatedSecondValue:split("/")
                return MathUtilities.reduceFraction(fraction[1], fraction[2] * calculatedThirdValue)
            end
            if type(calculatedThirdValue) == "string" then -- divide number and fraction
                local fraction = calculatedThirdValue:split("/")
                return MathUtilities.reduceFraction(calculatedSecondValue * fraction[2], fraction[1])
            end
            if calculatedSecondValue % calculatedThirdValue == 0 then -- return a whole number
                return calculatedSecondValue / calculatedThirdValue
            end
            return MathUtilities.reduceFraction(calculatedSecondValue, calculatedThirdValue) -- divide two numbers
        end
	end
	return value
end

-- Calculate number from possibly recursive tables
function Card:UpdateGUI()
	local TextLabel = self._cardObject.Base_Card.SurfaceGui.TextLabel
	TextLabel.Text = Card.calculateValue(self._cardTable)
end

function Card.maxDepth(value)
    if type(value) == "table" then
        local leftDepth = Card.maxDepth(value[2])
        local rightDepth = Card.maxDepth(value[3])
        if leftDepth == 2 and rightDepth == 2 then -- special case when depths are even
            return 4
        elseif leftDepth > rightDepth then
            return leftDepth + 1
        else
            return rightDepth + 1
        end
    end
    return 0
end

function Card.getSequence(value)
    if type(value[2]) == "table" and type(value[3]) == "table" then
        return "(" .. Card.getSequence(value[2]) .. operatorTranslations[tostring(value[1])] .. Card.getSequence(value[3]) .. ")"
    end
    return tostring(value[2])
end

function Card.getColoredSequenceWithDepth(value, depth)
    if type(value[2]) == "table" and type(value[3]) == "table" then
        return '<font color="'.. ColorHexDepthTable[depth] .. '">' .. 
            Card.getColoredSequenceWithDepth(value[2], depth + 1) .. 
            operatorTranslations[tostring(value[1])] .. 
            Card.getColoredSequenceWithDepth(value[3], depth + 1) ..
            "</font>"
    end
    return tostring(value[2])
end

return Card