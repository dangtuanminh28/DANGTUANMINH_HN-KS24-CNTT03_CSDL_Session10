SELECT * FROM social_network_pro.users;
-- Kiểm tra tìm bài viết
EXPLAIN ANALYZE
SELECT post_id, content, created_at 
FROM social_network_pro.posts 
WHERE user_id = 1 AND created_at BETWEEN '2026-01-01 00:00:00' AND '2026-12-31 23:59:59';

-- Kiểm tra tìm email
EXPLAIN ANALYZE
SELECT user_id, username, email 
FROM social_network_pro.users 
WHERE email = 'an@gmail.com';
-- Tạo Composite Index cho bài viết
CREATE INDEX idx_user_id_created_at ON social_network_pro.posts(user_id, created_at);

-- Tạo Unique Index cho email
CREATE UNIQUE INDEX idx_email ON social_network_pro.users(email);
-- Xóa chỉ mục phức hợp trên bảng posts
DROP INDEX idx_user_id_created_at ON social_network_pro.posts;

-- Xóa chỉ mục duy nhất trên bảng users
DROP INDEX idx_email ON social_network_pro.users;