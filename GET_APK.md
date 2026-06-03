# 获取 APK 安装包指南

## 方法一：GitHub Actions 自动编译（最简单）

### 步骤 1: 上传代码到 GitHub

```bash
# 初始化 Git 仓库
cd lushuaih
git init
git add .
git commit -m "Initial commit"

# 在 GitHub 创建新仓库后推送
git remote add origin https://github.com/你的用户名/lushuaih.git
git branch -M main
git push -u origin main
```

### 步骤 2: 等待自动编译

推送后，GitHub Actions 会自动开始编译。你可以：
1. 进入仓库的 **Actions** 标签页
2. 查看编译进度
3. 编译成功后，会在 **Releases** 页面生成 APK 下载链接

### 步骤 3: 下载 APK

编译完成后有两种下载方式：

**方式 A: 从 Releases 下载**
1. 进入仓库的 **Releases** 页面
2. 下载 `lushuaih-demo-v1.0.0.apk`

**方式 B: 从 Artifacts 下载**
1. 进入 **Actions** 页面
2. 点击最新的工作流
3. 在页面底部 **Artifacts** 区域下载 `lushuaih-demo-apk`

---

## 方法二：本地编译

### 前置要求

1. **安装 Flutter SDK**
   - Windows: https://docs.flutter.dev/get-started/install/windows
   - macOS: https://docs.flutter.dev/get-started/install/macos
   - Linux: https://docs.flutter.dev/get-started/install/linux

2. **验证安装**
```bash
flutter doctor
```

### 编译 Demo 版本（无需 Firebase）

```bash
cd lushuaih

# 切换到独立版本
cp lib/main_standalone.dart lib/main.dart
cp pubspec_standalone.yaml pubspec.yaml

# 获取依赖
flutter pub get

# 编译 APK
flutter build apk --release
```

### 安装到手机

```bash
# 方式 1: 通过 USB 连接直接安装
flutter install

# 方式 2: 手动传输 APK
# APK 位置: build/app/outputs/flutter-apk/app-release.apk
# 将此文件传输到手机并安装
```

---

## 方法三：使用在线编译服务

### Codemagic（推荐）

1. 访问 https://codemagic.io
2. 使用 GitHub 账号登录
3. 添加你的仓库
4. 选择 Flutter 模板
5. 点击 **Start new build**

### 其他选项

- **Bitrise**: https://www.bitrise.io
- **CircleCI**: https://circleci.com
- **AppCenter**: https://appcenter.ms

---

## 项目文件说明

```
lushuaih/
├── lib/
│   ├── main.dart              # 完整版入口（需要 Firebase）
│   ├── main_standalone.dart   # 独立版入口（无需 Firebase，可直接编译）
│   ├── models/                # 数据模型
│   ├── providers/             # 状态管理
│   ├── screens/               # 页面
│   └── services/              # 服务层
├── pubspec.yaml               # 完整版依赖（需要 Firebase）
├── pubspec_standalone.yaml    # 独立版依赖（无 Firebase）
├── .github/workflows/
│   └── build.yml              # GitHub Actions 配置
└── README.md                  # 项目文档
```

---

## 常见问题

### Q: 编译失败怎么办？

**检查 Flutter 环境：**
```bash
flutter doctor -v
```

**常见解决方案：**
- 更新 Flutter SDK: `flutter upgrade`
- 清理缓存: `flutter clean`
- 重新获取依赖: `flutter pub get`

### Q: 手机无法安装 APK？

1. 确保开启 **允许安装未知来源应用**
2. 如果之前安装过同包名应用，先卸载
3. 检查手机架构是否匹配（APK 默认包含所有架构）

### Q: 如何修改应用名称？

编辑 `android/app/src/main/AndroidManifest.xml`:
```xml
<application android:label="你的应用名">
```

### Q: 如何修改应用图标？

1. 准备一张 1024x1024 的图标图片
2. 使用工具：https://romannurik.github.io/AndroidAssetStudio/
3. 替换 `android/app/src/main/res/` 目录下的图标文件

---

## 功能对比

| 功能 | Demo 版本 | 完整版本 |
|------|----------|---------|
| 浏览帖子 | ✅ 模拟数据 | ✅ 真实数据 |
| 发布帖子 | ❌ | ✅ |
| 评论互动 | ❌ | ✅ |
| 用户登录 | ❌ | ✅ |
| 私信功能 | ❌ | ✅ |
| 关注系统 | ❌ | ✅ |
| 通知推送 | ❌ | ✅ |

---

## 下一步

### 配置 Firebase（解锁完整功能）

1. 创建 Firebase 项目：https://console.firebase.google.com
2. 添加 Android 应用（包名：`com.lushuaih.app`）
3. 下载 `google-services.json` 放到 `android/app/`
4. 更新 `lib/firebase_options.dart` 中的配置
5. 使用 `pubspec.yaml` 重新编译

详细步骤见：`README.md`
