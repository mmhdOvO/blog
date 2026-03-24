import { httpUtil } from '../utils/HttpUtil';
import type { ApiResult, ReviewAppeal } from '../model/DataModel';

class AppealService {
  /**
   * 发起复核申诉
   * @param articleId 文章ID
   * @param reason 申诉理由（可选）
   */
  async createAppeal(articleId: number, reason?: string): Promise<string> {
    let url = `/appeals/article/${articleId}`;
    if (reason) {
      url += `?reason=${encodeURIComponent(reason)}`;
    }
    // 不发送请求体，因为后端使用 @RequestParam 接收参数
    const result = await httpUtil.post<ApiResult<string>>(url, undefined);
    if (result.code === 200) {
      return result.message || '申诉成功';
    }
    throw new Error(result.message || '申诉失败');
  }

  /**
   * 管理员获取待处理的申诉列表
   */
  async getPendingAppeals(): Promise<ReviewAppeal[]> {
    const result = await httpUtil.get<ApiResult<ReviewAppeal[]>>('/appeals/admin/pending');
    if (result.code === 200) {
      return result.data;
    }
    throw new Error(result.message || '获取申诉列表失败');
  }

  /**
   * 批准申诉
   * @param appealId 申诉ID
   * @param note 处理备注（可选）
   */
  async approveAppeal(appealId: number, note?: string): Promise<string> {
    let url = `/appeals/admin/${appealId}/approve`;
    if (note) {
      url += `?note=${encodeURIComponent(note)}`;
    }
    const result = await httpUtil.post<ApiResult<string>>(url, {} as Record<string, never>);
    if (result.code === 200) {
      return result.message || '批准成功';
    }
    throw new Error(result.message || '批准失败');
  }

  /**
   * 驳回申诉
   * @param appealId 申诉ID
   * @param note 处理备注（可选）
   */
  async rejectAppeal(appealId: number, note?: string): Promise<string> {
    let url = `/appeals/admin/${appealId}/reject`;
    if (note) {
      url += `?note=${encodeURIComponent(note)}`;
    }
    const result = await httpUtil.post<ApiResult<string>>(url, {} as Record<string, never>);
    if (result.code === 200) {
      return result.message || '驳回成功';
    }
    throw new Error(result.message || '驳回失败');
  }
}

export const appealService = new AppealService();
