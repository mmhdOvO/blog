import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { userService } from '../service/UserService';
import type { LoginRequest } from '../model/DataModel';
import common from '@ohos.app.ability.common';

@Entry
@Component
struct LoginPage {
  @State username: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;
  private context: common.UIAbilityContext | null = null;

  async aboutToAppear(): Promise<void> {
    this.context = getContext(this) as common.UIAbilityContext;
    
    // 先初始化存储（确保从本地存储读取最新状态）
    if (this.context) {
      await userService.initStorage(this.context);
    }
    
    // 验证登录状态的有效性（解决 DevEco 热重载缓存问题）
    const isValidLogin = await userService.validateLoginState();
    if (isValidLogin) {
      router.replaceUrl({ url: 'pages/Index' });
    } else {
      // 登录无效，清理残留状态
      await userService.logout();
    }
  }

  /**
   * 处理登录
   */
  async handleLogin(): Promise<void> {
    if (!this.username.trim()) {
      promptAction.showToast({ message: '请输入用户名' });
      return;
    }
    if (!this.password.trim()) {
      promptAction.showToast({ message: '请输入密码' });
      return;
    }

    this.isLoading = true;
    try {
      const loginRequest: LoginRequest = {
        username: this.username.trim(),
        password: this.password.trim()
      };
      
      const result = await userService.login(loginRequest);
      promptAction.showToast({ message: '登录成功' });
      
      // 初始化存储
      if (this.context) {
        await userService.initStorage(this.context);
      }
      
      router.replaceUrl({ url: 'pages/Index' });
    } catch (err) {
      if (err instanceof Error) {
        promptAction.showToast({ message: err.message || '登录失败' });
      } else {
        promptAction.showToast({ message: '登录失败' });
      }
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 跳转到注册页面
   */
  goToRegister(): void {
    router.pushUrl({ url: 'pages/Register' });
  }

  build() {
    Column() {
      // 标题
      Text('博客系统')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 80, bottom: 60 })
        .fontColor('#1890ff');

      // 用户名输入框
      TextInput({ placeholder: '请输入用户名', text: this.username })
        .width('80%')
        .height(50)
        .margin({ bottom: 20 })
        .borderRadius(8)
        .padding({ left: 15 })
        .backgroundColor('#f5f5f5')
        .onChange((value) => {
          this.username = value;
        });

      // 密码输入框
      TextInput({ placeholder: '请输入密码', text: this.password })
        .width('80%')
        .height(50)
        .margin({ bottom: 30 })
        .borderRadius(8)
        .padding({ left: 15 })
        .backgroundColor('#f5f5f5')
        .type(InputType.Password)
        .onChange((value) => {
          this.password = value;
        });

      // 登录按钮
      Button(this.isLoading ? '登录中...' : '登录')
        .width('80%')
        .height(50)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .backgroundColor('#1677ff')
        .borderRadius(8)
        .enabled(!this.isLoading)
        .onClick(() => {
          this.handleLogin();
        });

      // 注册链接
      Text('没有账号？去注册')
        .fontSize(14)
        .fontColor('#1890ff')
        .margin({ top: 20 })
        .onClick(() => {
          this.goToRegister();
        });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#ffffff');
  }
}
