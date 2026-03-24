import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { articleService } from '../service/ArticleService';
import type { Article, ArticleRequest } from '../model/DataModel';

@Entry
@Component
struct EditArticlePage {
  @State title: string = '';
  @State content: string = '';
  @State isLoading: boolean = false;
  @State isEditMode: boolean = false;
  private articleId: number = 0;

  async aboutToAppear(): Promise<void> {
    // 获取路由参数（编辑模式）
    const params = router.getParams() as Record<string, Object>;
    if (params && params.articleId) {
      this.articleId = params.articleId as number;
      this.isEditMode = true;
      await this.loadArticleData();
    }
  }

  /**
   * 加载文章数据（编辑模式）
   */
  async loadArticleData(): Promise<void> {
    try {
      const article = await articleService.getArticleById(this.articleId);
      this.title = article.title;
      this.content = article.content;
    } catch (err) {
      if (err instanceof Error) {
        promptAction.showToast({ message: err.message || '加载文章数据失败' });
      } else {
        promptAction.showToast({ message: '加载文章数据失败' });
      }
    }
  }

  /**
   * 保存草稿
   */
  async saveDraft(): Promise<void> {
    if (!this.title.trim() && !this.content.trim()) {
      promptAction.showToast({ message: '请输入标题或内容' });
      return;
    }

    this.isLoading = true;
    try {
      const articleRequest: ArticleRequest = {
        title: this.title.trim() || '无标题草稿',
        content: this.content.trim()
      };

      if (this.isEditMode) {
        // 编辑模式：更新草稿
        await articleService.updateDraft(this.articleId, articleRequest);
        promptAction.showToast({ message: '草稿已保存' });
      } else {
        // 创建模式：新建草稿
        const result = await articleService.saveDraft(articleRequest);
        this.articleId = result.id;
        this.isEditMode = true;
        promptAction.showToast({ message: '草稿已保存' });
      }
    } catch (err) {
      if (err instanceof Error) {
        promptAction.showToast({ message: err.message || '保存草稿失败' });
      } else {
        promptAction.showToast({ message: '保存草稿失败' });
      }
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 提交文章
   */
  async submitArticle(): Promise<void> {
    if (!this.title.trim()) {
      promptAction.showToast({ message: '请输入文章标题' });
      return;
    }
    if (this.title.trim().length > 200) {
      promptAction.showToast({ message: '文章标题不能超过 200 个字符' });
      return;
    }
    if (!this.content.trim()) {
      promptAction.showToast({ message: '请输入文章内容' });
      return;
    }
    if (this.content.trim().length > 10000) {
      promptAction.showToast({ message: '文章内容不能超过 10000 个字符' });
      return;
    }

    this.isLoading = true;
    try {
      const articleRequest: ArticleRequest = {
        title: this.title.trim(),
        content: this.content.trim()
      };

      if (this.isEditMode) {
        // 编辑模式：更新文章
        await articleService.updateArticle(this.articleId, articleRequest);
        promptAction.showToast({ message: '文章更新成功' });
        // 返回列表页并确保数据刷新
        router.replaceUrl({ url: 'pages/Index' });
      } else {
        // 创建模式：新建文章
        try {
          await articleService.createArticle(articleRequest);
          promptAction.showToast({ message: '文章发布成功' });
          // 返回列表页并确保数据刷新
          router.replaceUrl({ url: 'pages/Index' });
        } catch (createErr) {
          let errMsg = '发布失败';
          if (createErr instanceof Error) {
            errMsg = createErr.message || '发布失败';
          }
          if (errMsg.includes('人工审核') || errMsg.includes('人工复核')) {
            // 人工复核情况：显示信息提示后返回
            promptAction.showToast({ message: '内容违规，如有异议可申请人工复核', duration: 4000 });
            setTimeout(() => {
              router.replaceUrl({ url: 'pages/Index' });
            }, 2500);
          } else {
            // 真正的错误：显示错误但不返回
            throw new Error(errMsg);
          }
        }
      }
    } catch (err) {
      if (err instanceof Error) {
        promptAction.showToast({ message: err.message || (this.isEditMode ? '更新失败' : '发布失败') });
      } else {
        promptAction.showToast({ message: this.isEditMode ? '更新失败' : '发布失败' });
      }
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button('取消')
          .width(60)
          .height(35)
          .fontSize(14)
          .backgroundColor('#86909c')
          .onClick(() => {
            router.back();
          });

        Text(this.isEditMode ? '编辑文章' : '发布文章')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center);

        // 保存草稿按钮
        Button(this.isLoading ? '保存中...' : '存草稿')
          .width(80)
          .height(35)
          .fontSize(14)
          .backgroundColor('#ff7d00')
          .enabled(!this.isLoading)
          .margin({ right: 10 })
          .onClick(() => {
            this.saveDraft();
          });

        Button(this.isLoading ? '提交中...' : '提交')
          .width(60)
          .height(35)
          .fontSize(14)
          .backgroundColor('#1677ff')
          .enabled(!this.isLoading)
          .onClick(() => {
            this.submitArticle();
          });
      }
      .width('100%')
      .padding({ left: 15, right: 15, top: 10, bottom: 10 })
      .backgroundColor('#fff');

      // 表单区域
      Scroll() {
        Column() {
          // 标题输入
          Column() {
            Text('文章标题')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333')
              .margin({ bottom: 10 });

            TextInput({ placeholder: '请输入文章标题（最多 200 字符）', text: this.title })
              .width('100%')
              .height(50)
              .borderRadius(8)
              .padding({ left: 15, right: 15 })
              .backgroundColor('#f5f5f5')
              .maxLength(200)
              .onChange((value) => {
                this.title = value;
              });

            Text(`${this.title.length}/200`)
              .fontSize(12)
              .fontColor('#999')
              .width('100%')
              .textAlign(TextAlign.End)
              .margin({ top: 5 });
          }
          .width('100%')
          .margin({ bottom: 25 });

          // 内容输入
          Column() {
            Text('文章内容')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333')
              .margin({ bottom: 10 });

            TextArea({ placeholder: '请输入文章内容（最多 10000 字符）', text: this.content })
              .width('100%')
              .height(400)
              .borderRadius(8)
              .padding({ left: 15, right: 15, top: 15, bottom: 15 })
              .backgroundColor('#f5f5f5')
              .maxLength(10000)
              .onChange((value) => {
                this.content = value;
              });

            Text(`${this.content.length}/10000`)
              .fontSize(12)
              .fontColor('#999')
              .width('100%')
              .textAlign(TextAlign.End)
              .margin({ top: 5 });
          }
          .width('100%');
        }
        .width('100%')
        .padding(20)
        .backgroundColor('#fff');
      }
      .layoutWeight(1)
      .width('100%')
      .backgroundColor('#f5f5f5');
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5');
  }
}
