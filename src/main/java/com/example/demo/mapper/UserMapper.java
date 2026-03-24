package com.example.demo.mapper;

import com.example.demo.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper   // 也可以在主类上加 @MapperScan，二选一
public interface UserMapper {

    @Select("SELECT * FROM user WHERE id = #{id}")
    User findById(Integer id);

    // 你也可以用 XML 方式，下面会演示
    List<User> findAll();
    User findByUsername(@Param("username") String username);

    int insertUser(User user);

    int deleteById(Integer id);

    int updateById(User user);
}