package com.example.demo.service;

import com.example.demo.entity.Article;
import com.example.demo.entity.User;

import java.util.List;

public interface ArticleService {

    Article createArticle(Article article, Integer userId);

    Article getArticleById(Integer id);

    List<Article> getAllArticles(Integer userId, String keyword);

    Article updateArticle(Article article, User currentUser);

    void deleteArticle(Integer id, User currentUser);

    void incrementViewCount(Integer id);

    void updateStatus(Integer id, Integer status);

    Article createDraft(Article article, Integer userId);

    Article updateDraft(Article article, User currentUser);
}
