import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { appealService } from '../service/AppealService';
import { articleService } from '../service/ArticleService';
import { userService } from '../service/UserService';
import type { ReviewAppeal, Article } from '../model/DataModel';

@Entry
@Component
struct AdminAppealPage {
  @State appealList: ReviewAppeal[] = [];
  @State isLoading: boolean = false;
  @State selectedAppeal: ReviewAppeal | null = null;
  @State articleDetail: Article | null = null;
  @State showDetailDialog: boolean = false;
  @State handlerNote: string = '';

  async aboutToAppear(): Promise<void> {
    // 检查是否为管理员
    const currentUser = userService.getCurrentUser();
    if (!currentUser || (currentUser.role !== 'ADMIN' && currentUser.role !== 'admin')) {
      promptAction.showToast({ message: '无管理员权限' });
      router.back();
      return;
    }

    await this.loadAppealList();
  }

  /**
   * 加载待处理的申诉列表
   */
  async loadAppealList(): Promise<void> {
    this.isLoading = true;
    try {
      this.appealList = await appealService.getPendingAppeals();
    } catch (err) {
      if (err instanceof Error) {
        promptAction.showToast({ message: err.message || '加载申诉列表失败' });
      } else {
        promptAction.showToast({ message: '加载申诉列表失败' });
      }
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 查看申诉详情
   */
  async viewAppealDetail(appeal: ReviewAppeal): Promise<void> {
    try {
      this.articleDetail = await articleService.getArticleById(appeal.articleId);
      this.selectedAppeal = appeal;
      this.handlerNote = '';
      this.showDetailDialog = true;
    } catch (err) {
      if (err instanceof Error) {
        promptAction.showToast({ message: err.message || '加载文章详情失败' });
      } else {
        promptAction.showToast({ message: '加载文章详情失败' });
      }
    }
  }

  /**
   * 批准申诉
   */
  async approveAppeal(): Promise<void> {
    if (!this.selectedAppeal) return;

    try {
      await appealService.approveAppeal(this.selectedAppeal.id, this.handlerNote);
      promptAction.showToast({ message: '申诉已批准，文章已恢复显示' });
      this.showDetailDialog = false;
      await this.loadAppealList();
    } catch (err) {
      if (err instanceof Error) {
        promptAction.showToast({ message: err.message || '操作失败' });
      } else {
        promptAction.showToast({ message: '操作失败' });
      }
    }
  }

  /**
   * 驳回申诉
   */
  async rejectAppeal(): Promise<void> {
    if (!this.selectedAppeal) return;

    try {
      await appealService.rejectAppeal(this.selectedAppeal.id, this.handlerNote);
      promptAction.showToast({ message: '申诉已驳回' });
      this.showDetailDialog = false;
      await this.loadAppealList();
    } catch (err) {
      if (err instanceof Error) {
        promptAction.showToast({ message: err.message || '操作失败' });
      } else {
        promptAction.showToast({ message: '操作失败' });
      }
    }
  }

  /**
   * 获取状态文本
   */
  getStatusText(status: number): string {
    switch (status) {
      case 0: return '待处理';
      case 1: return '已批准';
      case 2: return '已驳回';
      default: return '未知';
    }
  }

  build() {
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

        Text('复核申诉管理')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center);

        Text('')
          .width(60);
      }
      .width('100%')
      .padding({ left: 15, right: 15, top: 10, bottom: 10 })
      .backgroundColor('#fff');

      // 申诉列表
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color('#1890ff');
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center);
      } else if (this.appealList.length === 0) {
        Column() {
          Text('暂无待处理的申诉')
            .fontSize(16)
            .fontColor('#999');
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center);
      } else {
        List({ space: 10 }) {
          ForEach(this.appealList, (appeal: ReviewAppeal) => {
            ListItem() {
              this.AppealItem(appeal);
            }
            .margin({ left: 15, right: 15 });
          }, (appeal: ReviewAppeal) => appeal.id.toString());
        }
        .layoutWeight(1)
        .width('100%')
        .margin({ top: 10 });
      }

      // 详情弹窗
      if (this.showDetailDialog && this.selectedAppeal && this.articleDetail) {
        this.DetailDialog();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5');
  }

  /**
   * 申诉列表项
   */
  @Builder
  AppealItem(appeal: ReviewAppeal) {
    Column() {
      Row() {
        Column() {
          Text(`申诉ID: ${appeal.id}`)
            .fontSize(14)
            .fontColor('#333')
            .fontWeight(FontWeight.Medium);

          Text(`文章ID: ${appeal.articleId}`)
            .fontSize(12)
            .fontColor('#666')
            .margin({ top: 5 });

          if (appeal.reason) {
            Text(`申诉理由: ${appeal.reason}`)
              .fontSize(12)
              .fontColor('#666')
              .margin({ top: 5 })
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis });
          }

          Text(`申请时间: ${appeal.createTime.split('T')[0]}`)
            .fontSize(12)
            .fontColor('#999')
            .margin({ top: 5 });
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);

        Button('处理')
          .width(60)
          .height(32)
          .fontSize(12)
          .backgroundColor('#1677ff')
          .onClick(() => {
            this.viewAppealDetail(appeal);
          });
      }
      .width('100%')
      .padding(15)
      .backgroundColor('#fff')
      .borderRadius(8);
    }
    .width('100%');
  }

  /**
   * 详情处理弹窗
   */
  @Builder
  DetailDialog() {
    Stack() {
      // 背景遮罩
      Column() {
      }
      .width('100%')
      .height('100%')
      .backgroundColor('rgba(0, 0, 0, 0.5)')
      .onClick(() => {
        this.showDetailDialog = false;
      });

      // 弹窗内容
      Column() {
        Text('申诉详情')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 15 });

        // 文章标题
        Text(`文章标题: ${this.articleDetail?.title || ''}`)
          .fontSize(14)
          .fontColor('#333')
          .width('100%')
          .margin({ bottom: 10 });

        // 文章内容预览
        Text(`文章内容: ${(this.articleDetail?.content || '').substring(0, 100)}...`)
          .fontSize(12)
          .fontColor('#666')
          .width('100%')
          .margin({ bottom: 10 });

        // 申诉理由
        Text(`申诉理由: ${this.selectedAppeal?.reason || '无'}`)
          .fontSize(14)
          .fontColor('#333')
          .width('100%')
          .margin({ bottom: 15 });

        // 处理备注输入
        TextInput({ placeholder: '输入处理备注（可选）', text: this.handlerNote })
          .width('100%')
          .height(80)
          .fontSize(14)
          .backgroundColor('#f5f5f5')
          .borderRadius(8)
          .padding({ left: 10, right: 10 })
          .onChange((value: string) => {
            this.handlerNote = value;
          });

        // 操作按钮
        Row() {
          Button('驳回')
            .layoutWeight(1)
            .height(40)
            .fontSize(14)
            .backgroundColor('#f53f3f')
            .margin({ right: 10 })
            .onClick(() => {
              this.rejectAppeal();
            });

          Button('批准')
            .layoutWeight(1)
            .height(40)
            .fontSize(14)
            .backgroundColor('#00b42a')
            .margin({ left: 10 })
            .onClick(() => {
              this.approveAppeal();
            });
        }
        .width('100%')
        .margin({ top: 15 });

        Button('取消')
          .width('100%')
          .height(40)
          .fontSize(14)
          .backgroundColor('#ccc')
          .margin({ top: 10 })
          .onClick(() => {
            this.showDetailDialog = false;
          });
      }
      .width('90%')
      .padding(20)
      .backgroundColor('#fff')
      .borderRadius(12);
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 });
  }
}
