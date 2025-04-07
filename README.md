## 블루투스 설정

AT+BLEINIT=1
AT+BLEADDR?
AT+BLEUUID=0xFFE0
AT+BLECHAR=0xFFE1

## ios인 경우

<key>NSBluetoothAlwaysUsageDescription</key>
<string>블루투스 연결 필요</string>
