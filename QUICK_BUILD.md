# 快速编译指南

## 🚀 最快方法：GitHub Actions（5分钟搞定）

### 第一步：创建 GitHub 仓库

1. 打开 https://github.com/new
2. 仓库名填：`lushuaih`
3. 选择 **Public**
4. 点击 **Create repository**

### 第二步：上传代码

**在项目根目录执行：**

```bash
cd lushuaih

# 初始化
git init
git add .
git commit -m "Initial commit"

# 推送到 GitHub（替换成你的用户名）
git remote add origin https://github.com/你的用户名/lushuaih.git
git branch -M main
git push -u origin main
```

### 第三步：等待编译

1. 进入你的仓库页面
2. 点击顶部的 **Actions** 标签
3. 等待编译完成（约5分钟）

### 第四步：下载 APK

**方式 A：从 Releases 下载**
- 点击右侧 **Releases**
- 下载 `lushuaih-demo-v1.0.0.apk`

**方式 B：从 Artifacts 下载**
- 在 Actions 页面点击最新的工作流
- 滚动到底部 **Artifacts** 区域
- 点击 `lushuaih-demo-apk` 下载

---

## 💻 本地编译方法（需要配置环境）

### Windows 用户

1. **安装 Flutter**（约 2GB）
   ```
   下载：https://docs.flutter.dev/get-started/install/windows
   ```

2. **打开 PowerShell，执行：**
   ```powershell
   cd lushuaih
   
   # 使用独立版本（无需Firebase配置）
   copy lib\main_standalone.dart lib\main.dart
   copy pubspec_standalone.yaml pubspec.yaml
   
   # 编译
   flutter pub get
   flutter build apk --release
   ```

3. **APK 位置：**
   ```
   build\app\outputs\flutter-apk\app-release.apk
   ```

### macOS / Linux 用户

```bash
cd lushuaih

# 切换到独立版本
cp lib/main_standalone.dart lib/main.dart
cp pubspec_standalone.yaml pubspec.yaml

# 编译
flutter pub get
flutter build apk --release
```

APK 位于：`build/app/outputs/flutter-apk/app-release.apk`

---

## 📱 安装到手机

1. 将 APK 传输到手机：
   - USB 数据线连接
   - 微信/QQ文件传输
   - 云盘下载

2. 在手机上打开 APK 文件

3. 如果提示"禁止安装未知应用"：
   - 设置 → 安全 → 允许安装未知来源

4. 安装完成后打开应用

---

## 🎯 两个版本的区别

| 特性 | Demo版本（默认编译） | 完整版本 |
|-----|------------------|---------|
| UI界面 | ✅ 完整 | ✅ 完整 |
| 浏览帖子 | ✅ 模拟数据 | ✅ 真实数据 |
| 发布帖子 | ❌ 需登录 | ✅ |
| 评论互动 | ❌ | ✅ |
| 用户系统 | ❌ | ✅ |
| 需要配置 | 无需配置 | 需Firebase |

**建议：先用 Demo 版本体验界面，满意后再配置 Firebase 解锁完整功能。**

---

## ❓ 遇到问题？

### GitHub Actions 编译失败
- 检查仓库是否为 Public
- 查看 Actions 页面的错误日志

### 本地编译失败
```bash
# 检查环境
flutter doctor -v

# 清理重试
flutter clean
flutter pub get
flutter build apk --release
```

### 手机安装失败
- 确保开启"未知来源应用安装"
- 先卸载旧版本再安装
- 检查手机存储空间

---

## 🔗 相关链接

- Flutter 安装指南：https://docs.flutter.dev/get-started/install
- GitHub Actions 文档：https://docs.github.com/cn/actions
- 项目完整文档：README.md
