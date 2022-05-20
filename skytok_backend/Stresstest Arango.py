from pyArango.connection import *
import random
import string
import datetime

conn = Connection(arangoURL='http://node-intel:8529', username="root", password="root_passwd")
db = conn['SkyTok']
users = db['users']

# Create a random string
def randomString(stringLength=10):
    letters = string.ascii_lowercase
    return ''.join(random.choice(letters) for i in range(stringLength))


# Loop 100 times
for i in range(100000):
    startTime = datetime.datetime.now()
    user1 = users.createDocument()
    user1['username'] = randomString()
    user1['password'] = '123456'
    user1['mail'] = randomString() + '@gmail.com'
    user1.save()
    endTime = datetime.datetime.now()
    # Duration in miliseconds
    duration = (endTime - startTime).microseconds / 1000
    print("Index: " + str(i) + " took: " + str(duration))