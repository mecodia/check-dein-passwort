import json

passwordList =[]
with open("10-million-combos.txt", "r") as password_file:

    for idx,line in enumerate(password_file):

        if idx > 50000:
            break
        lines = line.split()
        try:
            passs = lines[1]
        except:
            passs = lines[0]
        passwordList.append(passs.decode('cp1252').encode('utf-8'))

with open("common.coffee","w") as passwords:
    passwords.write("module.exports.passwords.common = ")
    json.dump(passwordList,passwords)
