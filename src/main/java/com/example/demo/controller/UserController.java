package com.example.demo.controller;

import com.example.demo.common.Result;
import com.example.demo.dto.LoginRequest;
import com.example.demo.dto.RegisterRequest;
import com.example.demo.entity.User;
import com.example.demo.mapper.UserMapper;
import com.example.demo.service.UserService;
import com.example.demo.utils.JwtUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Validated
@RestController
public class UserController {

    private static final Logger log = LoggerFactory.getLogger(UserController.class);

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private UserService userService;

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private PasswordEncoder passwordEncoder;

    // 根据 ID 查询用户
    @GetMapping("/users/{id}")
    public Result getUserById(@PathVariable Integer id) {
        User user = userMapper.findById(id);
        if (user == null) {
            return Result.error(404, "用户不存在");
        }
        return Result.success(user);
    }

    // 查询用户列表（支持按用户名过滤）
    @GetMapping("/users")
    public Result getUsers(@RequestParam(required = false) String username) {
        if (username != null) {
            User user = userMapper.findByUsername(username);
            if (user == null) {
                return Result.error(404, "用户不存在");
            }
            return Result.success(user);
        }
        List<User> users = userMapper.findAll();
        return Result.success(users);
    }

    // 新增用户（管理员接口，可能需权限）
    @PostMapping("/users")
    public Result addUser(@RequestBody User user) {
        if (user != null && user.getPassword() != null && !user.getPassword().trim().isEmpty()) {
            user.setPassword(passwordEncoder.encode(user.getPassword()));
        }
        if (user != null && (user.getRole() == null || user.getRole().trim().isEmpty())) {
            user.setRole("USER");
        }
        int result = userMapper.insertUser(user);
        if (result > 0) {
            return Result.success("增添成功");
        } else {
            return Result.error(500, "增添失败");
        }
    }

    // 删除用户
    @DeleteMapping("/users/{id}")
    public Result deleteUserById(@PathVariable Integer id) {
        int result = userMapper.deleteById(id);
        if (result > 0) {
            return Result.success("删除成功");
        } else {
            return Result.error(404, "用户不存在");
        }
    }

    // 更新用户信息
    @PutMapping("/users/{id}")
    public Result updateById(@PathVariable Integer id, @RequestBody User user) {
        user.setId(id);
        if (user.getPassword() != null && user.getPassword().trim().isEmpty()) {
            user.setPassword(null);
        }
        if (user.getPassword() != null) {
            user.setPassword(passwordEncoder.encode(user.getPassword()));
        }
        int result = userMapper.updateById(user);
        if (result > 0) {
            return Result.success("修改成功");
        } else {
            return Result.error(404, "用户不存在");
        }
    }

    // 用户登录
    @PostMapping("/login")
    public Result login(@Valid @RequestBody LoginRequest loginRequest) {
        String username = loginRequest.getUsername();
        String password = loginRequest.getPassword();

        User user = userService.login(username, password);
        if (user != null) {
            String token = jwtUtil.generateToken(user.getUsername());
            Map<String, Object> data = new HashMap<>();
            data.put("token", token);
            data.put("user", user);
            return Result.success(data);
        } else {
            return Result.error(401, "用户名或密码错误");
        }
    }

    // 用户注册
    @PostMapping("/register")
    public Result register(@Valid @RequestBody RegisterRequest registerRequest) {
        try {
            User user = userService.register(registerRequest);
            return Result.success(user);
        } catch (RuntimeException e) {
            return Result.error(400, e.getMessage());
        }
    }
}