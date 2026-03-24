package com.example.demo.controller;

import com.example.demo.common.Result;
import com.example.demo.entity.Article;
import com.example.demo.entity.User;
import com.example.demo.service.ArticleService;
import com.example.demo.service.ContentReviewService;
import com.example.demo.service.UserService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.security.core.Authentication;

@Validated
@RestController
@RequestMapping("articles")
public class ArticleController {

    private static final Logger log = LoggerFactory.getLogger(ArticleController.class);

    @Autowired
    private ArticleService articleService;

    @Autowired
    private UserService userService;

    @Autowired
    private ContentReviewService contentReviewService;

    // 获取当前登录用户
    private User getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            return null;
        }

        Object principal = authentication.getPrincipal();

        if (principal instanceof UserDetails) {
            String username = ((UserDetails) principal).getUsername();
            User user = userService.getUserByUsername(username);
            log.debug("Current user: username={}, id={}", username, user != null ? user.getId() : "null");
            return user;
            //return userService.getUserByUsername(username);
        }
        return null;
    }

    // 创建文章
    @PostMapping
    public Result createArticle(@Valid @RequestBody Article article) {
        User currentUser = getCurrentUser();
        if (currentUser == null) {
            return Result.error(401, "未登录");
        }

        Article created = articleService.createArticle(article, currentUser.getId());

        boolean compliant = contentReviewService.isContentCompliant(article.getTitle(), article.getContent());
        if (compliant) {
            created.setStatus(1);
            articleService.updateStatus(created.getId(), 1);
            return Result.success(created);
        } else {
            created.setStatus(2);
            articleService.updateStatus(created.getId(), 2);
            Map<String, Object> data = new HashMap<>();
            data.put("articleId", created.getId());
            data.put("message", "文章可能包含违规内容，已进入人工复核流程");
            return Result.success(202, data, "文章需人工复核");
        }

//        // 审核内容
//        if (!contentReviewService.isContentCompliant(article.getTitle(), article.getContent())) {
//            return Result.error(400, "文章内容包含违规信息，请修改后重试");
//        }
//
//        Article created = articleService.createArticle(article, curentUser.getId());
//        return Result.success(created);
    }

    // 获取文章详情（同时增加阅读数）
    @GetMapping("/{id}")
    public Result getArticle(@PathVariable Integer id) {
        Article article = articleService.getArticleById(id);
        if (article == null) {
            return Result.error(404,"文章不存在");
        }
        articleService.incrementViewCount(id);
        return Result.success(article);
    }

    // 获取文章列表（可选按用户ID或关键字搜索）
    @GetMapping
    public Result getArticles(@RequestParam(required = false) Integer userId,
                              @RequestParam(required = false) String keyword) {
        List<Article> articles = articleService.getAllArticles(userId, keyword);
        return Result.success(articles);
    }

    // 更新文章
    @PutMapping("/{id}")
    public Result updateArticle(@PathVariable Integer id, @Valid @RequestBody Article article) {
        User currentUser = getCurrentUser();
        if (currentUser == null) {
            return Result.error(401,"未登录");
        }

        // 审核内容
        if (!contentReviewService.isContentCompliant(article.getTitle(), article.getContent())) {
            return Result.error(400, "文章内容包含违规信息，请修改后重试");
        }

        article.setId(id);
        try {
            Article updated = articleService.updateArticle(article, currentUser);
            return  Result.success(updated);
        } catch (RuntimeException e) {
            return Result.error(403,e.getMessage());
        }
    }

    // 删除文章
    @DeleteMapping("/{id}")
    public Result deleteArticle(@PathVariable Integer id) {
        User currentUser = getCurrentUser();
        if (currentUser == null) {
            return Result.error(401, "未登录");
        }
        try {
            articleService.deleteArticle(id, currentUser);
            return Result.success(null);
        } catch (RuntimeException e) {
            return Result.error(403, e.getMessage());
        }
    }

    // 保存草稿
    @PostMapping("/draft")
    public Result saveDraft(@Valid @RequestBody Article article) {
        User currentUser = getCurrentUser();
        if (currentUser == null) {
            return Result.error(401, "未登录");
        }

        Article draft = articleService.createDraft(article, currentUser.getId());
        return Result.success(draft);
    }

    // 更新草稿
    @PutMapping("/draft/{id}")
    public Result updateDraft(@PathVariable Integer id, @Valid @RequestBody Article article) {
        User currentUser = getCurrentUser();
        if (currentUser == null) {
            return Result.error(401, "未登录");
        }

        article.setId(id);
        try {
            Article updated = articleService.updateDraft(article, currentUser);
            return Result.success(updated);
        } catch (RuntimeException e) {
            return Result.error(403, e.getMessage());
        }
    }

    // 发布草稿（将草稿转为已发布状态）
    @PostMapping("/{id}/publish")
    public Result publishDraft(@PathVariable Integer id) {
        User currentUser = getCurrentUser();
        if (currentUser == null) {
            return Result.error(401, "未登录");
        }

        try {
            Article article = articleService.getArticleById(id);
            if (article == null) {
                return Result.error(404, "文章不存在");
            }

            // 验证是否是作者
            if (!article.getUserId().equals(currentUser.getId())) {
                return Result.error(403, "只能发布自己的文章");
            }

            // 验证是否是草稿状态
            if (article.getStatus() != 0) {
                return Result.error(400, "只能发布草稿状态的文章");
            }

            // 审核内容
            boolean compliant = contentReviewService.isContentCompliant(article.getTitle(), article.getContent());
            if (compliant) {
                articleService.updateStatus(id, 1);
                article.setStatus(1);
                return Result.success(article);
            } else {
                articleService.updateStatus(id, 2);
                article.setStatus(2);
                Map<String, Object> data = new HashMap<>();
                data.put("articleId", id);
                data.put("message", "文章可能包含违规内容，已进入人工复核流程");
                return Result.success(202, data, "文章需人工复核");
            }
        } catch (RuntimeException e) {
            return Result.error(500, e.getMessage());
        }
    }
}
