import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { userService } from '../service/UserService';
import type { RegisterRequest } from '../model/DataModel';

@Entry
@Component
struct RegisterPage {
  @State username: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State nickname: string = '';
  @State isLoading: boolean = false;

  /**
   * 处理注册
   */
  async handleRegister(): Promise<void> {
    if (!this.username.trim()) {
      promptAction.showToast({ message: '请输入用户名' });
      return;
    }
    if (this.username.trim().length < 3 || this.username.trim().length > 20) {
      promptAction.showToast({ message: '用户名长度必须在 3-20 个字符之间' });
      return;
    }
    if (!this.password.trim()) {
      promptAction.showToast({ message: '请输入密码' });
      return;
    }
    if (this.password.trim().length < 6 || this.password.trim().length > 20) {
      promptAction.showToast({ message: '密码长度必须在 6-20 个字符之间' });
      return;
    }
    if (this.password !== this.confirmPassword) {
      promptAction.showToast({ message: '两次输入的密码不一致' });
      return;
    }

    this.isLoading = true;
    try {
      const registerRequest: RegisterRequest = {
        username: this.username.trim(),
        password: this.password.trim(),
        nickname: this.nickname.trim() || undefined
      };
      
      await userService.register(registerRequest);
      promptAction.showToast({ message: '注册成功，请登录' });
      
      // 返回登录页面
      router.back();
    } catch (err) {
      if (err instanceof Error) {
        promptAction.showToast({ message: err.message || '注册失败' });
      } else {
        promptAction.showToast({ message: '注册失败' });
      }
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      // 标题
      Text('用户注册')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 60, bottom: 50 })
        .fontColor('#1890ff');

      // 用户名输入框
      TextInput({ placeholder: '请输入用户名（3-20字符）', text: this.username })
        .width('80%')
        .height(50)
        .margin({ bottom: 15 })
        .borderRadius(8)
        .padding({ left: 15 })
        .backgroundColor('#f5f5f5')
        .onChange((value) => {
          this.username = value;
        });

      // 昵称输入框（可选）
      TextInput({ placeholder: '请输入昵称（可选）', text: this.nickname })
        .width('80%')
        .height(50)
        .margin({ bottom: 15 })
        .borderRadius(8)
        .padding({ left: 15 })
        .backgroundColor('#f5f5f5')
        .onChange((value) => {
          this.nickname = value;
        });

      // 密码输入框
      TextInput({ placeholder: '请输入密码（6-20字符）', text: this.password })
        .width('80%')
        .height(50)
        .margin({ bottom: 15 })
        .borderRadius(8)
        .padding({ left: 15 })
        .backgroundColor('#f5f5f5')
        .type(InputType.Password)
        .onChange((value) => {
          this.password = value;
        });

      // 确认密码输入框
      TextInput({ placeholder: '请确认密码', text: this.confirmPassword })
        .width('80%')
        .height(50)
        .margin({ bottom: 30 })
        .borderRadius(8)
        .padding({ left: 15 })
        .backgroundColor('#f5f5f5')
        .type(InputType.Password)
        .onChange((value) => {
          this.confirmPassword = value;
        });

      // 注册按钮
      Button(this.isLoading ? '注册中...' : '注册')
        .width('80%')
        .height(50)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .backgroundColor('#1677ff')
        .borderRadius(8)
        .enabled(!this.isLoading)
        .onClick(() => {
          this.handleRegister();
        });

      // 返回登录链接
      Text('已有账号？返回登录')
        .fontSize(14)
        .fontColor('#1890ff')
        .margin({ top: 20 })
        .onClick(() => {
          router.back();
        });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#ffffff');
  }
}
