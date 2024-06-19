import 'dart:convert';

import 'package:google_map/ui/destination.dart';
import 'package:http/http.dart' as http;

class RequestAssistant {

  
  static Future<dynamic> reciveRequest(String url) async {
    http.Response httpResponse = await http.get(Uri.parse(url));
    try {
      if (httpResponse.statusCode == 200) {
        String responseData = httpResponse.body;
        var decodeResponseData = jsonDecode(responseData);
        return decodeResponseData;
      } else {
        return "Error occurd. Failed .No Response";
      }
    } catch (e) {
      return "Error occurd. Failed .No Response";
    }
  }

static const deviceRegistrationToken="fRH9MoLRRZKk8wwrtyqR9n:APA91bE7CCSGdbRG956CYplZgKNixKnXNihhLrI5Ch9vbqk9jcACJ_zaaTYqUyC9sj9omMnK9d91SSN9wfJmLU1dSqUfRfXKTwv_xcZyb1R1BahIsy8_WPU2YK3llLPgPNj3qZOASXYL";
static const userRidRequestid="1";
static sendnotificationfordriver(String deviceRegistrationToken, String userRidRequestid,context) async{
String key="key=nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCawNIJ09rtRUV4\n65LoqKOwJWPgzKtbB2O+Dr1if4XwUipoyBkPu7oiaKqCkyjyCWf7KJ0/TtwjL13y\nPrnkrvLbkgCykPx/I0iERLqJBkEeTlTPVSBpdlt+vPlLuVaPJOhmEP+YXku7Buei\nm/vO89rweHAn0LSE+R/qg54z1/13/CMb8Epatw5JQ50FW5WFwvy2tiL42MIuRzvy\nH4nJVFB4mBVORUScr6ZRM60XI8goeMIYilnslZpfHJKkUIj8btkAwuphe4iyGNKz\nOJL8exmIu2WuW3f6aL6IDW85jQazpralmP0chln5jC/RxT313Vk2TY7ULtmjZW/O\ncdbn8TL/AgMBAAECggEAJZt/T5kXBntDl0+0a2r0II3tmEdUyzHgCON/Ha086Pqm\nyMD76ilmYg9KhKHrnOoxRUWI9UYeVESiEYkx1sO3TCnOlpaKbgEukco8BKmq8Ij7\nrkkTL93t/T5CXSckxHOlMIyn+KjNwZ07dHZwusnjJnY2V06uV/RMz8p9iz7Nn7cb\nEFqLSIAmG7bafENhUEBvT0OSA03AJ4i2hWPPOuAkbmTQcKK3n7Ruk/sRHgKflGCA\n8IK2oSgOVMXSMfE+UL+IkLJulFJ6sggPtclsrs0lAU8IJRmU5VioFGXJhWabtoa8\nc+0OGAqynX8YGXnqLZn2AFSO76UvoInNYzIIHx6aeQKBgQDS17gnB2U7eBkmiSB3\nVp6Ss1bIoI5J4dV946ZXuGo2ciZkx0P+em0cAAWbmr6WeYK28suDpoWPFsk7Yr4q\n0erxZRSkoElsEd6KaFpbmvup2xuyBf3/smR1avcdsuuUqGNSRYbTXPom52RcC0DF\nNQuLnVExQaVFxPtbW/KCIzC4hwKBgQC75caVB/VhkB+qgaJHUKLZlicU/QDaN0LY\nmc/tlqq70NmX8Xevjiu1/br0NMhP3LCZdwlUNtyj382PDV95Uq2cfcqfTlTGV2KL\nIUI8fRt+AkCDZNPF+8DpzYxFBHZuGIA5T5Q9hHrJ/C3kwZ9sz2FVMypEo3w9b6ih\n5abT1n5nyQKBgQCO0A1takX4pR2sC4ARNXvNdGpZFN+sTarVTaizjDdtT56P7qUw\nru5O4/jocEWeGQogL48ISnf29wExF24mBPA1uDjmVafF6sipSYvCttS2NbKpwANO\n+h+vpNdjp3iIxhIYfP2ZF0ZdqahB7GFf8tEyLUn8qjFvc8CqHjrCSWHL6wKBgGLO\nltnB4KCYaH6CQvLbjXd8RTr9PJiD3MwIPlZDF69CSVpkaTrROV0ve0N2Ciws8lUR\nSr+VRfuK8g6ayq0C9DbJ02Zoi53tT+235Jvoci+WQZSWzeJb2/tW0r9sdFa63ZrF\npT+gTe2vhfa4dvyCJT3ndP+5NNkdwYC5Qjw9nCU5AoGBAJJZuiNV9ZY7ZbyYk7e4\nXnNhvJHWMAknXvd4boaSzWGHxZPiyYvF/AX+DoPp3y0YbyiQRfOaci+kMbgp49WP\nNdipnjIoi46YTRafX7BZ/OjLwIFSJHFm0B/8KygEdYyI3ar+8GHrkvGIs5Yc0SKw\neDCD7kk4s2e4YIG6tjx8Tb2+";
String destinationaddress="";
Map<String,String> notification={
  "Content-type":"Application/json",
  "Authorization":key,
};
Map bodynotification={
  "body":"Destination Address:",
  "title":"New Trip Request"
};

Map dataMap={
  "click_action":"FLUTTER_NOTIFICATION_CLICK",
   "id":"1",
   "status":"done",
   "rideRequsest":userRidRequestid
};

Map officalNotificationFormat={
  "notification":bodynotification,
  "data":dataMap,
  "priority":"high",
  "to":deviceRegistrationToken,
};

var responseNotification=http.post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
headers: notification,
body: jsonEncode(officalNotificationFormat),
);

}

}
