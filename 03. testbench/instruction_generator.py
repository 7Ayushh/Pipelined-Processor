print("Enter your Assembly Code:")
instructions = input()
instruction = instructions.split()
hexcode = []
for i in range(len(instruction)):
    if (instruction[i] == 'ADD'):
        hexcode.append('0000' + instruction[i + 1] + instruction[i + 2] + instruction[i + 3] + '000')
    elif (instruction[i] == 'ADC'):
        hexcode.append('0000' + instruction[i + 1] + instruction[i + 2] + instruction[i + 3] + '010')
    elif (instruction[i] == 'ADZ'):
        hexcode.append('0000' + instruction[i + 1] + instruction[i + 2] + instruction[i + 3] + '001')
    elif (instruction[i] == 'ADI'):
        hexcode.append('0001' + instruction[i + 1] + instruction[i + 2] + instruction[i + 3])
    elif (instruction[i] == 'ADI'):
        hexcode.append('0001' + instruction[i + 1] + instruction[i + 2] + instruction[i + 3])
    elif (instruction[i] == 'NDU'):
        hexcode.append('0010' + instruction[i + 1] + instruction[i + 2] + instruction[i + 3] + '000')
    elif (instruction[i] == 'NDC'):
        hexcode.append('0010' + instruction[i + 1] + instruction[i + 2] + instruction[i + 3] + '010')
    elif (instruction[i] == 'NDZ'):
        hexcode.append('0010' + instruction[i + 1] + instruction[i + 2] + instruction[i + 3] + '001')
    elif (instruction[i] == 'LHI'):
        hexcode.append('0011' + instruction[i + 1] + instruction[i + 2])
    elif (instruction[i] == 'LW'):
        hexcode.append('0100' + instruction[i + 1] + instruction[i + 2] + instruction[i + 3])
    elif (instruction[i] == 'SW'):
        hexcode.append('0101' + instruction[i + 1] + instruction[i + 2] + instruction[i + 3])
    elif (instruction[i] == 'LM'):
        hexcode.append('0110' + instruction[i + 1] + '0' + instruction[i + 2])
    elif (instruction[i] == 'SM'):
        hexcode.append('0111' + instruction[i + 1] + '0' + instruction[i + 2])
    elif (instruction[i] == 'BEQ'):
        hexcode.append('1100' + instruction[i + 1] + instruction[i + 2] + instruction[i + 3])
    elif (instruction[i] == 'JAL'):
        hexcode.append('1000' + instruction[i + 1] + instruction[i + 2])
    elif (instruction[i] == 'JLR'):
        hexcode.append('1001' + instruction[i + 1] + instruction[i + 2] + '000000')

inst_set = open(r"rom_init.txt", "w")

for k in range(len(hexcode)):
    inst_set.write(str(hexcode[k]) + '\n')

for j in range(256 - len(hexcode)):
    if j != (255 - len(hexcode)):
        inst_set.write(str("1111111111111111") + '\n')
    else:
        inst_set.write(str("1111111111111111"))

#   print('memory(' + str(len(hexcode) * i + k) + ')<="' + str(hexcode[k]) + '";')
