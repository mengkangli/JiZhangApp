import 'package:flutter/material.dart';

class AppIconData {
  const AppIconData._();

  static IconData fromCodePoint(int codePoint) {
    return _materialIcons[codePoint] ?? Icons.category_rounded;
  }

  static const Map<int, IconData> _materialIcons = {
    0xe02c: Icons.six_k_plus,
    0xe043: Icons.account_circle,
    0xe04b: Icons.add_box,
    0xe050: Icons.add_circle_outline,
    0xe059: Icons.add_road,
    0xe0af: Icons.atm,
    0xe0be: Icons.auto_graph,
    0xe0cf: Icons.bathtub,
    0xe0f2: Icons.bookmark_add,
    0xe0f8: Icons.border_bottom,
    0xe16d: Icons.closed_caption_disabled,
    0xe1e1: Icons.directions_walk,
    0xe227: Icons.electric_scooter,
    0xe234: Icons.engineering,
    0xe30a: Icons.help_center,
    0xe30d: Icons.hide_image,
    0xe31b: Icons.home_mini,
    0xe321: Icons.hot_tub,
    0xe323: Icons.hourglass_bottom,
    0xe328: Icons.house,
    0xe32a: Icons.houseboat,
    0xe3b0: Icons.lock_open,
    0xe3b3: Icons.logout,
    0xe3d9: Icons.medication,
    0xe422: Icons.nearby_off,
    0xe4a3: Icons.phone_android,
    0xe531: Icons.restart_alt,
    0xe53a: Icons.roofing,
    0xe548: Icons.rule_folder,
    0xe54e: Icons.sanitizer,
    0xe54f: Icons.satellite,
    0xe552: Icons.saved_search,
    0xe553: Icons.savings,
    0xe561: Icons.screen_share,
    0xe565: Icons.sd_card_alert,
    0xe578: Icons.sentiment_dissatisfied,
    0xe57a: Icons.sentiment_satisfied,
    0xe5d2: Icons.sort,
    0xe5d3: Icons.sort_by_alpha,
    0xe627: Icons.swap_vert,
    0xe751: Icons.add_link_sharp,
    0xe7ec: Icons.book_online_sharp,
    0xe7f1: Icons.bookmark_remove_sharp,
    0xe80c: Icons.brightness_medium_sharp,
    0xe80e: Icons.browser_not_supported_sharp,
    0xe8b0: Icons.data_saver_off_sharp,
    0xe8b8: Icons.delete_sharp,
  };
}
