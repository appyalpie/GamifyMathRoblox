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

function Card.calculateValue(value)
	if type(value) == "table" then
		if value[1] then
			if value[1] == "add" then
				return Card.calculateValue(value[2]) + Card.calculateValue(value[3])
			elseif value[1] == "subtract" then
				return Card.calculateValue(value[2]) - Card.calculateValue(value[3])
			elseif value[1] == "multiply" then
				return Card.calculateValue(value[2]) * Card.calculateValue(value[3])
			elseif value[1] == "divide" then
				-- special case???????????????????????????????????????????????????????????????????????????????
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
