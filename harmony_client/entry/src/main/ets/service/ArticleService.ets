import { httpUtil } from '../utils/HttpUtil';
import type { ApiResult, Article, ArticleRequest } from '../model/DataModel';

class ArticleService {
  /**
   * 创建文章
   */
  async createArticle(article: ArticleRequest): Promise<Article> {
    const result = await httpUtil.post<ApiResult<Article>>('/articles', article);
    if (result.code === 200) {
      return result.data;
    } else if (result.code === 202) {
      // 202 表示文章需人工复核，抛出特殊消息
      throw new Error('需人工审核');
    }
    throw new Error(result.message || '创建文章失败');
  }

  /**
   * 获取文章详情
   */
  async getArticleById(id: number): Promise<Article> {
    const result = await httpUtil.get<ApiResult<Article>>(`/articles/${id}`);
    if (result.code === 200) {
      return result.data;
    }
    throw new Error(result.message || '获取文章详情失败');
  }

  /**
   * 获取文章列表
   * @param userId 可选，按用户 ID 过滤
   * @param keyword 可选，搜索关键字（标题或作者）
   */
  async getArticleList(userId?: number, keyword?: string): Promise<Article[]> {
    let url = '/articles';
    const params: string[] = [];
    if (userId !== undefined) {
      params.push(`userId=${userId}`);
    }
    if (keyword !== undefined && keyword !== '') {
      params.push(`keyword=${encodeURIComponent(keyword)}`);
    }
    if (params.length > 0) {
      url += `?${params.join('&')}`;
    }
    const result = await httpUtil.get<ApiResult<Article[]>>(url);
    if (result.code === 200) {
      return result.data;
    }
    throw new Error(result.message || '获取文章列表失败');
  }

  /**
   * 更新文章
   */
  async updateArticle(id: number, article: ArticleRequest): Promise<Article> {
    const result = await httpUtil.put<ApiResult<Article>>(`/articles/${id}`, article);
    if (result.code === 200) {
      return result.data;
    }
    throw new Error(result.message || '更新文章失败');
  }

  /**
   * 删除文章
   */
  async deleteArticle(id: number): Promise<void> {
    const result = await httpUtil.delete<ApiResult<void>>(`/articles/${id}`);
    if (result.code !== 200) {
      throw new Error(result.message || '删除文章失败');
    }
  }

  /**
   * 保存草稿
   */
  async saveDraft(article: ArticleRequest): Promise<Article> {
    const result = await httpUtil.post<ApiResult<Article>>('/articles/draft', article);
    if (result.code === 200) {
      return result.data;
    }
    throw new Error(result.message || '保存草稿失败');
  }

  /**
   * 更新草稿
   */
  async updateDraft(id: number, article: ArticleRequest): Promise<Article> {
    const result = await httpUtil.put<ApiResult<Article>>(`/articles/draft/${id}`, article);
    if (result.code === 200) {
      return result.data;
    }
    throw new Error(result.message || '更新草稿失败');
  }

  /**
   * 发布草稿（将草稿转为已发布）
   */
  async publishDraft(id: number): Promise<Article> {
    const result = await httpUtil.post<ApiResult<Article>>(`/articles/${id}/publish`, undefined);
    if (result.code === 200) {
      return result.data;
    } else if (result.code === 202) {
      // 202 表示文章需人工复核，抛出特殊消息
      throw new Error('需人工审核');
    }
    throw new Error(result.message || '发布失败');
  }
}

export const articleService = new ArticleService();
