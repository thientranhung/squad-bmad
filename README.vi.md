# Squad BMAD: Trợ Lý Ảo Điều Phối Dự Án Tự Động Với Gemini & Claude Code

Chào mừng bạn đến với **Squad BMAD** – một boilerplate/giải pháp thiết kế để biến **Gemini CLI** trở thành một **Project Manager & Principal Tech Lead** thực thụ. Bằng cách kết hợp sức mạnh điều phối của Gemini và khả năng lập trình/suy luận xuất sắc của **Claude Code** thông qua môi trường **Tmux**, dự án này tự động hóa và tối ưu hóa luồng công việc phát triển phần mềm dựa trên nền tảng phương pháp luận **BMAD**.

---

## 🌟 Lợi Ích Đem Lại

Phương pháp luận BMAD (Build-Measure-Analyze-Deploy) nổi tiếng với khả năng duy trì tính chặt chẽ, cấu trúc rõ ràng và luôn hướng tới **spec-driven** (làm việc dựa trên đặc tả kỹ thuật). Tuy nhiên, nhược điểm lớn nhất là quá trình vận hành tốn khá nhiều bước và thao tác thủ công. 

**Squad BMAD giải quyết triệt để vấn đề đó:**
- **Tự động hóa xuyên suốt:** Giúp quá trình vận hành project với phương pháp BMAD diễn ra trơn tru, liền mạch mà không cần bạn phải can thiệp vào từng bước nhỏ.
- **Có ngay một trợ lý dự án mẫn cán:** Trợ lý này sẽ giúp bạn trả lời, xử lý các step của BMAD, tự động vận hành và implement toàn bộ Epics, Stories.
- **Tập trung vào giá trị cốt lõi:** Bạn chỉ cần nói chuyện với Trợ lý (Gemini), đưa ra quyết định ở tầm cao, phần còn lại Trợ lý sẽ tự động giao việc và giám sát các Agent khác (Claude Code).

---

## 📋 Yêu Cầu Hệ Thống (Requirements)

Để vận hành trơn tru hệ thống này, bạn cần chuẩn bị:

- **Tài khoản Claude Code:** Cần thiết để khởi chạy các Agent thực thi (Implement) và tư duy (Brainstorm).
- **Tài khoản Gemini (Gemini CLI):** Đóng vai trò là "Nhạc trưởng" điều phối toàn bộ luồng công việc.
- **Môi trường Tmux:** Được cài đặt sẵn trên máy tính (MacOS/Linux) để quản lý đa luồng phiên làm việc.
- **Kinh nghiệm:** Đã từng sử dụng hoặc có kiến thức nền tảng về phương pháp **BMAD**.

---

## 🧠 Hệ Tư Tưởng Cốt Lõi

Squad BMAD được xây dựng dựa trên các nguyên tắc bất di bất dịch:

1. **Bám sát quy trình BMAD:** Mọi tác vụ từ lên ý tưởng, viết đặc tả, đến code và review đều tuân thủ nghiêm ngặt các workflow của BMAD. Điều này đảm bảo dự án luôn đi đúng hướng và tài liệu kỹ thuật luôn đồng bộ với code thực tế.
2. **Fresh Chat & Context Isolation (Cách ly Ngữ cảnh):** Trước khi bắt đầu một workflow mới, hệ thống bắt buộc phải dọn dẹp ngữ cảnh (gọi lệnh `/clear`). Việc này giúp AI (Claude) không bị ảo giác (hallucination) do ôm đồm quá nhiều thông tin cũ, giữ cho suy luận luôn sắc bén.
3. **Phân chia vai trò rõ ràng (Agent Roles):** Áp dụng đúng tinh thần của BMAD, hệ thống chia các Agent thành các "persona" chuyên biệt (PM, Architect, Dev, QA) để tối ưu hóa hiệu suất của từng Model AI.

---

## ⚙️ Kiến Trúc Hệ Thống & Cách Vận Hành

Hệ thống hoạt động dựa trên sự phối hợp nhịp nhàng của **3 phiên làm việc (sessions) Tmux**:

1. **Session 1: Gemini Orchestrator (Nhạc trưởng)**
   - Là người chủ vận hành 2 tmux còn lại.
   - Giao tiếp trực tiếp với bạn, hiểu yêu cầu, ánh xạ vào workflow của BMAD.
   - Theo dõi, nghiệm thu kết quả và ra quyết định chuyển tiếp.

2. **Session 2: Claude Code - Implement (Thực thi)**
   - Đóng vai trò là một **Developer**.
   - Chuyên dùng để viết code, sửa lỗi, chạy test.
   - Sử dụng model **Claude 3.5 Sonnet** để đảm bảo tốc độ nhanh, code giỏi và tiết kiệm chi phí.

