from socket import *
import os
import sys

clientSock = socket(AF_INET, SOCK_STREAM)
clientSock.connect(('220.69.208.115', 8080))

print('연결에 성공했습니다.')
filename = 'OIP.jfif'
clientSock.sendall(filename.encode('utf-8'))

data = clientSock.recv(1024)
data_transferred = 0

if not data:
    print('파일 %s 가 서버에 존재하지 않음' %filename)
    sys.exit()

nowdir = os.getcwd()
with open(nowdir+"\\"+filename, 'wb') as f:
    try:
        while data: #데이터가 있을 때까지
            f.write(data) #1024바이트 쓴다
            data_transferred += len(data)
            data = clientSock.recv(1024) #1024바이트를 받아 온다
    except Exception as ex:
        print(ex)
print('파일 %s 받기 완료. 전송량 %d' %(filename, data_transferred))