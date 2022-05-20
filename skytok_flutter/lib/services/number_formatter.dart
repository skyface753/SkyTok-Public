class NumberFormatter {
  // 1000 -> 1k
  // 1000000 -> 1m
  // 1000000000 -> 1b
  // 1000000000000 -> 1t

  static String format(int number) {
    if (number < 1000) {
      return number.toString();
    }
    if (number < 1000000) {
      return (number / 1000).toStringAsFixed(0) + "K";
    }
    if (number < 1000000000) {
      return (number / 1000000).toStringAsFixed(1) + "M";
    }
    if (number < 1000000000000) {
      return (number / 1000000000).toStringAsFixed(1) + "B";
    }
    return (number / 1000000000000).toStringAsFixed(1) + "T";
  }
}
