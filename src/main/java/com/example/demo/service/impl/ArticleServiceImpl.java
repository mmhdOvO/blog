package com.example.demo.service.impl;

import com.example.demo.entity.Article;
import com.example.demo.entity.User;
import com.example.demo.service.ArticleService;
import com.example.demo.mapper.ArticleMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ArticleServiceImpl implements ArticleService {

    @Autowired
    private ArticleMapper articleMapper;
    @Override
    public Article createArticle(Article article, Integer userId) {
        if (userId == null) {
            throw new IllegalArgumentException("用户ID不能为空，请确认用户已登录且用户信息完整");
        }
        article.setUserId(userId);
        article.setViewCount(0);
        articleMapper.insertArticle(article);
        return article;
    }

    @Override
    public Article getArticleById(Integer id) {
        return articleMapper.findById(id);
    }

    @Override
    public List<Article> getAllArticles(Integer userId, String keyword) {
        return articleMapper.findAll(userId, keyword);
    }

    @Override
    public Article updateArticle(Article article, User currentUser) {
        if (currentUser == null || currentUser.getId() == null) {
            throw new RuntimeException("未登录");
        }
        String role = currentUser.getRole() == null ? "USER" : currentUser.getRole().trim().toUpperCase();

        int rows;
        if ("ADMIN".equals(role)) {
            rows = articleMapper.updateArticleAsAdmin(article);
        } else {
            article.setUserId(currentUser.getId());
            rows = articleMapper.updateArticle(article);
        }

        if (rows == 0) {
            throw new RuntimeException("更新失败，文章不存在或无权修改");
        }
        return articleMapper.findById(article.getId());
    }

    @Override
    public void deleteArticle(Integer id, User currentUser) {
        Article article = articleMapper.findById(id);
        if (article == null) {
            throw new RuntimeException("文章不存在");
        }
        if (currentUser == null || currentUser.getId() == null) {
            throw new RuntimeException("未登录");
        }
        String role = currentUser.getRole() == null ? "USER" : currentUser.getRole().trim().toUpperCase();
        if (!"ADMIN".equals(role) && !article.getUserId().equals(currentUser.getId())) {
            throw new RuntimeException("无权删除他人文章");
        }
        articleMapper.deleteById(id);

    }

    @Override
    public void incrementViewCount(Integer id) {
        articleMapper.incrementViewCount(id);
    }

    @Override
    public void updateStatus(Integer id, Integer status) {
        articleMapper.updateStatus(id, status);
    }

    @Override
    public Article createDraft(Article article, Integer userId) {
        if (userId == null) {
            throw new IllegalArgumentException("用户ID不能为空，请确认用户已登录且用户信息完整");
        }
        article.setUserId(userId);
        article.setViewCount(0);
        article.setStatus(0); // 草稿状态
        articleMapper.insertArticle(article);
        return article;
    }

    @Override
    public Article updateDraft(Article article, User currentUser) {
        if (currentUser == null || currentUser.getId() == null) {
            throw new RuntimeException("未登录");
        }

        Article existing = articleMapper.findById(article.getId());
        if (existing == null) {
            throw new RuntimeException("草稿不存在");
        }

        // 验证权限：只能修改自己的草稿
        if (!existing.getUserId().equals(currentUser.getId())) {
            throw new RuntimeException("无权修改他人的草稿");
        }

        // 验证状态：只能修改草稿状态的文章
        if (existing.getStatus() != 0) {
            throw new RuntimeException("只能修改草稿状态的文章");
        }

        article.setUserId(currentUser.getId());
        article.setStatus(0); // 保持草稿状态
        articleMapper.updateArticle(article);
        return articleMapper.findById(article.getId());
    }
}
