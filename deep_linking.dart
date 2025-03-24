/*
To implement deep linking in Flutter follow the below steps:

    (1) In AndroidManifest.xml 
      -> In Application tag
        -> In Activity tag
          -> Add the following :
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


      -> In manifest tag
        -> In queries tag:
          -> Add the following :
            <!-- DEEP LINKS  -->
            <intent>
                <action android:name="android.intent.action.VIEW" />
                <data android:scheme="https" />
            </intent>

    (2) In Info.plist
      -> In dict tag 
        -> Add the following : 
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

    (3) Generate assetlinks.json file and host it on your domain.
        1. Create a file named assetlinks.json
        2. Add the following content to the file:
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
        3. To Get sha256_cert_fingerprints run the following command in terminal:
            - cd android
            - ./gradlew signingreport
        4. Host the assetlinks.json file on your domain in path https://joystick.evyx.lol/.well-known/assetlinks.json.
    
    (4) Host IOS files 
        1. In the .well-known folder, create a file called apple-app-site-association (no file extension).

        2. Add the following content to the file:
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
        3. Replace YOUR_TEAM_ID with your Apple Team ID.
        4. Host the apple-app-site-association file on your domain in path https://joystick.evyx.lol/.well-known/apple-app-site-association.
    
    (5) Add Applinks package
        1. In pubspec.yaml
          -> Add the following :
            dependencies:
              app_links: ^6.4.0

    (6) Add the following code to handle deep linking in the app:
      1. In MyApp.dart add the listner for deep linking 
        ->
          late final AppLinks _appLinks;
          StreamSubscription<Uri?>? _linkSubscription;

          @override
          void initState() {
            super.initState();
            _appLinks = AppLinks();
            _initDeepLinkListener();
          }

          void _initDeepLinkListener() async {
            // Get the initial deep link if there is one
            final Uri? initialLink = await _appLinks.getInitialLink();
            if (initialLink != null) {
              _handleDeepLink(initialLink);
            }

            // Listen for subsequent deep links while the app is running
            _linkSubscription = _appLinks.uriLinkStream.listen(
              (Uri? uri) {
                if (uri != null) {
                  _handleDeepLink(uri);
                }
              },
            );
          }

          void _handleDeepLink(Uri uri) {
            // Custom logic to handle deep links as per the app requirement
            navigatorKey.currentState?.pushNamed(uri.toString());
          }

          @override
          void dispose() {
            _linkSubscription?.cancel();
            super.dispose();
          }
    
    (7) If you use Router to navigate Add the following to your router to hande Navigation
        ->
            final Uri uri = Uri.parse(routeSettings.name ?? '');
            // Handle deep links
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

    (8) In BaseScreen (optional) (As your app logic)
        ->
          @override
          void initState() {
            super.initState();
            navigateWithDeepLink();
          }
          navigateWithDeepLink() async {
            await context.read<GlobalCubit>().getUserProfile();
            await context.read<HomeCubit>().getHome();
            // Navigate to ProductDetails if productIdFromDeepLink is provided
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

    (9) To Share the deep link with the user use the following code:
        
          1. Add share_plus: ^10.1.4 to pubspec.yaml
          
          2. var link = "https://joystick.evyx.lol/product/${cubit.product?.id}";
            Share.share(
              "JoyStick Repair: $link \n ${cubit.product?.name}",
               subject: cubit.product?.name,
            );
*/
*/
