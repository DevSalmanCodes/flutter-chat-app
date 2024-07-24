import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Function to format the Firestore timestamp into a readable string
String formatDate(Timestamp timestamp) {
  DateTime now = DateTime.now();
  DateTime dateTime = timestamp.toDate();
  Duration diff = now.difference(dateTime);

  if (diff.inDays == 0 && now.day == dateTime.day) {
    return 'Today';
  } else if (diff.inDays == 1 && now.day - dateTime.day == 1) {
    return 'Yesterday';
  } else {
    return DateFormat.yMMMd().format(dateTime);
  }
}



String formatDateTime(DateTime dateTime) {
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  return formatter.format(dateTime);
}
