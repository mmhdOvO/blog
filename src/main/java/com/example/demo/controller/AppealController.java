package com.example.demo.controller;

import com.example.demo.common.Result;
import com.example.demo.entity.Article;
import com.example.demo.entity.ReviewAppeal;
import com.example.demo.entity.User;
import com.example.demo.mapper.ArticleMapper;
import com.example.demo.mapper.ReviewAppealMapper;
import com.example.demo.service.UserService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.Date;
import java.util.List;


@RestController
@RequestMapping("/appeals")
public class AppealController {

    private static final Logger log = LoggerFactory.getLogger(ArticleController.class);

    @Autowired
    private ReviewAppealMapper appealMapper;
    @Autowired
    private ArticleMapper articleMapper;
    @Autowired
    private UserService userService;

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

    @PostMapping("/article/{articleId}")
    public Result createAppeal(@PathVariable Integer articleId,
                               @RequestParam(required = false) String reason) {
        User currentUser = getCurrentUser();
        if (currentUser == null) return Result.error(401, "未登录");

        // 校验文章是否存在且属于当前用户
        Article article = articleMapper.findById(articleId);
        if (article == null) return Result.error(404, "文章不存在");
        if (!article.getUserId().equals(currentUser.getId())) {
            return Result.error(403, "无权操作他人的文章");
        }
        // 校验文章状态是否为 2（不合规）
        if (article.getStatus() != 2) {
            return Result.error(400, "当前状态不允许发起复核");
        }
        // 检查是否已存在复核申请
        ReviewAppeal existing = appealMapper.findByArticleId(articleId);
        if (existing != null) {
            return Result.error(400, "已发起过复核申请，请勿重复提交");
        }

        // 创建复核申请
        ReviewAppeal appeal = new ReviewAppeal();
        appeal.setArticleId(articleId);
        appeal.setUserId(currentUser.getId());
        appeal.setReason(reason);
        appeal.setStatus(0); // 待处理
        appeal.setCreateTime(new Date());
        appealMapper.insertAppeal(appeal);

        // 更新文章状态为 3（复核中）
        articleMapper.updateStatus(articleId, 3);

        return Result.success("复核申请已提交，请等待管理员处理");
    }

    // 管理员：获取待处理的复核列表
    @GetMapping("/admin/pending")
    @PreAuthorize("hasRole('ADMIN')")
    public Result getPendingAppeals() {
        List<ReviewAppeal> list = appealMapper.findByStatus(0); // 0-待处理
        // 可以关联查询文章信息，简化起见仅返回复核列表，前端再调用文章详情
        return Result.success(list);
    }

    // 管理员：批准复核
    @PostMapping("/admin/{appealId}/approve")
    @PreAuthorize("hasRole('ADMIN')")
    public Result approveAppeal(@PathVariable Integer appealId,
                                @RequestParam(required = false) String note) {
        return handleAppeal(appealId, note, true);
    }

    // 管理员：驳回复核
    @PostMapping("/admin/{appealId}/reject")
    @PreAuthorize("hasRole('ADMIN')")
    public Result rejectAppeal(@PathVariable Integer appealId,
                               @RequestParam(required = false) String note) {
        return handleAppeal(appealId, note, false);
    }

    private Result handleAppeal(Integer appealId, String note, boolean approve) {
        User admin = getCurrentUser();
        if (admin == null) return Result.error(401, "未登录");

        ReviewAppeal appeal = appealMapper.findById(appealId); // 需要增加 findById 方法
        if (appeal == null) return Result.error(404, "复核申请不存在");
        if (appeal.getStatus() != 0) {
            return Result.error(400, "该申请已处理");
        }

        // 更新申请状态
        appeal.setStatus(approve ? 1 : 2);
        appeal.setHandleTime(new Date());
        appeal.setHandlerId(admin.getId());
        appeal.setHandlerNote(note);
        appealMapper.updateAppeal(appeal);

        // 更新文章状态
        int articleStatus = approve ? 4 : 5; // 复核通过 或 复核拒绝
        articleMapper.updateStatus(appeal.getArticleId(), articleStatus);

        return Result.success(approve ? "已批准" : "已驳回");
    }






}
