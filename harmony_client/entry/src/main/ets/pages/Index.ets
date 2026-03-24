import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { articleService } from '../service/ArticleService';
import { userService } from '../service/UserService';
import type { Article } from '../model/DataModel';
import common from '@ohos.app.ability.common';

@Entry
@Component
struct IndexPage {
  @State articleList: Article[] = [];
  @State isLoading: boolean = false;
  @State currentUsername: string = '';
  @State showMyArticles: boolean = false; // false=显示全部，true=只显示我的
  @State searchKeyword: string = ''; // 搜索关键字
  @State isAdmin: boolean = false; // 是否为管理员
  private context: common.UIAbilityContext | null = null;
  private currentUserId: number = 0;

  async aboutToAppear(): Promise<void> {
    this.context = getContext(this) as common.UIAbilityContext;
    
    // 先初始化存储（确保从本地存储读取最新状态）
    if (this.context) {
      await userService.initStorage(this.context);
    }

    // 验证登录状态的有效性（解决 DevEco 热重载缓存问题）
    const isValidLogin = await userService.validateLoginState();
    if (!isValidLogin) {
      await userService.logout();
      router.replaceUrl({ url: 'pages/Login' });
      return;
    }

    // 获取当前用户信息
    const currentUser = userService.getCurrentUser();
    this.currentUsername = currentUser?.nickname || currentUser?.username || '用户';
    this.currentUserId = currentUser?.id || 0;
    this.isAdmin = currentUser?.role === 'ADMIN' || currentUser?.role === 'admin';
  }

  /**
   * 每次页面显示时调用（包括从其他页面返回）
   */
  onPageShow(): void {
    // 从详情页或编辑页返回时刷新文章列表
    this.loadArticleList();
  }

  /**
   * 加载文章列表
   */
  async loadArticleList(): Promise<void> {
    this.isLoading = true;
    try {
      const userId = this.showMyArticles && this.currentUserId > 0 ? this.currentUserId : undefined;
      const keyword = this.searchKeyword.trim() || undefined;
      this.articleList = await articleService.getArticleList(userId, keyword);
    } catch (err) {
      if (err instanceof Error) {
        promptAction.showToast({ message: err.message || '加载文章列表失败' });
      } else {
        promptAction.showToast({ message: '加载文章列表失败' });
      }
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 切换显示模式（全部/我的文章）
   */
  toggleShowMode(): void {
    this.showMyArticles = !this.showMyArticles;
    this.loadArticleList();
  }

  /**
   * 跳转到文章详情
   */
  goToArticleDetail(articleId: number): void {
    router.pushUrl({
      url: 'pages/ArticleDetail',
      params: { articleId }
    });
  }

  /**
   * 跳转到创建文章页面
   */
  goToCreateArticle(): void {
    router.pushUrl({ url: 'pages/EditArticle' });
  }

  /**
   * 退出登录
   */
  async handleLogout(): Promise<void> {
    await userService.logout();
    promptAction.showToast({ message: '已退出登录' });
    router.replaceUrl({ url: 'pages/Login' });
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('博客文章')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1);

        Text(this.currentUsername)
          .fontSize(14)
          .fontColor('#666')
          .margin({ right: 10 });

        // 管理员入口
        if (this.isAdmin) {
          Button('复核')
            .width(60)
            .height(32)
            .fontSize(12)
            .backgroundColor('#ff7d00')
            .margin({ right: 8 })
            .onClick(() => {
              router.pushUrl({ url: 'pages/AdminAppeal' });
            });
        }

        Button('退出')
          .width(60)
          .height(32)
          .fontSize(12)
          .backgroundColor('#f53f3f')
          .onClick(() => {
            this.handleLogout();
          });
      }
      .width('100%')
      .padding({ left: 15, right: 15, top: 10, bottom: 10 })
      .backgroundColor('#fff');

      // 搜索框和切换按钮
      Column() {
        // 搜索框
        TextInput({ placeholder: '搜索文章标题或作者...' })
          .width('100%')
          .height(40)
          .fontSize(14)
          .backgroundColor('#f5f5f5')
          .borderRadius(20)
          .padding({ left: 15, right: 15 })
          .onChange((value: string) => {
            this.searchKeyword = value;
          })
          .onSubmit(() => {
            this.loadArticleList();
          });

        // 切换按钮（全部文章/我的文章）
        Row() {
          Button(this.showMyArticles ? '全部文章' : '我的文章')
            .width(100)
            .height(32)
            .fontSize(12)
            .backgroundColor('#1677ff')
            .onClick(() => {
              this.toggleShowMode();
            });
        }
        .width('100%')
        .margin({ top: 10 })
        .justifyContent(FlexAlign.End);
      }
      .width('100%')
      .padding({ left: 15, right: 15, top: 10, bottom: 10 })
      .backgroundColor('#fff');

      // 文章列表
      List({ space: 10 }) {
        if (this.isLoading) {
          ListItem() {
            Column() {
              LoadingProgress()
                .width(50)
                .height(50)
                .color('#1890ff');
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .margin({ top: 50 });
          }
        } else if (this.articleList.length === 0) {
          ListItem() {
            Column() {
              Text(this.showMyArticles ? '您还没有发布文章' : '暂无文章')
                .fontSize(16)
                .fontColor('#999');
              Text(this.showMyArticles ? '点击右下角按钮发布第一篇文章' : '暂无公开文章')
                .fontSize(12)
                .fontColor('#ccc')
                .margin({ top: 10 });
            }
            .width('100%')
            .margin({ top: 100 });
          }
        } else {
          ForEach(this.articleList, (article: Article) => {
            ListItem() {
              ArticleItem({
                article,
                currentUserId: this.currentUserId,
                isAdmin: this.isAdmin,
                onItemClick: () => this.goToArticleDetail(article.id)
              });
            }
            .margin({ left: 15, right: 15 });
          }, (article: Article) => article.id.toString());
        }
      }
      .layoutWeight(1)
      .width('100%')
      .backgroundColor('#f5f5f5');

      // 创建文章按钮
      Button('+')
        .width(60)
        .height(60)
        .fontSize(30)
        .fontWeight(FontWeight.Lighter)
        .backgroundColor('#1677ff')
        .borderRadius(30)
        .position({ x: '80%', y: '80%' })
        .onClick(() => {
          this.goToCreateArticle();
        });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5');
  }
}

/**
 * 文章列表项组件
 */
@Component
struct ArticleItem {
  article: Article = { id: 0, title: '', content: '', userId: 0, viewCount: 0, createTime: '' };
  currentUserId: number = 0;
  isAdmin: boolean = false;
  onItemClick: () => void = () => {};

