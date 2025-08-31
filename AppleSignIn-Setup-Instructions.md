# Apple Sign-In 設定指南

## 第一步：啟用 Apple Sign-In Capability

1. 在 Xcode 中開啟 `Atlas.xcodeproj`
2. 選擇 Project Navigator 中的 `Atlas` 項目
3. 選擇 `Atlas` target
4. 點擊 `Signing & Capabilities` 標籤
5. 點擊 `+ Capability` 按鈕
6. 搜尋並添加 `Sign In with Apple`

## 第二步：Firebase Console 設定

1. 前往 [Firebase Console](https://console.firebase.google.com/)
2. 選擇你的 Atlas 項目
3. 進入 `Authentication` > `Sign-in method`
4. 點擊 `Apple` 提供商
5. 點擊 `Enable` 開關
6. 按照指示設定 Apple 開發者帳戶中的 Services ID（如果需要）
7. 儲存設定

## 第三步：Apple 開發者帳戶設定

1. 前往 [Apple Developer](https://developer.apple.com/account/)
2. 選擇 `Certificates, Identifiers & Profiles`
3. 選擇 `Identifiers`
4. 找到你的 App ID (com.krauserhuang.Atlas)
5. 編輯 App ID，確保 `Sign In with Apple` 已啟用
6. 如果是新的 App ID，記得生成新的 Provisioning Profile

## 第四步：測試

1. 建構並運行應用程式
2. 點擊 "Continue with Apple" 按鈕
3. 應該會顯示 Apple Sign-In 的系統對話框
4. 使用 Apple ID 登入
5. 首次登入時可以選擇分享或隱藏電子郵件
6. 成功登入後應該會完成 Firebase 認證

## 注意事項

### 開發測試
- 在模擬器上測試 Apple Sign-In 需要在 iOS 設定中登入 Apple ID
- 建議在真機上測試以獲得最佳體驗

### 生產部署
- 確保你的 App ID 在 Apple Developer 中正確設定
- 確保 Provisioning Profile 包含 Sign In with Apple 服務
- 在 App Store Connect 中上傳 App 時，Apple Sign-In 功能會自動啟用

### 隱私考量
- Apple Sign-In 允許用戶選擇隱藏真實電子郵件
- 應用程式應該處理這種情況，使用 Apple 提供的代理郵件地址

### 錯誤處理
- 用戶可能會取消 Apple Sign-In 流程
- 網路錯誤可能導致認證失敗
- 應該提供適當的錯誤訊息和重試機制

## 程式碼說明

Apple Sign-In 的實作已經完成，包括：
- 生成安全的 nonce
- 處理 Apple ID 認證憑證
- 與 Firebase Authentication 整合
- 適當的錯誤處理
- 記憶體管理（避免循環引用）

所有功能都已經整合到 `AuthenticationViewModel` 中，並且在 `LoginView` 和 `SignupView` 中可以使用。