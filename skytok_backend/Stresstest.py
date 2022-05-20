import requests
import random
import string
import datetime

#Create a random string
def randomString(stringLength=20):
    letters = string.ascii_lowercase
    return ''.join(random.choice(letters) for i in range(stringLength))

host = 'http://localhost'
createVideoUrl = host + '/videos/create'
likeVideoUrl = host + '/videos/userLikedVideo'
getUserVideos = host + '/videos/getVideosForUserByTags'
createVideoObj = {'path': 'bfwjbfjwf',
        'length': '120',
        'user_id': '1',
        'descryption': 'test #' + randomString() + ' #' + randomString() + ' #' + randomString() + ' #' + randomString() + ' #' + randomString()}
getUserVideosObj = {'userId': '1'}
# Start time
startTime = datetime.datetime.now()
#Loop 100 times
for i in range(10000):
    createVideoObj['descryption'] = 'test #' + randomString() + ' #' + randomString() + ' #' + randomString()

    x = requests.post(createVideoUrl, data = createVideoObj)
    # Get id from response
    responeJson = x.json()
    videoId = responeJson[0]['id']
    likeVideoObj = {'videoId': videoId, 'userId': '1'}
    y = requests.post(likeVideoUrl, data = likeVideoObj)
    z = requests.post(getUserVideos, data = getUserVideosObj)
    # print(z.text)
    endTime = datetime.datetime.now()
    print("Index: " + str(i) + " took: " + str(endTime - startTime))


print(x.text)