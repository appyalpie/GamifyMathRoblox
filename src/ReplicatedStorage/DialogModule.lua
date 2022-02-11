local DialogModule = {
    --create dialog for NPCs
    ["Eenie"] = {
        [1] = "Hi There! I'm the Gatekeeper of Mega Blue. Welcome to the Island!",
        [2] = "To get to the next island, you will need to face my challenge! Try and unlock the door by inserting math blocks into the colored 'zone' by that giant door.",
        [3] = "You can push and combine blocks.",
        [4] = "Combining blocks will create a new block with a new value depending on the numbers on the 2 blocks. For this first section... we have addition!",
        [5] = "Muahahaha",
        [6] = "You gotta push the correct block into the zone.",
        [7] = "Good Luck!",
    }, 
    ["Meenie"] = {
        [1] = "Hey, have we met before?",
        [2] = "Blocks here perform 'subtraction' when combined. The blue blocks can take away value.",
        [3] = "Kinda similar to the last section... kinda...",
        [4] = "When you have a block that is the same number as listed on that blue zone next to the giant door, go ahead and push it on there.",
        [5] = "Again, your gonna need 3! Muahahaha."
    },
    ["Miney"] = {
        [1] = "Gosh, you look familiar.",
        [2] = "Blocks here perform 'multiplication' when combined. Numbers can get really big really fast!",
        [3] = "3 key blocks my friend, and you may pass."   
    },
    ["Moe"] = {
        [1] = "It's me again. Your old friend. Moe.",
        [2] = "Things are a bit trickier in this area.",
        [3] = "This time, when you combine 2 blocks, the smaller number block will 'divide' the larger number block. This means that blocks can reduce value from one another!",
        [4] = "3 more key blocks! Good luck!",
        [5] = "(Hint: watch out for 'fractions' and 'decimals'... they're explosive!)"
    },  
}

return DialogModule