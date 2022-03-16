# http_ssl_pinning_override

**http_ssl_pinning_override** 

## Usage

You should set up before the [http](https://pub.dev/packages/http) request, typically before `runApp()`.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final List<int> cert1 = ...; final String cert1Sha1 = ...;
  final List<int> cert2 = ...; final String cert2Sha1 = ...;
  final httpSslPinningOverride =
      await HttpSslPinningOverride.createSslPinning(
        useSystemProxy: true,
        ignoreSslErrors: false,
      );
  httpSslPinningOverride.addTrusted(cert1, cert1Sha1)
    ..addTrustedCert(cert2)
    ..addTrustedSha1(cert2Sha1);
  HttpOverrides.global = httpSslPinningOverride;
  runApp(MyApp());
}
```
