# Google Sign-In 設定指南

## 第一步：添加 Google Sign-In SDK

1. 在 Xcode 中開啟 `Atlas.xcodeproj`
2. 選擇 Project Navigator 中的 `Atlas` 項目
3. 選擇 `Atlas` target
4. 點擊 `Package Dependencies` 標籤
5. 點擊 `+` 按鈕添加套件
6. 輸入 URL: `https://github.com/google/GoogleSignIn-iOS`
7. 選擇 `Up to Next Major Version` 和最新版本
8. 點擊 `Add Package`
9. 選擇 `GoogleSignIn` 和 `GoogleSignInSwift` 添加到 Atlas target

## 第二步：設定 URL Scheme

1. 從 `GoogleService-Info.plist` 中找到 `REVERSED_CLIENT_ID` 值
2. 在 Xcode 中選擇 `Atlas` target
3. 點擊 `Info` 標籤
4. 展開 `URL Types`
5. 點擊 `+` 添加新的 URL Type
6. 在 `URL Schemes` 中輸入 `REVERSED_CLIENT_ID` 的值

## 第三步：啟用程式碼

完成上述步驟後，需要在以下檔案中取消註解：

### AtlasApp.swift
```swift
import GoogleSignIn

// 在 AppDelegate 中取消註解:
guard let clientID = FirebaseApp.app()?.options.clientID else {
    fatalError("Firebase client ID not found")
}
GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

// URL scheme 處理:
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    return GIDSignIn.sharedInstance.handle(url)
}
```

### AuthenticationViewModel.swift
```swift
import GoogleSignIn

// 在 signInWithGoogle() 方法中啟用完整實作
```

## 第四步：測試

1. 建構並運行應用程式
2. 點擊 "Continue with Google" 按鈕
3. 應該會開啟 Google 登入流程
4. 成功登入後應該會返回到應用程式並完成認證

## 注意事項

- 確保 Firebase 項目中已啟用 Google Sign-In 認證方法
- 確保在 Firebase Console 中設定了正確的 iOS bundle ID
- 如果測試時遇到問題，檢查 Xcode 控制台的錯誤訊息