  // 判断是否是作者
  private isAuthor(): boolean {
    return this.currentUserId > 0 && this.article.userId === this.currentUserId;
  }

  /**
   * 获取状态文本
   */
  getStatusText(status?: number): string {
    switch (status) {
      case 0: return '草稿';
      case 1: return '已发布';
      case 2: return '内容违规';
      case 3: return '复核中';
      case 4: return '复核通过';
      case 5: return '复核拒绝';
      default: return '';
    }
  }

  /**
   * 获取状态颜色
   */
  getStatusColor(status?: number): string {
    switch (status) {
      case 0: return '#86909c'; // 草稿-灰色
      case 1: return '#00b42a'; // 已发布-绿色
      case 2: return '#f53f3f'; // 内容违规-红色
      case 3: return '#1677ff'; // 复核中-蓝色
      case 4: return '#14c9c9'; // 复核通过-青色
      case 5: return '#f7ba1e'; // 复核拒绝-橙色（与申诉按钮统一色调）
      default: return '#86909c';
    }
  }

  build() {
    Column() {
      // 标题和状态标签
      Row() {
        Text(this.article.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1);

        // 状态标签（非已发布状态显示，复核通过状态只对作者和管理员显示）
        if (this.article.status !== undefined && this.article.status !== 1) {
          // 复核通过（状态4）只对作者和管理员显示
          if (this.article.status !== 4 || this.isAuthor() || this.isAdmin) {
            Text(this.getStatusText(this.article.status))
              .fontSize(10)
              .fontColor('#fff')
              .backgroundColor(this.getStatusColor(this.article.status))
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(4)
              .margin({ left: 8 });
          }
        }
      }
      .width('100%')
      .margin({ bottom: 8 });

      Text(this.article.content)
        .fontSize(14)
        .fontColor('#666')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .margin({ bottom: 10 });

      Row() {
        Text(`阅读: ${this.article.viewCount}`)
          .fontSize(12)
          .fontColor('#999');

        Text(this.article.createTime.split('T')[0])
          .fontSize(12)
          .fontColor('#999')
          .margin({ left: 20 });
      }
      .width('100%')
      .justifyContent(FlexAlign.Start);
    }
    .width('100%')
    .padding(15)
    .backgroundColor('#fff')
    .borderRadius(8)
    .onClick(() => {
      this.onItemClick();
    });
  }
}
