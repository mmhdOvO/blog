/**
 * 统一响应结果
 */
export interface ApiResult<T> {
  code: number;
  message: string;
  data: T;
}

/**
 * 用户信息
 */
export interface User {
  id: number;
  username: string;
  nickname: string;
  role: string;
  createTime: string;
}

/**
 * 登录请求
 */
export interface LoginRequest {
  username: string;
  password: string;
}

/**
 * 注册请求
 */
export interface RegisterRequest {
  username: string;
  password: string;
  nickname?: string;
}

/**
 * 登录响应数据
 */
export interface LoginData {
  token: string;
  user: User;
}

/**
 * 文章信息
 */
export interface Article {
  id: number;
  title: string;
  content: string;
  userId: number;
  viewCount: number;
  createTime: string;
  status?: number; // 文章状态：0-待审核，1-合规(已发布)，2-不合规(被拦截)，3-复核中，4-复核通过，5-复核拒绝
}

/**
 * 复核申诉信息
 */
export interface ReviewAppeal {
  id: number;
  articleId: number;
  userId: number;
  reason?: string;
  status: number; // 0-待处理，1-已批准，2-已驳回
  createTime: string;
  handleTime?: string;
  handlerId?: number;
  handlerNote?: string;
}

/**
 * 创建/更新文章请求
 */
export interface ArticleRequest {
  title: string;
  content: string;
}
