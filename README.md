# http_ssl_pinning_override

**http_ssl_pinning_override** 

## Usage

You should set up before the [http](https://pub.dev/packages/http) request, typically before `runApp()`.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final List<int> cert1 = ...;
  final List<int> cert2 = ...;
  final httpSslPinningOverride =
      await HttpSslPinningOverride.createSslPinning(
        useSystemProxy: true,
        ignoreSslErrors: false,
        certs: [cert1, cert2],
      );
  HttpOverrides.global = httpSslPinningOverride;
  runApp(MyApp());
}
```
