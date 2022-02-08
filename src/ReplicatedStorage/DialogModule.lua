local DialogModule = {
    --create dialog for NPCs
    ["NPC1"] = {
        [1] = "Hi There! I'm the Gatekeeper.",
        [2] = "Each door needs 3 key blocks to Unlock it.",
        [3] = "You can push and combine blocks.",
        [4] = "The new block sums the numbers on the 2 blocks.",
        [5] = "The new block is determined by the operator on the door",
        [6] = "When you have the correct number found above the pedestal,",
        [7] = "push that block onto that key block onto the pedestal.",
        [8] = "Good Luck!",
    }, 
    ["NPC2"] = {
        [1] = "Hey, have we met before?",
        [2] = "blocks here perform subtraction when combined.",
        [3] = "Again, please push three key blocks onto the pedestal "    
    },
    ["NPC3"] = {
        [1] = "Gosh, you look familiar",
        [2] = "blocks here perform multiplication when combined.",
        [3] = "3 key blocks are needed."   
    },
    ["NPC4"] = {
        [1] = "It's me again. Your old friend.",
        [2] = "when you combine a block in this area, the result is division",
        [3] = "3 keys please."    
    },  
}

return DialogModule