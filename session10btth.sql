DROP DATABASE IF EXISTS session10btth;
CREATE DATABASE session10btth;
USE session10btth;

-- ==============================
-- 1. TABLE: users
-- ==============================
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ==============================
-- 2. TABLE: posts
-- ==============================
CREATE TABLE posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    content TEXT,
    privacy ENUM('PUBLIC', 'FRIEND', 'PRIVATE') DEFAULT 'PUBLIC',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- ==============================
-- 3. TABLE: comments
-- ==============================
CREATE TABLE comments (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    content TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(post_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- ==============================
-- 4. TABLE: likes
-- ==============================
CREATE TABLE likes (
    like_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(post_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- ==============================
-- INSERT SAMPLE DATA
-- ==============================

-- Users
INSERT INTO users (username, email, phone) VALUES
('alice', 'alice@gmail.com', '0901111111'),
('bob', 'bob@gmail.com', '0902222222'),
('charlie', 'charlie@gmail.com', '0903333333'),
('david', 'david@gmail.com', '0904444444');

-- Posts
INSERT INTO posts (user_id, content, privacy, created_at) VALUES
(1, 'Hello world from Alice', 'PUBLIC', '2024-01-10'),
(2, 'Bob private post', 'PRIVATE', '2024-02-01'),
(3, 'Charlie public sharing', 'PUBLIC', '2024-03-05'),
(1, 'Alice friend-only post', 'FRIEND', '2024-03-20'),
(4, 'David public post', 'PUBLIC', '2024-04-01');

-- Comments
INSERT INTO comments (post_id, user_id, content) VALUES
(1, 2, 'Nice post!'),
(1, 3, 'Welcome Alice'),
(3, 1, 'Good content'),
(5, 2, 'Great post David');

-- Likes
INSERT INTO likes (post_id, user_id) VALUES
(1, 2),
(1, 3),
(3, 1),
(3, 2),
(5, 1),
(5, 3);

-- PHẦN A – VIEW (Khung nhìn)
-- Câu 1: View hồ sơ người dùng công khai
-- Mục tiêu: Ẩn thông tin nhạy cảm
CREATE OR REPLACE VIEW view_user_profile AS
SELECT 
    username, 
    email, 
    created_at
FROM users;

-- Câu 2: View News Feed bài viết công khai
-- Mục tiêu: Hiển thị bài viết PUBLIC kèm số lượt thích
CREATE OR REPLACE VIEW view_news_feed AS
SELECT 
    u.username AS author,
    p.content,
    p.created_at,
    (SELECT COUNT(*) FROM likes l WHERE l.post_id = p.post_id) AS total_likes
FROM posts p
JOIN users u ON p.user_id = u.user_id
WHERE p.privacy = 'PUBLIC';

-- Câu 3: View có CHECK OPTION
-- Mục tiêu: Ràng buộc dữ liệu chỉ cho phép các bài viết PUBLIC
CREATE OR REPLACE VIEW view_public_posts_check AS
SELECT * FROM posts 
WHERE privacy = 'PUBLIC'
WITH CHECK OPTION;

-- Thử nghiệm thao tác không hợp lệ (Sẽ báo lỗi do CHECK OPTION)
-- INSERT INTO view_public_posts_check (user_id, content, privacy) 
-- VALUES (1, 'Test private post', 'PRIVATE'); 

-- PHẦN B – INDEX (Chỉ mục)
-- Câu 4: Phân tích truy vấn News Feed khi chưa có INDEX
EXPLAIN ANALYZE
SELECT *
FROM posts
WHERE privacy = 'PUBLIC'
ORDER BY created_at DESC;

/* NHẬN XÉT HIỆU NĂNG (Trước khi đánh Index):
- Phương thức: Table scan.
- MySQL phải duyệt qua tất cả các dòng trong bảng posts để lọc ra 'PUBLIC' 
  và sau đó thực hiện sắp xếp thủ công trên bộ cho created_at.
- Hiệu năng sẽ rất kém nếu bảng posts có hàng triệu dữ liệu.
*/

-- Câu 5: Tạo INDEX tối ưu
-- 5.1: Index tối ưu cho News Feed (Phối hợp lọc privacy và sắp xếp thời gian)
CREATE INDEX idx_privacy_created_at ON posts(privacy, created_at DESC);

-- 5.2: Index tăng tốc lấy bài viết theo người dùng (Tối ưu cho JOIN)
CREATE INDEX idx_user_id ON posts(user_id);

-- Kiểm tra lại hiệu năng sau khi tạo INDEX
EXPLAIN ANALYZE
SELECT *
FROM posts
WHERE privacy = 'PUBLIC'
ORDER BY created_at DESC;

/*
SO SÁNH KẾT QUẢ:
- Sau khi tạo index, MySQL sử dụng "Index range scan".
- Thời gian thực thi giảm vì không cần dùng Filesort (dữ liệu đã được sắp xếp sẵn trong Index).
*/

---
-- Câu 6: Phân tích hạn chế của INDEX (Trả lời lý thuyết)

/*
1. Khi nào không nên tạo index?
   - Cho các bảng quá nhỏ.
   - Cho các cột có độ chọn lọc thấp.
   - Cho các bảng thường xuyên cập nhật dữ liệu liên tục nhưng ít khi được truy vấn.

2. Vì sao không nên index cột nội dung bài viết (TEXT)?
   - Cột TEXT có kích thước rất lớn, tạo index thông thường sẽ tốn rất nhiều dung lượng bộ nhớ.
   - Index trên cột TEXT không hỗ trợ tốt việc tìm kiếm từng từ bên trong nội dung.

3. Index ảnh hưởng thế nào đến thao tác INSERT / UPDATE?
   - Làm CHẬM các thao tác INSERT/UPDATE/DELETE. 
   - Nguyên nhân: Mỗi khi dữ liệu thay đổi, MySQL không chỉ cập nhật bảng chính mà còn phải tính toán và cập nhật lại cấu trúc cây của tất cả các Index liên quan.
*/