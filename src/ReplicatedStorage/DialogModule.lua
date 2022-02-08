local DialogModule = {
    --create dialog for NPCs
    ["Eenie"] = {
        [1] = "Hi There! I'm the Gatekeeper.",
        [2] = "Each door needs 3 key blocks to Unlock it.",
        [3] = "You can push and combine blocks.",
        [4] = "The new block sums the numbers on the 2 blocks.",
        [5] = "The new block is determined by the operator on the door",
        [6] = "When you have the correct number found above the pedestal,",
        [7] = "push that block onto the pedestal.",
        [8] = "Good Luck!",
    }, 
    ["Meenie"] = {
        [1] = "Hey, have we met before?",
        [2] = "blocks here perform subtraction when combined.",
        [3] = "Meaning two blocks can be pushed together and the new block",
        [4] = "will be smaller than the largest of the two blocks",
        [5] = "When you have a block that is the same number as the pedestal,",
        [6] = "push that block onto the pedestal.",
        [7] = "Again, please push three key blocks onto the pedestal "    
    },
    ["Miney"] = {
        [1] = "Gosh, you look familiar",
        [2] = "blocks here perform multiplication when combined.",
        [3] = "Again, 3 key blocks are needed."   
    },
    ["Moe"] = {
        [1] = "It's me again. Your old friend.",
        [2] = "Things are a bit trickier in this area.",
        [3] = "This time, when combine 2 blocks, the smaller number",
        [4] = "block will divide the larger number block.",
        [5] = "Once you've found the number displayed by the pedestal,",
        [6] = "push that block onto the pedestal", 
        [7] = "do this 3 times to unlock the door and proceed."   
    },  
}

return DialogModule