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
        [5] = "Since I like you, here's a hint. Watch out for 'fractions' and 'decimals'... they're (whispers) explosive!"
    },
    ["Gurdy"] = {
        [1] = "Har Har! I'm Gurdy! Welcome to the 24 Island Stage.",
        [2] = "Take the teleport pad ahead to the Island.",
        [3] = "You'll find a scoreboard to the left. You can also find a 24 practice pedestal.",
        [4] = "Check out Tony V's below if you need a break. Feel free to do so before venturing on.", 
        [5] = "Master the math concepts here and unlock your way to the 3rd island.",
        [6] = "Make sure to speak to Hurdy if you want to learn more about the 24 game. It's what they pay him for..."  
    },
    ["Pubby"] = {
        [1] = "Welcome to Tony V's!",
        [2] = "Stay awhile if you'd like, we got the finest company in town!",
        [3] = "If you're looking to get to the next Island, ya gotta prove your worth. You gotta beat at least 2 people in 24 to move on.",
        [4] = "Try starting with that 'Tough Guy' in the back!"
    },
    ["Hurdy"] = {
        [1] = ":Sigh: What now? Oh! Hi! I thought you were my brother Gurdy.",
        [2] = "Everyone on this island is OBSESSED with the 24 game.",
        [3] = "Let me tell you the rules. It's what they pay me for...",
        [4] = "24 is a card game where you are dealt 4 cards with number values.",
        [5] = "Your objective is to combine them all to create 24",
        [6] = "Click on a card and select a math operator (addition, subtraction, multiplication, and division). Then click on the card you want to combine. Repeat until you've made 24!",
        [7] = "You will find games of varying difficulty. Green pedestals are the easiest, followed by yellow for medium, and red for hard.",
        [8] = "Players can play alone at pedestals or against other island denizens.",
        [9] = "Lastly, when you are ready for a real challenge. Seek out Tommy Two Decks in the Club. ",
    },
    ["Tammy Two Docks"] = {
        [1] = "Ohhhh ho ho ho! Let's play twenty Fo!"
    },
    ["Timmy Two Ducks"] = {
        [1] = "If ya wanna beat the boss, ya gotta beat me!"
    },
    ["Tommy Two Decks"] = {
        [1] = "Ayyyy ohh. I'm Tommy Two Decks! If you want to MASTER 24. You gotta beat me",
        [2] = "You win and I'll give you a special prize.",
        [3] = "Remember, If you wanna swing at the king then ya betta not miss!" 
    },
    ---main hub NPCs
    ["Rama"] = {
        [1] = "Welcome to the main hub of Mega Blue Traveler. I am Rama the Keeper of these lands.",
        [2] = "Those who seek to master math may seek respite here.",
        [3] = "If you wish to purchase accessories, speak with my sister Llama anon.",
        [4] = "Proceed to the portal in the middle of the plaza when you are ready to move on." 
    },
    ["Llama"] = {
        [1] = "Oi bruv! what's ol' dis then?",
        [2] = "What I got is wot you want!",
        [3] = "'and me yor bees and honey (money) and av a butcher's hook (a look)."
    },
    ------ Inside Tony Vs ------
    ["Tough Guy"] = {
        [1] = "I'm a tough customer.",
        [2] = "Because I'm not very good at math...",
        [3] = "Hey wanna practice with me?"
    },
    ["Pirate Dude 1"] = {
        [1] = "...",
        [2] = "Why doesn't my boss buy a hat?",
        [3] = "You didn't hear  this from me."
    },
    ["Pirate Dude 2"] = {
        [1] = "Time to celebrate my super epic victory at the Champions Club.",
        [2] = "Aww yeahhhhhhh"
    },
    ["Pirate Dude 3"] = {
        [1] = "Huh? I'm not a deckhand what.",
        [2] = "Wait why does it say deckhand above my head?"
    },
    ["Pirate Dude 4"] = {
        [1] = "If you're wondering how to get off this Island, hear this.",
        [2] = "All you gotta do is beat at least 2 different people in 24.",
        [3] = "After that, the barrier comes down easy!"
    },
    ["Pirate Dude 5"] = {
        [1] = "...",
        [2] = "I don't wanna talk about it."
    },
    ["Pirate Dude 6"] = {
        [1] = "Hmm...",
        [2] = "I'm stumped on this one, maybe you can figure it out?",
        [3] = "one, three, four, six",
        [4] = "Is this one even possible?"
    },
    ["Pirate Dude 7"] = {
        [1] = "Hey, have ya challenged the Tough Guy yet?",
        [2] = "He's not so tough."
    },
    ["Skeleton At Tony V"] = {
        [1] = "...",
        [2] = "I can't talk dummy.",
        [3] = ". . .",
        [4] = "Here, I'll show ya something cool"
    },
    ["Hatless Pirate"] = {
        [1] = "Man... I lost my hat.",
        [2] = "Now what am I supposed to do?",
        [3] = "I don't even have 2 hands!"
    },
    ["Pirate Girl 1"] = {
        [1] = "Potion Seller, I require only your strongest potion."
    },
    ["Pirate Girl 2"] = {
        [1] = "...",
        [2] = "This guy keeps bugging me on this really tough problem.",
        [3] = "Maybe you can solve it?"
    },
    ------ Other Misc Island 2 Folk ------
    ["builderman"] = {
        [1] = "Oh hey there!",
        [2] = "I hope you've been enjoying the game so far haha.",
        [3] = "The second layer of the island is under construction, come back soon to see more!",
        [4] = "I'll see you around!"
    },
    ["Fisherman"] = {
        [1] = "24 fish... 24 fish... 24 fish...",
        [2] = "Do I multiply... no maybe subtract..."
    },
    ["Ship Pirate Dude"] = {
        [1] = "Ahoy there sailor!",
        [2] = "Hows it going?",
        [3] = "Wait... how the heck do ships fly?"
    },
    ["Stadium Pirate 1"] = {
        [1] = "Hmm...",
        [2] = "I'm not sure I'm ready for this..."
    },
    ["Stadium Pirate 2"] = {
        [1] = "AHHH",
        [2] = "Tommy Two Decks is too good!"
    },
    ["Stadium Pirate 3"] = {
        [1] = "My goodness...",
        [2] = "Don't be upset man, lets practice and get better!"
    },
    ["Pirate Dude Outside Portal"] = {
        [1] = "How do I get through this barrier...",
        [2] = "I heard you need to beat at least 2 challengers at 24 to pass through",
        [3] = "Hmm..."
    },
    --island 3 npcs--
    ["Randallf_first_meeting"] = {
        [1] = "ooo ooo! eee eee eee urgggghhh....",
        [2] = "Please, give me a Grow potion.",
        [3] = "You only need 100 red mushrooms, 100 blue berries, and 100 green herbs.",
        [4] = "In return, I'll unlock the portal to the next world.", 
    },
    ["Randallf_second_meeting"] = { --if player accept quest does not have potion
        [1] = "Do you have a Grow Potion yet?"
            
    },
    ["Randallf_third_meeting"] = { --if player accept quest does have potion
        [1] = "Ah! you have a Grow Potion!",
        [2] = "Will you please let me have it?"      
    },
    ["Randallf_fourth_meeting"] = { --when quest is done
        [1] = "Thank you for helping me friend! My Back feels much better.",       
    },
    ["Prentiss the apprentice"] = {
        [1] = "Hello Stranger, Welcome to Alchemy Island.",
        [2] = "You can mix ingredients to make potions with wondorous results using your knowledge of ratios.",
        [3] = "My master and I were on our way to make potions when he was beset by back pain. He needs a specific potion to cure him.",
        [4] = "I would help him myself but he hasn't taught me about ratios yet!",
        [5] = "Please talk to him down the way and see what potion he needs. I'm sure he'd help you in return."
    },
    ["Alchemia"] = {
        [1] = "Oh did Randallf send you? That's so nice of you to help him.",
        [2] = "He always gets his ratios confused though.",
        [3] = "To make a grow potion you need: 1 red mushroom, 1 blue berry, and 1 green herb.",
        [4] = "Because you're so nice I'll tell you how to make other potions as well",
        [5] = "To make a shrink potion you need: 1 red mushrooms, 3 blue berries, and 1 green herbs.",
        [6] = "To make an explosive potion you need: 2 red mushrooms, 1 blue berries, and 1 green herbs."
    }
}

return DialogModule