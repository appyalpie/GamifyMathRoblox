local OperatorSetObject = {}
OperatorSetObject.__index = OperatorSetObject

function OperatorSetObject.new()
	local self
	self = setmetatable({}, OperatorSetObject)
	self._operatorSet = nil
	self._cardPositionChangedSignal = nil
	
	self._addClickDetectorSignal = nil
	self._subtractClickDetectorSignal = nil
    self._multiplyClickDetectorSignal = nil
    self._divideClickDetectorSignal = nil
    self._undoClickDetectorSignal = nil
	
	self._addOperatorSelected = false
	self._subtractOperatorSelected = false
    self._multiplyOperatorSelected = false
    self._divideOperatorSelected = false

	self._operatorSelectedName = nil
	
	return self
end

function OperatorSetObject:CleanUp()
	self._cardPositionChangedSignal:Disconnect()
	if self._addClickDetectorSignal then
		self._addClickDetectorSignal:Disconnect()
		self._subtractClickDetectorSignal:Disconnect()
		self._multiplyClickDetectorSignal:Disconnect()
		self._divideClickDetectorSignal:Disconnect()
	end
    if self._undoClickDetectorSignal then
        self._undoClickDetectorSignal:Disconnect()
    end
	
	self._operatorSet:Destroy()
	self._operatorSet = nil
end

function OperatorSetObject:DeselectAll()
	self._addOperatorSelected = false
	self._subtractOperatorSelected = false
    self._multiplyOperatorSelected = false
    self._divideOperatorSelected = false

	self._operatorSelectedName = nil
	
	for _, v in pairs(self._operatorSet:GetChildren()) do
		v.Union.Material = "Plastic"
	end
end

function OperatorSetObject:SelectSpecific(operatorName)
	if operatorName == "add" then
		self._addOperatorSelected = true
		self._operatorSelectedName = "add"
		self._operatorSet.Add.Union.Material = "Neon"
	elseif operatorName == "subtract" then
		self._subtractOperatorSelected = true
		self._operatorSelectedName = "subtract"
		self._operatorSet.Subtract.Union.Material = "Neon"
    elseif operatorName == "multiply" then
        self._multiplyOperatorSelected = true
        self._operatorSelectedName = "multiply"
        self._operatorSet.Multiply.Union.Material = "Neon"
    elseif operatorName == "divide" then
        self._divideOperatorSelected = true
        self._operatorSelectedName = "divide"
        self._operatorSet.Divide.Union.Material = "Neon"
    end
end

return OperatorSetObject