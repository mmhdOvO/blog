package com.example.demo.entity;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Size;
import java.util.Date;

public class Article {
    private Integer id;

    @NotBlank(message = "文章标题不能为空")
    @Size(max = 200, message = "文章标题不能超过 200 个字符")
    private String title;

    @NotBlank(message = "文章内容不能为空")
    @Size(max = 10000, message = "文章内容不能超过 10000 个字符")
    private String content;
    private Integer userId;
    private Integer viewCount;
    private Date createTime;



    private Integer status = 0; // 默认状态：0-待审核，1-已通过，2-需人工复核

    // getter/setter 省略，请自行生成
    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }

    public Integer getViewCount() { return viewCount; }
    public void setViewCount(Integer viewCount) { this.viewCount = viewCount; }

    public Date getCreateTime() { return createTime; }
    public void setCreateTime(Date createTime) { this.createTime = createTime; }

    public Integer getStatus() {
        return status;
    }

    public void setStatus(Integer status) {
        this.status = status;
    }
}