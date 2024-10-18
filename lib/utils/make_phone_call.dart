import 'package:url_launcher/url_launcher.dart';

void makePhoneCall(String number) async {
  final Uri phoneUri = Uri(scheme: 'tel', path: number);
  if (await canLaunchUrl(phoneUri)) {
    await launchUrl(phoneUri);
  } else {
    throw 'Could not launch $number';
  }
}
