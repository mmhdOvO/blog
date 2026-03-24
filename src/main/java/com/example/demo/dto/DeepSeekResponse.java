package com.example.demo.dto;

import java.util.List;

public class DeepSeekResponse {
    private List<Choice> choices;

    public static class Choice {
        private Message message;

        public static class Message {
            private String role;
            private String content;
            // getters and setters
            public String getRole() { return role; }
            public void setRole(String role) { this.role = role; }
            public String getContent() { return content; }
            public void setContent(String content) { this.content = content; }
        }
        public Message getMessage() { return message; }
        public void setMessage(Message message) { this.message = message; }
    }

    public List<Choice> getChoices() { return choices; }
    public void setChoices(List<Choice> choices) { this.choices = choices; }
}