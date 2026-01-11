drop database Session09;
create database Session09;
use Session09;

-- Tạo bảng
CREATE TABLE users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  full_name VARCHAR(100) NOT NULL,
  gender ENUM('Nam', 'Nữ') NOT NULL DEFAULT 'Nam',
  email VARCHAR(100) UNIQUE NOT NULL,
  password VARCHAR(100) NOT NULL,
  birthdate DATE,
  hometown VARCHAR(100),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE posts (
  post_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  content TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT posts_fk_users FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE comments (
  comment_id INT AUTO_INCREMENT PRIMARY KEY,
  post_id INT NOT NULL,
  user_id INT NOT NULL,
  content TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT comments_fk_posts FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
  CONSTRAINT comments_fk_users FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE likes (
  post_id INT NOT NULL,
  user_id INT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (post_id, user_id),
  CONSTRAINT likes_fk_posts FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
  CONSTRAINT likes_fk_users FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE friends (
  user_id INT NOT NULL,
  friend_id INT NOT NULL,
  status ENUM('pending','accepted','blocked') DEFAULT 'pending',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, friend_id),
  CONSTRAINT friends_fk_user1 FOREIGN KEY (user_id) REFERENCES users(user_id),
  CONSTRAINT friends_fk_user2 FOREIGN KEY (friend_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE messages (
  message_id INT AUTO_INCREMENT PRIMARY KEY,
  sender_id INT NOT NULL,
  receiver_id INT NOT NULL,
  content TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT messages_fk_sender FOREIGN KEY (sender_id) REFERENCES users(user_id),
  CONSTRAINT messages_fk_receiver FOREIGN KEY (receiver_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE notifications (
  notification_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  type VARCHAR(50),
  content VARCHAR(255),
  is_read BOOLEAN DEFAULT FALSE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT notifications_fk_users FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX posts_created_at_ix ON posts (created_at DESC);
CREATE INDEX messages_created_at_ix ON messages (created_at DESC);

-- ==================== INSERT DATA ====================

-- Users (25 users)
INSERT INTO users (username, full_name, gender, email, password, birthdate, hometown) VALUES
('an', 'Nguyễn Văn An', 'Nam', 'an@gmail.com', '123', '1990-01-01', 'Hà Nội'),
('binh', 'Trần Thị Bình', 'Nữ', 'binh@gmail.com', '123', '1992-02-15', 'TP.HCM'),
('chi', 'Lê Minh Chi', 'Nữ', 'chi@gmail.com', '123', '1991-03-10', 'Đà Nẵng'),
('duy', 'Phạm Quốc Duy', 'Nam', 'duy@gmail.com', '123', '1990-05-20', 'Hải Phòng'),
('ha', 'Vũ Thu Hà', 'Nữ', 'ha@gmail.com', '123', '1994-07-25', 'Hà Nội'),
('hieu', 'Đặng Hữu Hiếu', 'Nam', 'hieu@gmail.com', '123', '1993-11-30', 'TP.HCM'),
('hoa', 'Ngô Mai Hoa', 'Nữ', 'hoa@gmail.com', '123', '1995-04-18', 'Đà Nẵng'),
('khanh', 'Bùi Khánh Linh', 'Nữ', 'khanh@gmail.com', '123', '1992-09-12', 'TP.HCM'),
('lam', 'Hoàng Đức Lâm', 'Nam', 'lam@gmail.com', '123', '1991-10-05', 'Hà Nội'),
('linh', 'Phan Mỹ Linh', 'Nữ', 'linh@gmail.com', '123', '1994-06-22', 'Đà Nẵng'),
('minh', 'Nguyễn Minh', 'Nam', 'minh@gmail.com', '123', '1990-12-01', 'Hà Nội'),
('nam', 'Trần Quốc Nam', 'Nam', 'nam@gmail.com', '123', '1992-02-05', 'TP.HCM'),
('nga', 'Lý Thúy Nga', 'Nữ', 'nga@gmail.com', '123', '1993-08-16', 'Hà Nội'),
('nhan', 'Đỗ Hoàng Nhân', 'Nam', 'nhan@gmail.com', '123', '1991-04-20', 'TP.HCM'),
('phuong', 'Tạ Kim Phương', 'Nữ', 'phuong@gmail.com', '123', '1990-05-14', 'Đà Nẵng'),
('quang', 'Lê Quang', 'Nam', 'quang@gmail.com', '123', '1992-09-25', 'Hà Nội'),
('son', 'Nguyễn Thành Sơn', 'Nam', 'son@gmail.com', '123', '1994-03-19', 'TP.HCM'),
('thao', 'Trần Thảo', 'Nữ', 'thao@gmail.com', '123', '1993-11-07', 'Đà Nẵng'),
('trang', 'Phạm Thu Trang', 'Nữ', 'trang@gmail.com', '123', '1995-06-02', 'Hà Nội'),
('tuan', 'Đinh Minh Tuấn', 'Nam', 'tuan@gmail.com', '123', '1990-07-30', 'TP.HCM'),
('dung', 'Hoàng Tuấn Dũng', 'Nam', 'dung@gmail.com', '123', '1993-05-10', 'Hải Phòng'),
('yen', 'Phạm Hải Yến', 'Nữ', 'yen@gmail.com', '123', '1995-08-22', 'Hà Nội'),
('thanh', 'Lê Văn Thành', 'Nam', 'thanh@gmail.com', '123', '1991-12-15', 'Cần Thơ'),
('mai', 'Nguyễn Tuyết Mai', 'Nữ', 'mai@gmail.com', '123', '1994-02-28', 'TP.HCM'),
('vinh', 'Trần Quang Vinh', 'Nam', 'vinh@gmail.com', '123', '1992-09-05', 'Đà Nẵng');


--  Tạo một view có tên view_users_firstname để hiển thị danh sách các người dùng có họ “Nguyễn”
CREATE VIEW view_users_firstname AS
SELECT 
    user_id, 
    username, 
    full_name, 
    email, 
    created_at
FROM users
WHERE full_name LIKE 'Nguyễn %';
SELECT * FROM view_users_firstname;

-- Thêm một nhân viên mới vào bảng User có họ “Nguyễn”.
INSERT INTO users (username, full_name, gender, email, password, birthdate, hometown)
VALUES ('nguyen_thanh_tung', 'Nguyễn Thanh Tùng', 'Nam', 'tungnguyen@gmail.com', 'pass123', '1995-08-20', 'Hà Nội');
SELECT * FROM view_users_firstname;

-- Thực hiện xóa nhân viên vừa thêm khỏi bảng Users.
DELETE FROM users 
WHERE username = 'nguyen_thanh_tung';
SELECT * FROM view_users_firstname;
