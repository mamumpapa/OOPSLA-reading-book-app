import numpy as np
import cv2
import math
from matplotlib import pyplot as plt
import platform
from PIL import ImageFont, ImageDraw, Image
import uuid
import json
import time
import requests

def line(path):
    ff=np.fromfile(path, np.uint8)
    src = cv2.imdecode(ff, cv2.IMREAD_COLOR)
    src=cv2.resize(src,(1440,810))


    dst = src.copy()
    gray = cv2.cvtColor(src, cv2.COLOR_BGR2GRAY)
    canny = cv2.Canny(gray, 5000, 1500, apertureSize=5, L2gradient=True)
    lines = cv2.HoughLines(canny, 0.8, np.pi / 180, 150, srn=100, stn=200, min_theta=0, max_theta=np.pi)
    line_arr = []

    for i in lines:
        rho, theta = i[0][0], i[0][1]
        a, b = np.cos(theta), np.sin(theta)
        x0, y0 = a * rho, b * rho

        scale = src.shape[0]

        x1 = int(x0 + scale * -b)
        y1 = int(y0 + scale * a)
        x2 = int(x0 - scale * -b)
        y2 = int(y0 - scale * a)

        rad = math.atan2(y2 - y1, x2 - x1)
        PI = math.pi
        deg = (rad * 180) / PI

        if abs(deg) > 75 and abs(deg) <= 90:
            print(rho, theta)
            print(x0, y0)
            print(x1,y1,x2,y2)
            x_arr = np.array([x1, x2])
            y_arr = np.array([y1, y2])
            arr = np.clip(x_arr, 0, 1440)
            arr2 = np.clip(y_arr, 0, 1080)

            cut_x = int((arr[0] + arr[1]) / 2)
            cut_y = arr2[0]
            cut_x2 = int((arr[0] + arr[1]) / 2)
            cut_y2 = arr2[1]

            cv2.line(dst, (x1, y1), (x2, y2), (0, 0, 255), 2)
            line_arr.append([cut_x, cut_y, cut_x2, cut_y2])

    line_arr.sort()

    line_near = []
    x_m = (line_arr[0][0] + line_arr[-1][0]) / 2
    for i in range(len(line_arr)):
        line_near.append(line_arr[:][i][0])


    x_m = min(line_near, key=lambda x: abs(x - x_m))
    dst1 = src[0:1080, line_arr[0][0]:x_m + 20].copy()
    dst2 = src[0:1080, x_m:line_arr[-1][0]].copy()

    cv2.imwrite("images/save.jpg", dst1)
    cv2.imwrite("images/save2.jpg", dst2)
    plt.imshow(dst)
    plt.show()
    cv2.imshow("save1", dst1)
    cv2.imshow("save2", dst2)
    cv2.waitKey(0)

    path = 'images/save.jpg'
    files = [('file', open(path, 'rb'))]

    api_url = 'https://dge2cmianc.apigw.ntruss.com/custom/v1/18970/93b43f62fe16540c90630a63f9d08bd7b5399ea2cdf379e1452be747389ef780/general'
    secret_key = 'UFN6ZkRtRm5DdUNwc2xyaWNWRmtqeGNub1pLREF6a2w='

    request_json = {'images': [{'format': 'jpg',
                                'name': 'demo'
                                }],
                    'requestId': str(uuid.uuid4()),
                    'version': 'V2',
                    'timestamp': int(round(time.time() * 1000))
                    }

    payload = {'message': json.dumps(request_json).encode('UTF-8')}

    headers = {
        'X-OCR-SECRET': secret_key,
    }

    response = requests.request("POST", api_url, headers=headers, data=payload, files=files)
    result = response.json()

    text_field=''
    for field in result['images'][0]['fields']:
        text = field['inferText']
        text_field+=text+" "

    path2 = 'images/save2.jpg'
    files2 = [('file', open(path2, 'rb'))]
    api_url = 'https://dge2cmianc.apigw.ntruss.com/custom/v1/18970/93b43f62fe16540c90630a63f9d08bd7b5399ea2cdf379e1452be747389ef780/general'
    secret_key = 'UFN6ZkRtRm5DdUNwc2xyaWNWRmtqeGNub1pLREF6a2w='

    request_json = {'images': [{'format': 'jpg',
                                'name': 'demo'
                                }],
                    'requestId': str(uuid.uuid4()),
                    'version': 'V2',
                    'timestamp': int(round(time.time() * 1000))
                    }

    payload = {'message': json.dumps(request_json).encode('UTF-8')}

    headers = {
        'X-OCR-SECRET': secret_key,
    }

    response2 = requests.request("POST", api_url, headers=headers, data=payload, files=files2)
    result2 = response2.json()

    text_field2=''
    for field2 in result2['images'][0]['fields']:
        text = field2['inferText']
        text_field2+=text+" "

    return text_field, text_field2

img_path="images/app_test.jpg"
img_to_text=[]
img_to_text2=[]
img_to_text, img_to_text2=line(img_path)
print(img_to_text)
print(img_to_text2)
