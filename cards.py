import math


def comp10001go_score_group(cards_original):
    card_suits = ['H', 'D', 'S', 'C']
    card_nums = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']

    cards_original.sort()

    # is N-of-a-kind?
    val_to_check = getValue(cards_original[0])
    is_n_o_k = True
    for c in cards_original:
        if getValue(c) != val_to_check or c[0] == "A":
            # not n of a kind
            is_n_o_k = False
        else :
            # is n of a kind
            is_n_o_k = True

    # is it a run?
    # split up wilds and cards
    wilds = [c for c in cards_original if c[0] == "A"]    
    cards = [c for c in cards_original if c[0] != "A"]

    # cards.sort()
    cards = useWildCards(cards, wilds)
    # cards.sort()
    print(cards)

    isRun = True
    for i in range(0, len(cards)-1):
        if(getValue(cards[i+1]) != getValue(cards[i]) + 1 or getColour(cards[i+1]) == getColour(cards[i])):
            isRun = False

    if(len(cards_original) < 3 or len(cards) < 3):
        isRun = False
        if(len(cards_original)<2):
            is_n_o_k = False

    if(is_n_o_k):
        print("NoK")
        return getNoKScore(cards, val_to_check)
    elif(isRun):
        print("Run")
        return sumCards(cards)
    else:
        print("Singletons")

        return -1*sumCards(cards_original)

def sumCards(cards):
    score = 0
    for c in cards:
        score += int(getValue(c))
    return score

def useWildCards(cards, wilds):
    wild_colours = {"R" : 0, "B" : 0}

    for w in wilds:
        if(getColour(w) == "R"):
            wild_colours["R"]+=1
        else:
            wild_colours["B"]+=1

    for w in wilds:
        for i in range(0, len(cards)-1):
            if getValue(cards[i+1]) != getValue(cards[i]) + 1:
                oppColour =  getOppositeColour(getColour(cards[i]))
                if(wild_colours[oppColour] > 0):    
                    wild_colours[oppColour] -= 1
                    cards.insert(i+1, str(getValue(cards[i]) + 1) + getCardFromColour(oppColour))
                    continue;
    return cards

def getValue(card):
    card_vals = {'0': '10', '1': '1', '2': '2', '3': '3', '4': '4', '5': '5', '6': '6', '7': '7', '8': '8', '9': '9',
             '10': '10', 'J': '11', 'Q': '12', 'K': '13', 'A': '20'}
    return int(card_vals[card[0]])

def getOppositeColour(colour):
    if(colour=="R"):
        return "B"
    else:
        return "R"

def getCardFromColour(colour):
    if(colour == "R"):
        return "H"
    else:
        return "C"

def getColour(card):  
    if(card[1] == "H" or card[1] == "D"):
        # print(card +" is RED")
        return "R"
    else:
        # print(card + " is BLACK")
        return "B"


#       Get score for N-of-kind
def getNoKScore(cards, cardValue):
    count = 0
    for c in cards:
        if(getValue(c) == cardValue):
            count+=1
    return int(cardValue) * math.factorial(count)

# cards = ['3C', '4H', 'AS']
# print(comp10001go_score_group(cards))

def isValidGroup(cards_original) :
    card_suits = ['H', 'D', 'S', 'C']
    card_nums = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']

    cards_original.sort()

    # is N-of-a-kind?
    val_to_check = getValue(cards_original[0])
    is_n_o_k = True
    for c in cards_original:
        if getValue(c) != val_to_check or c[0] == "A":
            # not n of a kind
            is_n_o_k = False
        else :
            # is n of a kind
            is_n_o_k = True

    # is it a run?
    # split up wilds and cards
    wilds = [c for c in cards_original if c[0] == "A"]    
    cards = [c for c in cards_original if c[0] != "A"]

    # cards.sort()
    cards = useWildCards(cards, wilds)
    # cards.sort()
    print(cards)

    isRun = True
    for i in range(0, len(cards)-1):
        if(getValue(cards[i+1]) != getValue(cards[i]) + 1 or getColour(cards[i+1]) == getColour(cards[i])):
            isRun = False

    if(len(cards_original) < 3 or len(cards) < 3):
        isRun = False
        if(len(cards_original)<2):
            is_n_o_k = False

    if(is_n_o_k):
        return True
    elif(isRun):
        return True
    elif(len(cards_original)<=1):
        return True
    else:
        return False

def comp10001go_valid_groups(groups):
    for g in groups:
        if(isValidGroup(g) == False):
            return False
    return True

groups = [['AC']]
print(comp10001go_valid_groups(groups))