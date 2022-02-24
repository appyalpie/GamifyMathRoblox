local ServerScriptService = game:GetService("ServerScriptService")
local MathUtilities = require(ServerScriptService.Utilities.MathUtilities)

local Card = {}
Card.__index = Card

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

function Card.getReducedFraction(a, b)

end

function Card.calculateValue(value)
	if type(value) == "table" then
        

        if value[1] == "add" then
            return Card.calculateValue(value[2]) + Card.calculateValue(value[3])
        elseif value[1] == "subtract" then
            return Card.calculateValue(value[2]) - Card.calculateValue(value[3])
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
            if Card.calculateValue(value[2]) % Card.calculateValue(value[3]) == 0 then
                return Card.calculateValue(value[2]) / Card.calculateValue(value[3])
            else -- returning a fraction
                return tostring(Card.calculateValue(value[2])) .. "/" .. tostring(Card.calculateValue(value[3]))
            end
        end
	end
	return value
end

-- Calculate number from possibly recursive tables
function Card:UpdateGUI()
	local TextLabel = self._cardObject.SurfaceGui.TextLabel
	TextLabel.Text = Card.calculateValue(self._cardTable)
end

return Card
