class BloodGroupHelper {
  static String formatDisplay(String bloodGroup) {
    return bloodGroup.replaceAll('_POSITIVE', '+').replaceAll('_NEGATIVE', '-').replaceAll('_', '');
  }
}
