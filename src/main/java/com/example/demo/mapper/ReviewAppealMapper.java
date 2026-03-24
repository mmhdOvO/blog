package com.example.demo.mapper;

import com.example.demo.entity.ReviewAppeal;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ReviewAppealMapper {
    int insertAppeal(ReviewAppeal appeal);
    ReviewAppeal findById(@Param("id") Integer id);
    ReviewAppeal findByArticleId(@Param("articleId") Integer articleId);
    List<ReviewAppeal> findByStatus(@Param("status") Integer status);
    int updateAppeal(ReviewAppeal appeal);
}