3. **Session 3: Claude Code - Brainstorm (Suy luận)**
   - Đóng vai trò là **Architect / PM / QA**.
   - Chuyên dùng để suy luận kiến trúc, giải quyết các bài toán phức tạp, thiết kế hệ thống và review code.
   - Sử dụng model **Claude 3.5 Sonnet** (hoặc **Opus** tuỳ cấu hình) cho các tác vụ cần tư duy logic sâu.

### 🔄 Hệ Thống Event-Driven bằng Hooks

Thay vì để Gemini phải liên tục kiểm tra màn hình xem Claude Code đã làm xong chưa (polling), dự án này sử dụng cơ chế **Hooks Event-driven** thông qua file `.claude/settings.json`.

Mỗi khi Claude Code (ở tmux 2 hoặc 3) hoàn thành công việc hoặc cần dừng lại, hệ thống sẽ tự động kích hoạt một bash script (như `.claude/hooks/wakeup-gemini.sh`). Script này sẽ lập tức gửi tín hiệu ngược lại cho Session Tmux của Gemini, "đánh thức" Gemini dậy để:
1. Đọc kết quả công việc.
2. Đánh giá và nghiệm thu mã nguồn.
3. Báo cáo lại cho bạn hoặc tự động đi tiếp bước tiếp theo theo quy trình BMAD.

---

## 🚀 Tóm Tắt Quy Trình Hoạt Động

1. Bạn mở 3 session Tmux (1 cho Gemini, 2 cho Claude Code).
2. Bạn chat với Gemini: *"Hãy implement Story #123 cho tôi."*
3. Gemini nhận lệnh, phân tích theo workflow BMAD và gửi lệnh (kèm `/clear` để reset context) sang cho `Claude Code - Implement` thông qua shell script an toàn.
4. Gemini rơi vào trạng thái "Idle" (nghỉ ngơi), chờ đợi.
5. `Claude Code - Implement` hì hục viết code. Khi xong, nó tự động kích hoạt Hook.
6. Hook chạy bash script, gửi phím `Enter` và dòng thông báo sang màn hình của Gemini.
7. Gemini "tỉnh giấc", đọc log màn hình của Claude Code, nghiệm thu kết quả và báo cáo lại cho bạn.

---

Với **Squad BMAD**, bạn không còn là một coder cặm cụi gõ từng dòng lệnh, bạn là một **Người quản lý dự án** thực thụ điều hành một đội ngũ AI tinh nhuệ!

---

## 🛠 Cách Cài Đặt & Sử Dụng (How to use)

### 1. Chuẩn Bị Môi Trường Tmux
Bạn cần khởi tạo 3 session Tmux riêng biệt. Bạn có thể đặt tên tuỳ ý, ví dụ:
- Session 1 (Gemini): `gemini-orchestrator`
- Session 2 (Claude Implement): `claude-implement`
- Session 3 (Claude Brainstorm): `claude-brainstorm`

Mở 3 terminal và chạy lần lượt:
```bash
tmux new -s gemini-orchestrator
tmux new -s claude-implement
tmux new -s claude-brainstorm
```

### 2. Khởi Chạy Các Tác Nhân
- **Tại Tmux 1 (`gemini-orchestrator`)**: Khởi chạy Gemini CLI.
  ```bash
  gemini --yolo
  ```
- **Tại Tmux 2 (`claude-implement`)**: Khởi chạy Claude Code. Mặc định Claude Code sẽ dùng model Sonnet.
  ```bash
  claude --dangerously-skip-permissions
  ```
- **Tại Tmux 3 (`claude-brainstorm`)**: Khởi chạy Claude Code. (Nên cấu hình dùng model Opus nếu bạn cần suy luận kiến trúc phức tạp).
  ```bash
  claude --dangerously-skip-permissions
  ```

### 3. Cấu Hình Tên Phiên Cho Gemini
Để Gemini biết được cần gửi lệnh cho ai, trong cửa sổ chat của **Gemini (Tmux 1)**, bạn gõ slash command để cấu hình (Lưu ý thay tên session cho đúng với tên bạn đã tạo):

```text
/withClaudeCodeTmux "claude-implement" "claude-brainstorm"
```

### 4. Bắt Đầu Công Việc
Giờ đây hệ thống đã sẵn sàng. Bạn chỉ việc giao tiếp với Gemini như một người quản lý dự án:
- *"Bắt đầu project này giúp tôi bằng luồng generate-project-context."*
- *"Chúng ta đang ở Epic nào? Hãy tạo story mới cho tính năng đăng nhập."*
- *"Hãy implement Story #5 theo quy trình dev-story."*

Gemini sẽ tự động phân tích, dọn dẹp ngữ cảnh (gửi lệnh `/clear`), chuyển lệnh đến đúng session Claude phù hợp và sẽ tự động "thức dậy" để nghiệm thu khi nhận được tín hiệu Hook phản hồi từ Claude.