import requests
import random
import string
import datetime


host = 'http://localhost'
shareVideoUrl = host + '/comments/create'
shareVideoObj = {'video_id': '33229', 'comment': 'This is a test comment'}
headerAuth = {'authorization': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSIsImlhdCI6MTY0NjI0Njk1OSwiZXhwIjoxNjQ4ODM4OTU5fQ.4_81XxmUJlum6HuD3qCAa6b46mcvjo7EhE2Dh12dRog'}
#Loop 100 times
for i in range(100000):

    # Start time
    startTime = datetime.datetime.now()
    x = requests.post(shareVideoUrl, data = shareVideoObj, headers = headerAuth)
    # print(x.text)
    endTime = datetime.datetime.now()
    # Duration in miliseconds
    duration = (endTime - startTime).microseconds / 1000
    print("Index: " + str(i) + " took: " + str(duration))


print(x.text)