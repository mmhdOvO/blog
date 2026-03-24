import { httpUtil } from '../utils/HttpUtil';
import type { ApiResult, LoginData, LoginRequest, RegisterRequest, User } from '../model/DataModel';
import dataStorage from '@ohos.data.storage';
import common from '@ohos.app.ability.common';

// 更新用户数据接口
interface UpdateUserData {
  username?: string;
  password?: string;
  nickname?: string;
  role?: string;
}

class UserService {
  private storage: dataStorage.Storage | null = null;
  private currentUser: User | null = null;

  /**
   * 初始化数据存储
   */
  async initStorage(context: common.UIAbilityContext): Promise<void> {
    this.storage = await dataStorage.getStorage(context.filesDir + '/myStore');
    // 读取已保存的 token
    const savedToken = await this.storage.getSync('token', '') as string;
    if (savedToken) {
      httpUtil.setToken(savedToken);
    }
    // 读取已保存的用户信息
    const savedUser = await this.storage.getSync('user', '') as string;
    if (savedUser && savedUser !== '') {
      try {
        this.currentUser = JSON.parse(savedUser);
      } catch (e) {
        console.error('解析用户信息失败');
      }
    }
  }

  /**
   * 登录
   */
  async login(loginRequest: LoginRequest): Promise<LoginData> {
    const result = await httpUtil.post<ApiResult<LoginData>>('/login', loginRequest, false);
    if (result.code === 200 && result.data) {
      // 保存 token 和用户信息
      httpUtil.setToken(result.data.token);
      this.currentUser = result.data.user;
      if (this.storage) {
        await this.storage.putSync('token', result.data.token);
        await this.storage.putSync('user', JSON.stringify(result.data.user));
        await this.storage.flushSync();
      }
      return result.data;
    }
    throw new Error(result.message || '登录失败');
  }

  /**
   * 注册
   */
  async register(registerRequest: RegisterRequest): Promise<User> {
    const result = await httpUtil.post<ApiResult<User>>('/register', registerRequest, false);
    if (result.code === 200 && result.data) {
      return result.data;
    }
    throw new Error(result.message || '注册失败');
  }

  /**
   * 退出登录
   */
  async logout(): Promise<void> {
    httpUtil.clearToken();
    this.currentUser = null;
    if (this.storage) {
      await this.storage.deleteSync('token');
      await this.storage.deleteSync('user');
      await this.storage.flushSync();
    }
  }

  /**
   * 获取当前登录用户
   */
  getCurrentUser(): User | null {
    // 如果内存中没有用户信息，但存储中有，尝试读取
    if (!this.currentUser && this.storage) {
      try {
        const savedUser = this.storage.getSync('user', '') as string;
        if (savedUser && savedUser !== '') {
          this.currentUser = JSON.parse(savedUser);
        }
      } catch (e) {
        console.error('获取用户信息失败');
      }
    }
    return this.currentUser;
  }

  /**
   * 设置当前用户
   */
  setCurrentUser(user: User): void {
    this.currentUser = user;
  }

  /**
   * 判断是否已登录（仅检查内存中的 token，用于快速判断）
   */
  isLoggedIn(): boolean {
    return !!httpUtil.getToken();
  }

  /**
   * 验证登录状态的有效性（检查本地存储中是否有用户信息）
   * 解决 DevEco 热重载/重新安装时内存 token 残留但本地存储已清空的问题
   */
  async validateLoginState(): Promise<boolean> {
    // 如果内存中没有 token，直接返回未登录
    if (!httpUtil.getToken()) {
      return false;
    }

    // 如果存储未初始化，先尝试从存储中读取验证
    if (!this.currentUser && this.storage) {
      try {
        const savedUser = await this.storage.getSync('user', '') as string;
        if (!savedUser || savedUser === '') {
          // 存储中没有用户信息，token 无效，清理内存中的 token
          httpUtil.clearToken();
          return false;
        }
        this.currentUser = JSON.parse(savedUser);
      } catch (e) {
        // 读取失败，token 无效
        httpUtil.clearToken();
        return false;
      }
    }

    // 双重验证：内存中的用户信息也必须存在
    return !!this.currentUser;
  }

  /**
   * 获取用户列表（管理员）
   */
  async getUserList(): Promise<User[]> {
    const result = await httpUtil.get<ApiResult<User[]>>('/users');
    if (result.code === 200) {
      return result.data;
    }
    throw new Error(result.message || '获取用户列表失败');
  }

  /**
   * 根据 ID 获取用户
   */
  async getUserById(id: number): Promise<User> {
    const result = await httpUtil.get<ApiResult<User>>(`/users/${id}`);
    if (result.code === 200) {
      return result.data;
    }
    throw new Error(result.message || '获取用户信息失败');
  }

  /**
   * 删除用户（管理员）
   */
  async deleteUser(id: number): Promise<void> {
    const result = await httpUtil.delete<ApiResult<void>>(`/users/${id}`);
    if (result.code !== 200) {
      throw new Error(result.message || '删除用户失败');
    }
  }

  /**
   * 更新用户信息（管理员）
   */
  async updateUser(id: number, userData: UpdateUserData): Promise<User> {
    const result = await httpUtil.put<ApiResult<User>>(`/users/${id}`, userData);
    if (result.code === 200) {
      return result.data;
    }
    throw new Error(result.message || '更新用户失败');
  }
}

export const userService = new UserService();
