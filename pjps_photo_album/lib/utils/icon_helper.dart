import 'package:flutter/material.dart';

class IconHelper {
  static const String basePath = 'assets/icons/';

  // App icons
  static const String appIcon = '${basePath}app_icon.png';
  static const String appIconAndroid = '${basePath}app_icon_android.png';
  static const String appIconIos = '${basePath}app_icon_ios.png';

  // Tab icons
  static const String tabAlbums = '${basePath}tab_albums.png';
  static const String tabStaff = '${basePath}tab_staff.png';
  static const String tabRemarks = '${basePath}tab_remarks.png';
  static const String tabProfile = '${basePath}tab_profile.png';

  // Feature icons
  static const String student = '${basePath}icon_student.png';
  static const String teacher = '${basePath}icon_teacher.png';
  static const String classIcon = '${basePath}icon_class.png';
  static const String camera = '${basePath}icon_camera.png';
  static const String gallery = '${basePath}icon_gallery.png';
  static const String fingerprint = '${basePath}icon_fingerprint.png';
  static const String sync = '${basePath}icon_sync.png';
  static const String download = '${basePath}icon_download.png';
  static const String upload = '${basePath}icon_upload.png';

  // Action icons
  static const String search = '${basePath}icon_search.png';
  static const String filter = '${basePath}icon_filter.png';
  static const String sort = '${basePath}icon_sort.png';
  static const String share = '${basePath}icon_share.png';
  static const String delete = '${basePath}icon_delete.png';
  static const String edit = '${basePath}icon_edit.png';
  static const String add = '${basePath}icon_add.png';
  static const String remove = '${basePath}icon_remove.png';
  static const String check = '${basePath}icon_check.png';
  static const String close = '${basePath}icon_close.png';
  static const String menu = '${basePath}icon_menu.png';
  static const String back = '${basePath}icon_back.png';
  static const String forward = '${basePath}icon_forward.png';
  static const String refresh = '${basePath}icon_refresh.png';
  static const String settings = '${basePath}icon_settings.png';
  static const String help = '${basePath}icon_help.png';
  static const String info = '${basePath}icon_info.png';

  // Status icons
  static const String warning = '${basePath}icon_warning.png';
  static const String error = '${basePath}icon_error.png';
  static const String success = '${basePath}icon_success.png';

  // Connectivity icons
  static const String offline = '${basePath}icon_offline.png';
  static const String online = '${basePath}icon_online.png';
  static const String wifi = '${basePath}icon_wifi.png';
  static const String noWifi = '${basePath}icon_no_wifi.png';

  static Image getIcon(String path, {double size = 24, Color? color}) {
    return Image.asset(
      path,
      width: size,
      height: size,
      color: color,
    );
  }

  static Image getStudentIcon({double size = 24, Color? color}) {
    return getIcon(student, size: size, color: color);
  }

  static Image getTeacherIcon({double size = 24, Color? color}) {
    return getIcon(teacher, size: size, color: color);
  }

  static Image getFingerprintIcon({double size = 24, Color? color}) {
    return getIcon(fingerprint, size: size, color: color);
  }
}
