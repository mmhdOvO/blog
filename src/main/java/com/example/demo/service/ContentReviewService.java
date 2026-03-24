package com.example.demo.service;

import com.example.demo.dto.DeepSeekRequest;
import com.example.demo.dto.DeepSeekResponse;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import javax.annotation.PostConstruct;
import java.util.Collections;

@Service
public class ContentReviewService {

    @Value("${deepseek.api.url}")
    private String apiUrl;

    @Value("${deepseek.api.key}")
    private String apiKey;

    @Value("${deepseek.model}")
    private String model;

    @Autowired
    private RestTemplate restTemplate;

    // 用于打印请求体的 JSON 转换器
    private final ObjectMapper objectMapper = new ObjectMapper();

    private static final Logger log = LoggerFactory.getLogger(ContentReviewService.class);

    @PostConstruct
    public void init() {
        log.info("DeepSeek API URL: {}", apiUrl);
        log.info("DeepSeek Model: {}", model);
        // 注意：不要打印 apiKey，避免泄露
    }

    /**
     * 审核文章内容是否合规
     * @param title   文章标题
     * @param content 文章内容
     * @return true 表示合规，false 表示不合规（或审核失败时保守返回 false）
     */
    public boolean isContentCompliant(String title, String content) {
        log.info("========== 开始内容审核 ==========");
        log.info("标题: {}", title);
        log.info("内容长度: {}", content == null ? 0 : content.length());

        // 1. 构建提示词，要求 DeepSeek 判断内容是否合规
        String prompt = String.format(
                "请审核以下文章标题和内容是否包含色情、暴力、政治敏感或其他违规内容。只需回答“合规”或“不合规”，不要有其他解释。\n\n标题：%s\n内容：%s",
                title, content
        );

        // 2. 构建请求体
        DeepSeekRequest request = new DeepSeekRequest();
        request.setModel(model);
        DeepSeekRequest.Message message = new DeepSeekRequest.Message("user", prompt);
        request.setMessages(Collections.singletonList(message));
        request.setTemperature(0.3); // 较低的温度使输出更确定

        // 3. 设置请求头
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.set("Authorization", "Bearer " + apiKey);

        HttpEntity<DeepSeekRequest> entity = new HttpEntity<>(request, headers);

        // 4. 发送请求并处理响应
        try {
            // 打印请求体（便于调试）
            String requestJson = objectMapper.writeValueAsString(request);
            log.debug("发送给 DeepSeek 的请求体: {}", requestJson);

            // 发送 POST 请求
            ResponseEntity<DeepSeekResponse> responseEntity = restTemplate.exchange(
                    apiUrl,
                    HttpMethod.POST,
                    entity,
                    DeepSeekResponse.class
            );

            // 打印响应状态码和头信息
            log.info("响应状态码: {}", responseEntity.getStatusCode());

            DeepSeekResponse response = responseEntity.getBody();
            if (response != null && response.getChoices() != null && !response.getChoices().isEmpty()) {
                String reply = response.getChoices().get(0).getMessage().getContent().trim();
                log.info("DeepSeek 回复: {}", reply);

                // 判断回复中是否包含“合规”（注意：可能返回“合规”或“不合规”或带标点符号的变体）
                // 先 trim 去除前后空白，再进行判断
                boolean compliant = reply.trim().contains("合规") && !reply.trim().contains("不合规");
                log.info("审核结果: {}", compliant ? "合规" : "不合规");
                return compliant;
            } else {
                log.warn("DeepSeek 响应为空或格式不正确");
            }
        } catch (RestClientException e) {
            // 网络异常、超时、4xx/5xx 等
            log.error("调用 DeepSeek API 时发生异常: {}", e.getMessage(), e);
            // 发生异常时，为安全起见，我们判定为不合规（拒绝文章保存）
            // 您也可以根据业务需求调整（例如返回 true 放行）
            return false;
        } catch (Exception e) {
            // 其他异常（如 JSON 解析）
            log.error("未知异常: {}", e.getMessage(), e);
            return false;
        } finally {
            log.info("========== 内容审核结束 ==========");
        }

        // 默认返回 false（如果响应无法解析）
        return false;
    }
}