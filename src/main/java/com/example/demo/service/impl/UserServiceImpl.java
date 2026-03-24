package com.example.demo.service.impl;

import com.example.demo.dto.RegisterRequest;
import com.example.demo.entity.User;
import com.example.demo.mapper.UserMapper;
import com.example.demo.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class UserServiceImpl implements UserService {

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private PasswordEncoder passwordEncoder;  // 注入加密器



    @Override
    public User login(String username, String password) {


        // 1. 根据用户名查询用户
        User user = userMapper.findByUsername(username);
        // 2. 判断用户是否存在且密码匹配（使用 matches 方法比对明文和密文）
        if (user != null && passwordEncoder.matches(password, user.getPassword())) {
            // 登录成功，返回用户信息（为了安全，可以清除密码后再返回）
            user.setPassword(null); // 避免返回密码字段
            return user;
        }
        // 登录失败
        return null;
    }

    @Override
    public User register(RegisterRequest request) {
        User existing = userMapper.findByUsername(request.getUsername());
        if (existing != null) {
            throw new RuntimeException("用户名已存在");
        }
        // 加密密码
        String encodedPassword = passwordEncoder.encode(request.getPassword());

        User user = new User();
        user.setUsername(request.getUsername());
        user.setPassword(encodedPassword);
        user.setNickname(request.getNickname());
        user.setRole("USER");
        userMapper.insertUser(user);
        user.setPassword(null);
        return user;
    }
    @Override
    public User getUserByUsername(String username) {
        User user = userMapper.findByUsername(username);
        if(user != null) {
            user.setPassword(null);
        }
        return user;
    }
}