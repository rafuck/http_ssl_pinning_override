import 'dart:async';
import 'dart:io';

import 'package:http_proxy_override/http_proxy_override.dart';

class HttpSslPinningOverride extends HttpOverrides {
  late final HttpProxyOverride? _proxyOverride;
  late final bool _isSslPinning;
  late final bool _ignoreSslErrors;

  final SecurityContext _securityContext = SecurityContext();
  HttpSslPinningOverride._(List<List<int>>? certs, this._ignoreSslErrors) {
    if (certs == null || certs.isEmpty) {
      _isSslPinning = false;
      return;
    }
    _isSslPinning = true;
    for (final cert in certs) {
      _securityContext.setTrustedCertificatesBytes(cert);
    }
  }

  static Future<HttpSslPinningOverride> createSslPinning({
    bool useSystemProxy = false,
    bool ignoreSslErrors = false,
    List<List<int>>? certs,
  }) async {
    return HttpSslPinningOverride._(certs, ignoreSslErrors)
      .._proxyOverride =
          ((useSystemProxy) ? await HttpProxyOverride.createHttpProxy() : null);
  }

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client =
        super.createHttpClient(_isSslPinning ? _securityContext : context);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
      return _ignoreSslErrors;
    };
    return client;
  }

  @override
  String findProxyFromEnvironment(Uri url, Map<String, String>? environment) {
    if (_proxyOverride != null) {
      return _proxyOverride!.findProxyFromEnvironment(url, environment);
    }

    return super.findProxyFromEnvironment(url, environment);
  }
}
