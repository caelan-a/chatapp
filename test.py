import math


def comp10001go_score_group(cards):
    card_suits = ['HS', 'HC', 'DS', 'DC', 'CD', 'CH', 'SH', 'SD']
    card_nums = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
    card_vals = {'0': '10', '1': '1', '2': '2', '3': '3', '4': '4', '5': '5', '6': '6', '7': '7', '8': '8', '9': '9',
                 '10': '10', 'J': '11', 'Q': '12', 'K': '13', 'A': '20'}
    num1 = cards[0][0]
    value = 0
    mnum = 0
    suite1 = cards[0][1]
    count = 0
    cards.sort()
    card_f = [x[0] for x in cards]
    card_v = []
    ble = 0
    for i in range(len(cards) - 1):
        card_v.append(cards[i][1] + cards[i + 1][1])
    for i in range(len(cards)):
        if cards[i].count(num1) == True:
            count += 1
    if len(cards) == 1:
        value = int(-1) * int(num1)
    elif len(cards) < 3 and count != len(cards):
        for i in range(len(cards)):
            value += int(card_vals[card_f[i]])
        value = int(-1) * value
    elif count == len(cards):
        value = int(card_vals[num1]) * math.factorial(len(cards))
    else:
        for i in range(len(card_f)):
            value += int(card_vals[cards[i][0]])
        for i in range(len(card_f)):
            if card_f[i] == card_nums[card_nums.index(card_f[0]) + i]:
                for j in range(len(card_v)):
                    if card_v[j] not in card_suits:
                        value = int(-1) * value
                        break
                    else:
                        value = value
            elif card_f[i] == 'A':
                value = 0
                for i in range(len(card_f) - 1):
                    if card_nums.index(card_f[i + 1]) - card_nums.index(card_f[i]) == 2:
                        mnum = (int(card_f[i]) + int(card_f[i + 1])) / 2
                        card_vals['A'] = int(mnum)
                        for i in range(len(card_f)):
                            value += int(card_vals[card_f[i]])
                            if cards[i][0]=='A':
                                suite = cards[i][1]
                                cards.pop(i)
                        cards.append(str(card_vals['A'])+str(suite))
                        cards.sort()
                        card_v.clear()
                        for i in range(len(cards) - 1):
                            card_v.append(cards[i][1] + cards[i + 1][1])   
                        for j in range(len(card_v)):
                            if card_v[j] not in card_suits:
                                card_vals['A']=20
                                value += int(card_vals[card_f[i]])
                                ble = abs(value) *-1
                            else:
                                value = value
                        break
                    else:
                        for i in range(len(card_f)):
                            value = value + int(card_vals[card_f[i]])
                        value = int(-1) * value
                        break
            else:
                value = 0
                for i in range(len(card_f)):
                    value = value + int(card_vals[card_f[i]])
                value = int(-1) * value
    if ble==0:
        return value
    else:
        return ble


# vowel list
vowel = ['a', 'e', 'i', 'u']

# inserting element to list at 4th position
vowel.insert(3, 'o')

print('Updated List: ', vowel)