import 'dart:async';
import 'dart:io';

import 'package:http_proxy_override/http_proxy_override.dart';

class HttpSslPinningOverride extends HttpOverrides {
  late final HttpProxyOverride? _proxyOverride;
  late final bool _ignoreSslErrors;

  final _trustedSha1 = <String>{};

  HttpSslPinningOverride._(this._ignoreSslErrors);

  static Future<HttpSslPinningOverride> createSslPinning({
    bool useSystemProxy = false,
    bool ignoreSslErrors = false,
  }) async {
    return HttpSslPinningOverride._(ignoreSslErrors)
      .._proxyOverride =
          ((useSystemProxy) ? await HttpProxyOverride.createHttpProxy() : null);
  }

  void addTrustedCert(List<int> certBytes) {
    if (certBytes.isEmpty) {
      return;
    }

    SecurityContext.defaultContext.setTrustedCertificatesBytes(certBytes);
  }

  void addTrustedSha1<T>(T sha1) {
    if (sha1 == null) {
      return;
    }

    if (T == String) {
      _trustedSha1.add((sha1 as String).normalizedSha1);
    } else if (T == List<String>) {
      _trustedSha1.add((sha1 as List<String>).normalizedSha1);
    } else if (T == List<int>) {
      _trustedSha1.add((sha1 as List<int>).normalizedSha1);
    } else {
      throw UnimplementedError('addTrustedSha1 is undefined for $T');
    }
  }

  void addTrusted<T>(List<int>? certBytes, T sha1) {
    if (certBytes != null) {
      addTrustedCert(certBytes);
    }

    if (sha1 != null) {
      addTrustedSha1(sha1);
    }
  }

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback = (
      X509Certificate cert,
      String host,
      int port,
    ) {
      return _ignoreSslErrors ||
          _trustedSha1.contains(cert.sha1.normalizedSha1);
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

extension _StringsToSha1 on Iterable<String> {
  String get normalizedSha1 =>
      map((e) => e.padLeft(2, '0')).join().toLowerCase();
}

extension _IntsToSha1 on Iterable<int> {
  String get normalizedSha1 =>
      map((e) => e.toRadixString(16).padLeft(2, '0')).join().toLowerCase();
}

extension _StringToSha1 on String {
  String get normalizedSha1 => split(RegExp(r'[^\dA-Fa-f]+')).normalizedSha1;
}
