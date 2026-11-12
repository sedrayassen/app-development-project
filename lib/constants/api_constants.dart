
class ApiConstants {
  static const String baseUrl =
      'https://456f-46-58-191-219.ngrok-free.app/api/v1/';

  static const String login = 'auth/login';
    static const String logout = 'auth/logout';
  static const String categories = 'categories';
  static const String products = 'products';
  static const String orders = 'orders';
  static const String createOrder = 'orders';

  static String orderDetails(int id) => 'orders/$id';

  static String productDetails(int id) => 'products/$id';
  static const String notifications = 'notifications';

  static String fixImageUrl(String url) {
    final u = Uri.tryParse(url);
    if (u == null) return url;
    const localHosts = {'localhost', '127.0.0.1', '10.0.2.2'};
    if (!localHosts.contains(u.host)) return url;

    final b = Uri.parse(baseUrl);
    return Uri(
      scheme: b.scheme,
      host: b.host,
      port: b.hasPort ? b.port : null,
      path: u.path,
      query: u.hasQuery ? u.query : null,
    ).toString();
  }
}