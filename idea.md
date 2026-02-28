
# Quản trị Tmux và Điều phối Claude Code bằng Gemini theo Phương pháp BMAD

Phương pháp này biến Gemini trở thành một **AI Project Manager & Principal Tech Lead**, đứng ra điều phối và giám sát hai instance của Claude Code làm việc thông qua môi trường Tmux. Tuy nhiên, trái tim thực sự vận hành toàn bộ hệ thống này chính là **Phương pháp BMAD (BMAD Method)**.

## 1. Phương pháp BMAD: Hệ tư tưởng Cốt lõi (The Core Philosophy)

BMAD không chỉ là một công cụ, mà là **trung tâm trọng lực** xoay quanh mọi luồng công việc (workflows) và các Agent. Nếu Gemini là "Nhạc trưởng" (Orchestrator) và Claude Code là "Nhạc công", thì **BMAD chính là bản nhạc (Sheet music)** quy định ai làm gì, khi nào làm, và làm như thế nào.

Những nguyên tắc cốt lõi của BMAD được áp dụng trong hệ thống này:

- **Intelligent Orchestration (Điều phối Thông minh)**: Mọi tác vụ đều được BMAD chia nhỏ thành các workflows chuyên biệt (ví dụ: `create-story`, `dev-story`, `code-review`). Gemini không giao việc một cách ngẫu hứng mà bám sát chặt chẽ theo các quy trình đã được BMAD chuẩn hóa.
- **Fresh Chat / Context Isolation (Cách ly Ngữ cảnh)**: Đây là một nguyên tắc sống còn. Trước khi khởi tạo một workflow mới (như chuyển từ làm tính năng A sang tính năng B), hệ thống **bắt buộc** phải có một "Fresh chat". Thay vì để Claude Code ôm đồm quá nhiều ngữ cảnh gây ảo giác (hallucination), Gemini sẽ tự động gửi lệnh `/clear` để reset môi trường, giữ cho luồng suy nghĩ của AI luôn sắc bén và tập trung vào đúng task hiện tại.
- **Agent Roles (Vai trò Chuyên biệt)**: BMAD định nghĩa rõ ràng các "persona" (ví dụ: PM, Dev, Architect, QA). Hệ thống đa instance này ánh xạ hoàn hảo với tầm nhìn đó bằng cách dùng phiên "Brainstorm" cho Architect/PM và phiên "Implement" cho Dev.

## 2. Kiến trúc Hệ thống

Hệ thống điều phối bao gồm 3 thành phần chính:
1. **Gemini CLI (Nhạc trưởng theo chuẩn BMAD)**: Hoạt động trong session Tmux chính (ví dụ `gemini-orchestrator:0.0`), đọc hiểu các workflow của BMAD, phân tích yêu cầu, gọi đúng Slash Command và nghiệm thu mã nguồn.
2. **Session "Implement" (Claude Code Sonnet)**: Xử lý các tác vụ thực thi như viết code, sửa lỗi (đóng vai Dev Agent).
3. **Session "Brainstorm" (Claude Code Opus/Sonnet)**: Xử lý các tác vụ tư duy cấp cao, thiết kế kiến trúc, review code (đóng vai Architect/QA Agent).

## 3. Cách Gemini tương tác với Claude Code

Gemini giao tiếp với Claude Code hoàn toàn thông qua Tmux, sử dụng các shell script để đảm bảo sự ổn định:

- **Gửi lệnh an toàn (`tmux-send.sh`)**: Gemini không gọi `tmux send-keys` thủ công để tránh lỗi ký tự khi gửi prompt dài. Script `tmux-send.sh` được sử dụng:
  ```bash
  .claude/hooks/tmux-send.sh "<session-target>" "nội dung lệnh" <wait-seconds>
  ```
- **Thực thi Fresh Chat (`/clear`)**: Trước khi khởi tạo một luồng công việc mới theo đề xuất của BMAD, Gemini tự động gửi lệnh `/clear` tới Claude Code để đảm bảo context sạch sẽ nhất.

## 4. Hệ thống Event-Driven qua Claude Code Hooks

Điểm đột phá tự động hóa là hệ thống **Hooks** tích hợp trong `.claude/settings.json`. Nó biến quá trình polling (Gemini liên tục kiểm tra màn hình) thành quá trình **Event-driven** (Claude Code làm xong tự báo).

### Cấu hình `.claude/settings.json`
Định nghĩa các sự kiện `Stop` và `Notification`:
```json
"hooks": {
  "Stop": [
    { "type": "command", "command": "bash .claude/hooks/wakeup-gemini.sh" }
  ],
  "Notification": [
    { "type": "command", "command": "bash .claude/hooks/notify-gemini.sh \"$CLAUDE_NOTIFICATION\"" }
  ]
}
```

### Script đánh thức Gemini
Khi Claude Code hoàn thành một task, script sẽ gửi phím Enter (`C-m`) và text vào chính panel của Gemini (`gemini-orchestrator:0.0`):
```bash
tmux send-keys -t gemini-orchestrator:0.0 "Claude Code đã phát tín hiệu Stop. Vui lòng kiểm tra tiếp tục công việc" C-m
```
Gemini "tỉnh giấc", đọc log màn hình bằng `capture-pane`, đánh giá kết quả theo chuẩn `GEMINI.md`, và tự động chuyển sang workflow tiếp theo do BMAD đề xuất.

## 5. Tóm tắt Quy trình Workflow
1. **Khởi tạo**: Chạy slash command `/withClaudeCodeTmux <Session Implement> <Session Brainstorm>`.
2. **Setup**: Gemini kiểm tra pane ID, tình trạng git branch.
3. **Mapping theo BMAD**: Gemini nhận diện yêu cầu, ánh xạ vào một workflow của BMAD.
4. **Phân luồng**: Gọi `tmux-send.sh` truyền task (kèm `/clear` nếu là workflow mới) vào đúng session của Claude Code.
5. **Chờ đợi (Idle)**: Gemini nằm chờ.
6. **Trigger**: Claude Code hoàn thành task -> kích hoạt Hook -> Bash script -> đánh thức Gemini.
7. **Nghiệm thu & Tiếp nối**: Gemini thức dậy, nghiệm thu code, đọc **Next step suggestion** của BMAD để tự động đi tiếp (hoặc dịch ra tiếng Việt hỏi ý kiến người dùng nếu cần quyết định).

## Context
- **BMAD Method** cung cấp "não bộ" (quy trình, role, context management), còn **Tmux + Hooks** cung cấp "hệ thần kinh vận động" (cơ sở hạ tầng để thực thi tự động).
- Sự kết hợp này mang lại khả năng mở rộng tuyệt vời, giúp một người (Solo Dev) có thể vận hành cả một đội ngũ AI thu nhỏ, hoạt động trơn tru ngày đêm.