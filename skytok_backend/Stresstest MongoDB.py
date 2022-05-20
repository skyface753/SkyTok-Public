import requests
import random
import string
import datetime

#Create a random string
def randomString(stringLength=20):
    letters = string.ascii_lowercase
    return ''.join(random.choice(letters) for i in range(stringLength))

host = 'http://localhost'
shareVideoUrl = host + '/videos/shareVideo'
shareVideoObj = {'video_id': '14'}
#Loop 100 times
for i in range(100000):

    # Start time
    startTime = datetime.datetime.now()
    x = requests.post(shareVideoUrl, data = shareVideoObj)
    # print(x.text)
    endTime = datetime.datetime.now()
    # Duration in miliseconds
    duration = (endTime - startTime).microseconds / 1000
    print("Index: " + str(i) + " took: " + str(duration))


print(x.text)