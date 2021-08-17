import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'alertX.dart';
import 'navigationX.dart';

typedef NotificationHandler = void Function(RemoteMessage?);

Future<void> _firebaseMessagingBackgroundHandler(message) async {
  await Firebase.initializeApp();
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  'This channel is used for important notifications.',
  importance: Importance.high,
  enableVibration: true,
  playSound: true,
);

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class FirebaseX{
  FirebaseX._();
  static final FirebaseX instance = FirebaseX._();

  FirebaseAuth auth = FirebaseAuth.instance;
  String verificationId = "";
  late String mobileNumber;
  int resendToken = 0;
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  Future<void> signInWithEmail(String email, String password, Function onSuccess, Function onError) async{
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      onSuccess();
    } on FirebaseAuthException catch  (e) {
      print('Failed with error code: ${e.code}');
      AlertX.instance.showAlert(
          title: "Error",
          msg: e.message ?? "",
          negativeButtonText: null,
          positiveButtonText: "Done",
          negativeButtonPressed: (){},
          positiveButtonPressed: (){
            Navigation.instance.goBack();
          }
      );
      onError();
    }
  }

  Future<void> handleSignIn(PhoneAuthCredential credential, Function onSuccess, Function onError) async{
    await auth.signInWithCredential(credential).then((value) {
      onSuccess();
    }).catchError((error){
      AlertX.instance.showAlert(
          title: "Error",
          msg: error.message ?? "",
          negativeButtonText: null,
          positiveButtonText: "Done",
          negativeButtonPressed: (){},
          positiveButtonPressed: (){
            Navigation.instance.goBack();
          }
      );
      onError();
    });
  }

  Future<void> sendOtp({required String phoneNumber, required Function onCodeSent, required Function onSuccess, required Function onError}) async{
    mobileNumber = phoneNumber;
    await auth.verifyPhoneNumber(
      phoneNumber: mobileNumber,
      forceResendingToken: resendToken,
      timeout: Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        handleSignIn(credential, onSuccess, (){});
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          AlertX.instance.showAlert(
              title: "Invalid phone number",
              msg: "The provided phone number is not valid.",
              negativeButtonText: null,
              positiveButtonText: "Done",
              negativeButtonPressed: (){},
              positiveButtonPressed: (){
                Navigation.instance.goBack();
              }
          );
        }else{
          AlertX.instance.showAlert(
              title: "Error",
              msg: e.message ?? "",
              negativeButtonText: null,
              positiveButtonText: "Done",
              negativeButtonPressed: (){},
              positiveButtonPressed: (){
                Navigation.instance.goBack();
              }
          );
        }
        onError();
      },
      codeSent: (String id, [int? code]){
        verificationId = id;
        resendToken = code ?? 0;
        onCodeSent();
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  void verifyOtp({required String otp, required Function onSuccess, required Function onError}) {
    handleSignIn(PhoneAuthProvider.credential(verificationId: verificationId, smsCode: otp),onSuccess, onError);
  }

  void onResendOtp({required Function onSuccess, required Function onError}){
    sendOtp(phoneNumber: mobileNumber, onCodeSent: (){}, onSuccess: onSuccess, onError: onError);
  }

  void onUpdatePhoneNumber({required String otp, required Function onSuccess, required Function onError}){
    final PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: otp);
    FirebaseAuth.instance.currentUser?.updatePhoneNumber(credential).then((value) {
      onSuccess();
    }).catchError((error){
      onError();
    });
  }

  onRegisterFirebaseNotificationTopics(List<String> topics){
    for(var topic in topics){
      firebaseMessaging.subscribeToTopic(topic);
    }
  }

  Future<void> onFirebaseNotificationReceived() async{
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                icon: 'ic_launcher',
              ),
            ));
      }
    });
  }

  ///when app in background
  void onClickedInBackground(NotificationHandler onClicked) {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      onClicked(message);
    });
  }

  Future<void> onFirebaseMessagingInitialize({required  NotificationHandler onFirebaseNotificationClickedInBackground}) async{
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await  FirebaseMessaging.instance.requestPermission(alert: true,badge: true,sound: true);
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    onFirebaseNotificationReceived();
    onClickedInBackground(onFirebaseNotificationClickedInBackground);
  }

  Future<void> onFirebaseNotificationClicked({required NotificationHandler onClicked}) async{
    RemoteMessage? message = await FirebaseMessaging.instance.getInitialMessage();
    if(message != null){
      ///when app is terminated
      onClicked(message);
    }
  }


}