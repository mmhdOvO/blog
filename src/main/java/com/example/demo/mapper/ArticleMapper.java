package com.example.demo.mapper;

import com.example.demo.entity.Article;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface ArticleMapper {

    int insertArticle(Article article);

    Article findById(@Param("id") Integer id);

    List<Article> findAll(@Param("userId") Integer userId, @Param("keyword") String keyword);

    List<Article> findByStatus(@Param("status") Integer status);

    int updateArticle(Article article);

    int updateArticleAsAdmin(Article article);

    int deleteById(@Param("id") Integer id);

    int incrementViewCount(@Param("id") Integer id);

    int updateStatus(@Param("id") Integer id, @Param("status") Integer status);



}
