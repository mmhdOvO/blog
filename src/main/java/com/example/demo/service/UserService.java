package com.example.demo.service;

import com.example.demo.dto.RegisterRequest;
import com.example.demo.entity.User;

public interface UserService {


    /**
     * 用户登录
     * @param username 用户名
     * @param password 密码
     * @return 登录成功返回用户对象（不含密码），失败返回 null
     */
    User login(String username, String password);

    /**
     * 用户注册

     */
    User register(RegisterRequest request);

    User getUserByUsername(String username);


}
