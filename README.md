# SGMW-EnergyUI 能耗UI

宝骏云海「状态」页 v32 大盘的 **纯 SwiftUI 原生 1:1 重写独立预览 App**。

- 绝无 HTML / WebView，全部原生 SwiftUI 逐像素还原 v32 规范
- 全部交互真实可用：三档主题切换 / 时间舱切换 / 更多抽屉 / 柱状图点击联动 / 按压缩放
- UI 验收通过后，整套视图文件将迁回 SGMW-Keyless 插件工程

## 构建

GitHub Actions（macos-14 + XcodeGen）自动构建未签名 `EnergyUI.ipa`（Actions 页 Artifacts 下载，TrollStore 直接安装或自签安装）。

本地构建：

```bash
brew install xcodegen
xcodegen generate
xcodebuild -project EnergyUI.xcodeproj -scheme EnergyUI -configuration Release \
  -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO build
```
