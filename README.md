# lushuaih - Flutter 社区论坛应用

一个功能完整的移动端社区论坛应用，基于 Flutter 和 Firebase 构建。

## 功能特性

### 核心功能
- **用户认证**：注册、登录、密码重置
- **帖子管理**：发布、浏览、删除帖子
- **分类浏览**：综合、技术、生活、娱乐、问答、资讯
- **搜索功能**：搜索帖子和用户

### 互动功能
- **评论系统**：发表评论、回复评论
- **点赞功能**：点赞帖子和评论
- **关注系统**：关注用户、查看粉丝/关注列表
- **私信功能**：用户间私信聊天
- **通知系统**：点赞、评论、关注通知

### 特色功能
- **热门推荐**：算法推荐热门内容
- **举报系统**：举报违规内容
- **@提醒**：在评论中@其他用户
- **深色模式**：支持明暗主题切换

## 技术栈

- **前端框架**：Flutter 3.x
- **后端服务**：Firebase
  - Firebase Auth - 用户认证
  - Cloud Firestore - 数据存储
  - Firebase Storage - 图片存储
  - Firebase Messaging - 推送通知
- **状态管理**：Provider
- **UI 组件**：Material Design 3

## 项目结构

```
lib/
├── main.dart                 # 应用入口
├── models/                   # 数据模型
│   ├── user_model.dart
│   ├── post_model.dart
│   ├── comment_model.dart
│   └── notification_model.dart
├── providers/                # 状态管理
│   ├── auth_provider.dart
│   ├── posts_provider.dart
│   ├── users_provider.dart
│   └── notifications_provider.dart
├── services/                 # 服务层
│   └── firebase_service.dart
├── screens/                  # 页面
│   ├── auth/                 # 认证相关页面
│   ├── main/                 # 主页面
│   ├── post/                 # 帖子相关页面
│   ├── profile/              # 个人资料页面
│   ├── search/               # 搜索页面
│   └── notifications/        # 通知页面
└── widgets/                  # 公共组件
```

## 快速开始

### 前置要求

1. 安装 Flutter SDK (>=3.0.0)
2. 配置 Flutter 开发环境
3. 创建 Firebase 项目

### 配置步骤

1. **克隆项目**
```bash
cd lushuaih
```

2. **安装依赖**
```bash
flutter pub get
```

3. **配置 Firebase**

   - 在 [Firebase Console](https://console.firebase.google.com) 创建新项目
   - 添加 Android 和 iOS 应用
   - 下载配置文件：
     - Android: `google-services.json` 放到 `android/app/`
     - iOS: `GoogleService-Info.plist` 放到 `ios/Runner/`
   
   更新 `lib/firebase_options.dart`：
```dart
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: '你的API_KEY',
      appId: '你的APP_ID',
      messagingSenderId: '你的SENDER_ID',
      projectId: '你的PROJECT_ID',
      storageBucket: '你的STORAGE_BUCKET',
    );
  }
}
```

4. **运行应用**
```bash
flutter run
```

### Firebase 数据库规则

在 Firebase Console 中设置以下 Firestore 规则：

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## 功能截图

| 登录页面 | 首页 | 发布帖子 |
|---------|------|---------|
| 用户主页 | 帖子详情 | 通知中心 |

## 数据模型

### User (用户)
```dart
{
  id: String,
  email: String,
  username: String,
  avatarUrl: String?,
  bio: String?,
  followersCount: int,
  followingCount: int,
  postsCount: int,
  createdAt: DateTime,
  isOnline: bool
}
```

### Post (帖子)
```dart
{
  id: String,
  authorId: String,
  title: String,
  content: String,
  images: List<String>,
  tags: List<String>,
  category: String,
  likesCount: int,
  commentsCount: int,
  viewsCount: int,
  isHot: bool,
  createdAt: DateTime
}
```

### Comment (评论)
```dart
{
  id: String,
  postId: String,
  authorId: String,
  content: String,
  likesCount: int,
  createdAt: DateTime
}
```

## API 接口

所有数据操作通过 `FirebaseService` 类封装：

- 用户认证：`signUp()`, `signIn()`, `signOut()`
- 帖子操作：`createPost()`, `getPosts()`, `deletePost()`, `searchPosts()`
- 评论操作：`createComment()`, `getComments()`
- 点赞操作：`toggleLike()`, `isLiked()`
- 关注操作：`toggleFollow()`, `isFollowing()`
- 通知操作：`createNotification()`, `getNotifications()`

## 构建发布

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 开发计划

- [ ] 添加图片上传功能
- [ ] 实现视频帖子支持
- [ ] 添加语音消息功能
- [ ] 实现帖子举报审核后台
- [ ] 添加消息推送通知
- [ ] 优化热门推荐算法
- [ ] 添加深色模式切换
- [ ] 国际化支持

## 许可证

MIT License

## 联系方式

如有问题或建议，欢迎提交 Issue。
