local GuiUtilities = {}

------ Bar starting from left and filling toward right ------
GuiUtilities.resizeCustomGuiLeftToRight = function(sizeRatio, clipping, top)
    clipping.Size = UDim2.new(sizeRatio, clipping.Size.X.Offset, clipping.Size.Y.Scale, clipping.Size.Y.Offset)
    top.Size = UDim2.new((sizeRatio > 0 and 1 / sizeRatio) or 0, top.Size.X.Offset, top.Size.Y.Scale, top.Size.Y.Offset)
end

return GuiUtilities