import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { articleService } from '../service/ArticleService';
import { userService } from '../service/UserService';
import { appealService } from '../service/AppealService';
import type { Article } from '../model/DataModel';

@Entry
@Component
struct ArticleDetailPage {
  @State article: Article | null = null;
  @State isLoading: boolean = true;
  @State isAuthor: boolean = false;
  @State isAdmin: boolean = false;
  @State showAppealDialog: boolean = false;
  @State appealReason: string = '';
  private articleId: number = 0;

  async aboutToAppear(): Promise<void> {
    // 获取路由参数
    const params = router.getParams() as Record<string, Object>;
    this.articleId = params.articleId as number;
    
    if (!this.articleId) {
      promptAction.showToast({ message: '文章ID无效' });
      router.back();
      return;
    }

    await this.loadArticleDetail();
  }

  /**
   * 加载文章详情
   */
  async loadArticleDetail(): Promise<void> {
    this.isLoading = true;
    try {
      this.article = await articleService.getArticleById(this.articleId);
      
      // 判断是否是文章作者或管理员
      const currentUser = userService.getCurrentUser();
      if (currentUser !== null && this.article) {
        // 使用 == 进行宽松比较，避免类型不匹配问题
        this.isAuthor = currentUser.id == this.article.userId;
        this.isAdmin = currentUser.role === 'ADMIN' || currentUser.role === 'admin';
      } else {
        this.isAuthor = false;
        this.isAdmin = false;
      }
    } catch (err) {
      if (err instanceof Error) {
        promptAction.showToast({ message: err.message || '加载文章详情失败' });
      } else {
        promptAction.showToast({ message: '加载文章详情失败' });
      }
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 编辑文章
   */
  goToEditArticle(): void {
    if (this.article) {
      router.pushUrl({
        url: 'pages/EditArticle',
        params: { articleId: this.article.id }
      });
    }
  }

  /**
   * 删除文章
   */
  async deleteArticle(): Promise<void> {
    if (!this.article) return;

    try {
      await articleService.deleteArticle(this.article.id);
      promptAction.showToast({ message: '删除成功' });
      // 使用 replaceUrl 替代 back() 确保返回后页面刷新
      router.replaceUrl({ url: 'pages/Index' });
    } catch (err) {
      if (err instanceof Error) {
        promptAction.showToast({ message: err.message || '删除失败' });
      } else {
        promptAction.showToast({ message: '删除失败' });
      }
    }
  }

  /**
   * 发布草稿
   */
  async publishArticle(): Promise<void> {
    if (!this.article) return;

    try {
      await articleService.publishDraft(this.article.id);
      promptAction.showToast({ message: '发布成功' });
      // 刷新页面
      await this.loadArticleDetail();
    } catch (err) {
      if (err instanceof Error) {
        let errMsg = err.message || '发布失败';
        if (errMsg.includes('人工审核') || errMsg.includes('人工复核')) {
          promptAction.showToast({ message: '内容违规，如有异议可申请人工复核', duration: 4000 });
          // 刷新页面显示最新状态
          await this.loadArticleDetail();
        } else {
          promptAction.showToast({ message: errMsg });
        }
      } else {
        promptAction.showToast({ message: '发布失败' });
      }
    }
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
      default: return '未知状态';
    }
  }

  /**
   * 获取状态颜色
   */
  getStatusColor(status?: number): string {
    switch (status) {
      case 0:
        return '#86909c'; // 草稿-灰色
      case 1:
      case 4:
        return '#00b42a'; // 已发布/复核通过-绿色
      case 2:
        return '#f53f3f'; // 内容违规-红色
      case 3:
        return '#1677ff'; // 复核中-蓝色
      case 5:
        return '#f7ba1e'; // 复核拒绝-橙色
      default:
        return '#86909c'; // 其他-灰色
    }
  }

  /**
   * 发起复核申诉
   */
  async submitAppeal(reason?: string): Promise<void> {
    if (!this.article) return;

    try {
      await appealService.createAppeal(this.article.id, reason);
      promptAction.showToast({ message: '申诉已提交，请等待管理员复核' });
      // 刷新页面
      await this.loadArticleDetail();
    } catch (err) {
      if (err instanceof Error) {
        promptAction.showToast({ message: err.message || '申诉失败' });
      } else {
        promptAction.showToast({ message: '申诉失败' });
      }
    }
  }

  build() {
    Stack() {
      // 主内容区域
      Column() {
        // 顶部导航栏
        Row() {
          Button('返回')
            .width(60)
            .height(35)
            .fontSize(14)
            .backgroundColor('#86909c')
            .onClick(() => {
              router.back();
            });

          Text('文章详情')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)
            .textAlign(TextAlign.Center);

          // 作者或管理员操作按钮
          if (this.isAuthor || this.isAdmin) {
            Row() {
              // 草稿状态显示发布按钮
              if (this.article && this.article.status === 0 && this.isAuthor) {
                Button('发布')
                  .width(60)
                  .height(35)
                  .fontSize(14)
                  .backgroundColor('#1677ff')
                  .margin({ right: 8 })
                  .onClick(() => {
                    this.publishArticle();
                  });
              }

              Button('编辑')
                .width(60)
                .height(35)
                .fontSize(14)
                .backgroundColor('#00b42a')
                .margin({ right: 8 })
                .onClick(() => {
                  this.goToEditArticle();
                });

              Button('删除')
                .width(60)
                .height(35)
                .backgroundColor('#f53f3f')
                .onClick(() => {
                  this.deleteArticle();
                });
            }
          } else {
            // 占位，保持标题居中
            Text('').width(this.article && this.article.status === 0 ? 196 : 128);
          }
        }
        .width('100%')
        .padding({ left: 15, right: 15, top: 10, bottom: 10 })
        .backgroundColor('#fff')
        .alignItems(VerticalAlign.Center);

        // 加载中提示
        if (this.isLoading) {
          LoadingProgress()
            .width(50)
            .height(50)
            .color('#1677ff')
            .layoutWeight(1)
            .alignSelf(ItemAlign.Center);
        } else if (this.article) {
          // 文章内容区域
          Scroll() {
            Column() {
              // 文章标题和作者信息
              Column() {
                Text(this.article.title)
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333')
                  .margin({ bottom: 15 })
                  .width('100%')
                  .textAlign(TextAlign.Center);

                Row() {
                  Text('阅读: ' + this.article.viewCount + ' 次')
                    .fontSize(12)
                    .fontColor('#999');

                  if (this.article.createTime) {
                    Text('发布于: ' + this.article.createTime)
                      .fontSize(12)
                      .fontColor('#999')
                      .margin({ left: 10 });
                  }

                  // 状态标签（复核通过状态只对作者和管理员显示）
                  if (this.article.status !== undefined && this.article.status !== 1) {
                    // 复核通过（状态4）只对作者和管理员显示，其他状态正常显示
                    if (this.article.status !== 4 || this.isAuthor || this.isAdmin) {
                      Text(this.getStatusText(this.article.status))
                        .fontSize(12)
                        .fontColor('#fff')
                        .backgroundColor(this.getStatusColor(this.article.status))
                        .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                        .borderRadius(4)
                        .margin({ left: 20 });
                    }
                  }
                }
                .width('100%')
                .margin({ bottom: 20 });

                // 申诉按钮（文章状态为"不合规"或"复核拒绝"且为作者时显示）
                if (this.article && this.article.status !== undefined && this.isAuthor) {
                  if (this.article.status === 2 || this.article.status === 5) {
                    Button('申请人工复核')
                      .width('100%')
                      .height(40)
                      .fontSize(14)
                      .backgroundColor('#ff7d00')
                      .margin({ bottom: 20 })
                      .onClick(() => {
                        this.appealReason = '';
                        this.showAppealDialog = true;
                      });
                  }
                }

                // 分隔线
                Divider()
                  .width('100%')
                  .color('#eee')
                  .margin({ bottom: 20 });

                // 文章内容
                Text(this.article.content)
                  .fontSize(16)
                  .fontColor('#333')
                  .lineHeight(28)
                  .width('100%')
                  .textAlign(TextAlign.JUSTIFY);
              }
              .width('100%')
              .padding(20)
              .backgroundColor('#fff');
            }
            .layoutWeight(1)
            .width('100%');
          }
          .layoutWeight(1);
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f5f5f5');

      // 申诉理由填写对话框
      if (this.showAppealDialog) {
        Stack({ alignContent: Alignment.Center }) {
          // 半透明背景遮罩
          Column() {
          }
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.5)')
          .onClick(() => {
            this.showAppealDialog = false;
          });

          // 对话框内容
          Column() {
            Text('申请人工复核')
              .fontSize(18)
              .fontColor('#333')
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 20 });

            TextArea({ text: this.appealReason, placeholder: '请输入申诉理由（可选）...' })
              .width('100%')
              .height(120)
              .fontSize(14)
              .border({ width: 1, color: '#ddd', radius: 8 })
              .padding(12)
              .onChange((value: string) => {
                this.appealReason = value;
              })
              .margin({ bottom: 20 });

            Row() {
              Button('取消')
                .width(100)
                .height(40)
                .fontSize(14)
                .backgroundColor('#86909c')
                .fontColor('#fff')
                .onClick(() => {
                  this.showAppealDialog = false;
                });

              Button('提交申诉')
                .width(100)
                .height(40)
                .fontSize(14)
                .backgroundColor('#ff7d00')
                .margin({ left: 20 })
                .onClick(() => {
                  this.showAppealDialog = false;
                  this.submitAppeal(this.appealReason);
                });
            }
            .justifyContent(FlexAlign.Center)
            .width('100%');
          }
          .width('85%')
          .padding(20)
          .backgroundColor('#fff')
          .borderRadius(12);
        }
        .width('100%')
        .height('100%');
      }
    }
    .width('100%')
    .height('100%');
  }
}
