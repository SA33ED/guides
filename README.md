# 🚀 Flutter Deep Linking Guide

This guide provides step-by-step instructions to implement deep linking in a Flutter application for both Android and iOS platforms.

---

## 📌 Steps to Implement Deep Linking

### 1️⃣ Configure AndroidManifest.xml

📍 **Inside **``** tag**:

```xml
<!-- DEEP LINKS -->
<meta-data android:name="flutter_deeplinking_enabled" android:value="true" />
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <!-- Accepts URIs that begin with https://YOUR_HOST -->
    <data
        android:scheme="https"
        android:host="joystick.evyx.lol"
        android:pathPrefix="/product" />
</intent-filter>
```

📍 **Inside **``** tag**, under `<queries>`:

```xml
<!-- DEEP LINKS  -->
<intent>
    <action android:name="android.intent.action.VIEW" />
    <data android:scheme="https" />
</intent>
```

---

### 2️⃣ Configure iOS (Info.plist)

📍 **Inside **``** tag**:

```xml
<!-- DEEP LINKS -->
<key>com.apple.developer.associated-domains</key>
  <array>
    <string>applinks:joystick.evyx.lol</string>
  </array>
<key>CFBundleURLTypes</key>
  <array>
    <dict>
      <key>CFBundleURLName</key>
      <string>joystick.evyx.lol</string>
      <key>CFBundleURLSchemes</key>
      <array>
        <string>joy_stick</string>
      </array>
    </dict>
  </array>
<key>NSUserActivityTypes</key>
  <array>
    <string>NSUserActivityTypeBrowsingWeb</string>
  </array>
```

---

### 3️⃣ Generate & Host `assetlinks.json` (Android)

📍 **Create **``** file** and add:

```json
[
  {
    "relation": [
      "delegate_permission/common.handle_all_urls"
    ],
    "target": {
      "namespace": "android_app",
      "package_name": "com.joystick.evyx",
      "sha256_cert_fingerprints": [
        "29:AA:E4:5B:40:B4:B7:6D:CA:09:CC:E0:1F:09:53:B0:03:65:F4:50:AD:8D:64:E5:5B:75:6E:56:F0:F6:48:59",
        "C8:3C:4B:B4:63:11:34:C1:DB:48:B1:B7:79:E1:3B:32:E4:BE:AC:92:81:FD:8C:5D:86:18:80:5D:84:A1:AE:26"
      ]
    }
  }
]
```

📍 **Get **``:

```sh
cd android
./gradlew signingreport
```

📍 **Host the file on your domain**:

```
https://joystick.evyx.lol/.well-known/assetlinks.json
```

---

### 4️⃣ Host iOS `apple-app-site-association`

📍 **Create a file named **``** (without extension)** and add:

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "YOUR_TEAM_ID.com.joystick.evyx",
        "paths": ["/product/*"]
      }
    ]
  }
}
```

📍 **Host the file on your domain**:

```
https://joystick.evyx.lol/.well-known/apple-app-site-association
```

---

### 5️⃣ Add `app_links` package

📍 **Update **``:

```yaml
dependencies:
  app_links: ^6.4.0
```

---

### 6️⃣ Handle Deep Linking in the App

📍 **Inside **``:

```dart
late final AppLinks _appLinks;
StreamSubscription<Uri?>? _linkSubscription;

@override
void initState() {
  super.initState();
  _appLinks = AppLinks();
  _initDeepLinkListener();
}

void _initDeepLinkListener() async {
  final Uri? initialLink = await _appLinks.getInitialLink();
  if (initialLink != null) {
    _handleDeepLink(initialLink);
  }

  _linkSubscription = _appLinks.uriLinkStream.listen(
    (Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    },
  );
}

void _handleDeepLink(Uri uri) {
  navigatorKey.currentState?.pushNamed(uri.toString());
}

@override
void dispose() {
  _linkSubscription?.cancel();
  super.dispose();
}
```

---

### 7️⃣ Handle Routing for Deep Links

📍 **Inside your router**:

```dart
final Uri uri = Uri.parse(routeSettings.name ?? '');
if (uri.pathSegments.isNotEmpty) {
  if (uri.pathSegments.length == 2 && uri.pathSegments[0] == 'product') {
    final productId = uri.pathSegments[1];
    return MaterialPageRoute(
      builder: (_) => BaseScreen(
        productIdFromDeepLink: int.parse(productId),
      ),
    );
  }
}
```

---

### 8️⃣ Navigate Inside `BaseScreen`

📍 **Inside **``:

```dart
@override
void initState() {
  super.initState();
  navigateWithDeepLink();
}

navigateWithDeepLink() async {
  await context.read<GlobalCubit>().getUserProfile();
  await context.read<HomeCubit>().getHome();
  if (widget.productIdFromDeepLink != null) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        navBarNavigate(
          context: context,
          screen: ProductDetails(
            id: widget.productIdFromDeepLink!,
          ),
        );
      },
    );
  }
}
```

---

### 9️⃣ Share Deep Link

📍 **Update **``:

```yaml
dependencies:
  share_plus: ^10.1.4
```

📍 **Generate & Share Link**:

```dart
var link = "https://joystick.evyx.lol/product/${cubit.product?.id}";
Share.share(
  "JoyStick Repair: $link \n ${cubit.product?.name}",
  subject: cubit.product?.name,
);
```

---

## 🎯 Conclusion

By following these steps, you can enable deep linking in your Flutter application for both Android and iOS platforms. This allows users to navigate directly to specific content within your app from external links. 🚀

