//class AppConstants {
// static const String appName = 'PJPS Photo Album';

// IMPORTANT: Change this to your computer's IP address
// Find your IP:
// Windows: ipconfig (look for IPv4 Address)
// Mac: ifconfig | grep inet
// Linux: hostname -I
//  static const String apiBaseUrl =
//      'http://192.168.1.100:8000/api'; // CHANGE THIS!

// Storage Keys
//  static const String accessTokenKey = 'access_token';
//  static const String refreshTokenKey = 'refresh_token';
//  static const String userKey = 'user';

// Pagination
//  static const int pageSize = 20;
//}

class AppConstants {
  static const String appName = 'PJPS Photo Album';

// Backend URLs
  // static const String devUrl = 'http://YOUR_CURRENT_IP:8000/api';
  static const String devUrl = 'http://10.178.161.217:8000/api';
//static const String devUrl = 'http://YOUR_CURRENT_IP:8000/api';
  //final baseUrl = 'http://192.168.137.1:8000/api/';
  static const String prodUrl = 'https://api.pjps.com/api';

// Current API base URL (switch between devUrl and prodUrl when needed)
  static const String apiBaseUrl = devUrl;

// Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user';

// Pagination
  static const int pageSize = 20;
}
