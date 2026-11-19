# ProfileBrowser

多 profile 隔离浏览器（iOS 17+，SwiftUI + WKWebView），参照 AdsPower 的 profile 思路：

- 每个 profile 使用独立的 `WKWebsiteDataStore`（按 profile UUID 隔离），cookie / localStorage / 缓存互不串号
- 每个 profile 可单独设置：User Agent（预设或自定义）、语言、时区、屏幕尺寸（JS 层注入的表面参数）、主页
- profile 可新建 / 编辑 / 删除，删除时一并清空其全部网站数据；也可单独一键清数据

## iOS 平台限制（先说清）

iOS 强制所有浏览器使用 WebKit 内核，自签名 App 没有特殊权限，因此做不到桌面指纹浏览器的底层能力：

- 不能改 canvas / WebGL / 字体列表等引擎级指纹
- 不能按 profile 分配独立代理（iOS 只有全局代理）
- JS 注入只能改 UA 之外的表面参数（语言、时区、屏幕），且注入式修改本身可被网站检测

本 App 的定位是「多账号分开登录、互不污染」，不是对抗平台风控的防关联工具。

## 构建

GitHub Actions 手动触发 `Build iOS IPA` 工作流（macos-14 + XcodeGen 生成工程），产出未签名 `ProfileBrowser-unsigned.ipa`（artifact 保留 30 天），自行重签名后安装。
