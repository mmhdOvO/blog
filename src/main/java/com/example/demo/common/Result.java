package com.example.demo.common;

public class Result {
    private int code;       // 状态码，例如 200 成功，401 未授权
    private String message; // 提示信息
    private Object data;    // 返回的数据

    public static Result success(Object data) {
        Result r = new Result();
        r.code = 200;
        r.message = "成功";
        r.data = data;
        return r;
    }

    public static Result success(int code, Object data, String message) {
        Result r = new Result();
        r.code = code;
        r.message = message;
        r.data = data;
        return r;
    }

    public static Result error(int code, String message) {
        Result r = new Result();
        r.code = code;
        r.message = message;
        r.data = null;
        return r;
    }

    // getter 和 setter 省略（可自行生成）
    // 必须为每个字段提供 getter 方法！
    public int getCode() { return code; }
    public String getMessage() { return message; }
    public Object getData() { return data; }

    // setter 可选，但如果有需要也可以加上
    public void setCode(int code) { this.code = code; }
    public void setMessage(String message) { this.message = message; }
    public void setData(Object data) { this.data = data; }
}
