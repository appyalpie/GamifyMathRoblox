local titleModule = {}

titleModule.titles = 
{
    "Dev",
    "Serf",
    "Merchant",
    "Professional",
    "Knight",
    "Baron",
    "Count",
    "Duke",
    "King"
}

titleModule.parseTitleIDs = function(IDs)
    local titlesToReturn = {}
    for i = 1, #IDs do
        if IDs[i] < #titleModule.titles and IDs[i] >= 0 then
            table.insert(titlesToReturn, titleModule.titles[IDs[i]])
        end
    end

    return titlesToReturn
end

return titleModule