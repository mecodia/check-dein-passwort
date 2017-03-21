import json

password_list =[]
with open("10-million-combos.txt", "r") as password_file:

    for idx,line in enumerate(password_file):

        if idx > 50000:
            break
        lines = line.split()
        try:
            password = lines[1]
        except:
            password = lines[0]
        password_list.append(password.decode('cp1252').encode('utf-8'))

with open("common.coffee","w") as passwords:
    passwords.write("module.exports.passwords.common = ")
    json.dump(password_list,passwords)
