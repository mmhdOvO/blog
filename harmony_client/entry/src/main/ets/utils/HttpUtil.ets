import http from '@ohos.net.http';
import hilog from '@ohos.hilog';
import promptAction from '@ohos.promptAction';

// 后端 API 基础地址
const BASE_URL = 'http://10.0.2.2:8082'; // 鸿蒙模拟器访问本地主机使用 10.0.2.2

// 定义响应结果接口
interface HttpResponse {
  responseCode: number;
  result: string | object;
}

// 错误响应接口
interface ErrorResponse {
  message?: string;
}

class HttpUtil {
  private token: string = '';

  setToken(token: string): void {
    this.token = token;
  }

  clearToken(): void {
    this.token = '';
  }

  getToken(): string {
    return this.token;
  }

  /**
   * 通用请求方法
   */
  async request<T>(
    url: string,
    method: http.RequestMethod,
    data?: object,
    needAuth: boolean = true
  ): Promise<T> {
    const httpRequest = http.createHttp();
    const fullUrl = `${BASE_URL}${url}`;

    hilog.info(0x0000, 'HttpUtil', '请求地址: %{public}s, 方法: %{public}d', fullUrl, method);

    let header: Record<string, string> = {
      'Content-Type': 'application/json'
    };

    if (needAuth && this.token) {
      header['Authorization'] = `Bearer ${this.token}`;
    }

    try {
      let response = await httpRequest.request(fullUrl, {
        method: method,
        header: header,
        extraData: data ? JSON.stringify(data) : undefined,
        readTimeout: 15000,
        connectTimeout: 15000
      }) as HttpResponse;

      hilog.info(0x0000, 'HttpUtil', '响应状态码: %{public}d', response.responseCode);

      if (response.responseCode === 401) {
        promptAction.showToast({ message: '登录已过期，请重新登录' });
        throw new Error('Unauthorized');
      }

      if (response.responseCode >= 200 && response.responseCode < 300) {
        let result: T;
        if (typeof response.result === 'string') {
          result = JSON.parse(response.result) as T;
        } else {
          result = response.result as T;
        }
        return result;
      } else {
        let errorMsg = `请求失败，状态码: ${response.responseCode}`;
        try {
          if (typeof response.result === 'string') {
            let errorResult = JSON.parse(response.result) as ErrorResponse;
            errorMsg = errorResult.message || errorMsg;
          }
        } catch (e) {
          // ignore
        }
        throw new Error(errorMsg);
      }
    } catch (err) {
      if (err instanceof Error) {
        hilog.error(0x0000, 'HttpUtil', '请求错误: %{public}s', err.message);
        throw err;
      }
      hilog.error(0x0000, 'HttpUtil', '请求错误: 未知错误类型');
      throw new Error('请求失败');
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * GET 请求
   */
  get<T>(url: string, needAuth: boolean = true): Promise<T> {
    return this.request<T>(url, http.RequestMethod.GET, undefined, needAuth);
  }

  /**
   * POST 请求
   */
  post<T>(url: string, data?: object, needAuth: boolean = true): Promise<T> {
    return this.request<T>(url, http.RequestMethod.POST, data, needAuth);
  }

  /**
   * PUT 请求
   */
  put<T>(url: string, data: object, needAuth: boolean = true): Promise<T> {
    return this.request<T>(url, http.RequestMethod.PUT, data, needAuth);
  }

  /**
   * DELETE 请求
   */
  delete<T>(url: string, needAuth: boolean = true): Promise<T> {
    return this.request<T>(url, http.RequestMethod.DELETE, undefined, needAuth);
  }
}

export const httpUtil = new HttpUtil();
