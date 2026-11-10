-- DDL
-- CREATE, ALTER, DROP

DROP DATABASE IF EXISTS telegram;
CREATE DATABASE telegram;
USE telegram;

DROP TABLE IF EXISTS users;
CREATE TABLE users(
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    firstname VARCHAR(50) NOT NULL,
    lastname VARCHAR(50) NOT NULL,
    login VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(256) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

INDEX idx_users_username(firstname, lastname)
) COMMENT 'пользователи';

DROP TABLE IF EXISTS user_settings;
CREATE TABLE user_settings(
	user_id BIGINT UNSIGNED NOT NULL PRIMARY KEY,
	is_premium_account BIT,
	is_night_mode_enabled BIT,
	color_scheme ENUM('classic', 'day', 'tinted', 'night'),
	app_language ENUM('english', 'french', 'russian', 'german', 'belorussian'),
	status_text VARCHAR(70),
	notifications_and_sounds JSON,
	created_at DATETIME DEFAULT NOW() 
);

ALTER TABLE user_settings ADD CONSTRAINT fk_user_settings_user_id
FOREIGN KEY (user_id) REFERENCES users(id)
ON UPDATE CASCADE
ON DELETE RESTRICT;

# ALTER TABLE user_settings PRIMARY KEY (user_id);
# ALTER TABLE user_settings MODIFY COLUMN user_id BIGINT UNSIGNED NOT NULL PRIMARY KEY;
ALTER TABLE users ADD COLUMN birthday DATETIME;
ALTER TABLE users MODIFY COLUMN birthday DATE;
# ALTER TABLE users RENAME COLUMN birthday TO date_of_birth;
# ALTER TABLE users DROP COLUMN date_of_birth;

/*DROP TABLE IF EXISTS media_types;
CREATE TABLE media_types(
	id SERIAL,
	name VARCHAR(50)
);*/

DROP TABLE IF EXISTS private_messages;
CREATE TABLE private_messages(
	id SERIAL,
	sender_id BIGINT UNSIGNED NOT NULL,
	receiver_id BIGINT UNSIGNED NOT NULL,
	reply_to_id BIGINT UNSIGNED NULL,
	media_type ENUM('text', 'image', 'audio', 'video'),
#	media_type_id BIGINT UNSIGNED NOT NULL,
#	body VARCHAR(), limit 65535
	body TEXT,
#	file BLOB
	filename VARCHAR(200),
	created_at DATETIME DEFAULT NOW(),
	
# PRIMARY KEY (`id`),
FOREIGN KEY (sender_id) REFERENCES users(id),
FOREIGN KEY (receiver_id) REFERENCES users(id),
FOREIGN KEY (reply_to_id) REFERENCES private_messages(id)
);

DROP TABLE IF EXISTS `groups`;
CREATE TABLE `groups` (
	id SERIAL,
	title VARCHAR(45),
	icon VARCHAR(45),
	invite_link VARCHAR(100),
	settings JSON,
	owner_user_id BIGINT UNSIGNED NOT NULL,
	is_private BIT,
	created_at DATETIME DEFAULT NOW(),
	
FOREIGN KEY (owner_user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS group_members;
CREATE TABLE group_members (
	id SERIAL,
	group_id BIGINT UNSIGNED NOT NULL,
	user_id BIGINT UNSIGNED NOT NULL,
	created_at DATETIME DEFAULT NOW(),
	
FOREIGN KEY (user_id) REFERENCES users(id),
FOREIGN KEY (group_id) REFERENCES `groups`(id)
);

DROP TABLE IF EXISTS group_messages;
CREATE TABLE group_messages (
	id SERIAL,
	group_id BIGINT UNSIGNED NOT NULL,
	sender_id BIGINT UNSIGNED NOT NULL,
	reply_to_id BIGINT UNSIGNED NULL,
	media_type ENUM('text', 'image', 'audio', 'video'),
	body TEXT,
	filename VARCHAR(100) NULL,
	created_at DATETIME DEFAULT NOW(),
	
FOREIGN KEY (sender_id) REFERENCES users(id),
FOREIGN KEY (group_id) REFERENCES `groups`(id),
FOREIGN KEY (reply_to_id) REFERENCES group_messages(id)
);

DROP TABLE IF EXISTS channels;
CREATE TABLE channels (
	id SERIAL,
	title VARCHAR(45),
	icon VARCHAR(45),
	invite_link VARCHAR(100),
	settings JSON,
	owner_user_id BIGINT UNSIGNED NOT NULL,
	is_private BIT,
#	channel_type ENUM('public', 'private')
	created_at DATETIME DEFAULT NOW(),
	
FOREIGN KEY (owner_user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS channel_subscribers;
CREATE TABLE channel_subscribers (
	channel_id BIGINT UNSIGNED NOT NULL,
	user_id BIGINT UNSIGNED NOT NULL,
	status ENUM ('requested', 'joined', 'left'),
	created_at DATETIME DEFAULT NOW(),
	uptated_at DATETIME ON UPDATE CURRENT_TIMESTAMP,
	
PRIMARY KEY (user_id,channel_id),
FOREIGN KEY (user_id) REFERENCES users(id),
FOREIGN KEY (channel_id) REFERENCES channels(id)
);

DROP TABLE IF EXISTS channel_messages;
CREATE TABLE channel_messages (
	id SERIAL,
	channel_id BIGINT UNSIGNED NOT NULL,
	sender_id BIGINT UNSIGNED NOT NULL,
	media_type ENUM('text', 'image', 'audio', 'video'),
	body TEXT,
	filename VARCHAR(100) NULL,
	created_at DATETIME DEFAULT NOW(),
	
FOREIGN KEY (sender_id) REFERENCES users(id),
FOREIGN KEY (channel_id) REFERENCES channels(id)
);

DROP TABLE IF EXISTS saved_messages;
CREATE TABLE saved_messages (
	id SERIAL,
	user_id BIGINT UNSIGNED NOT NULL,
	body TEXT,
	created_at DATETIME DEFAULT NOW(),
	
FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS reactions_list;
CREATE TABLE reactions_list (
	id SERIAL,
	code VARCHAR (1)
)DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

DROP TABLE IF EXISTS private_message_reactions;
CREATE TABLE private_message_reactions (
	reaction_id BIGINT UNSIGNED NOT NULL,
	message_id BIGINT UNSIGNED NOT NULL,
	user_id BIGINT UNSIGNED NOT NULL,
	created_at DATETIME DEFAULT NOW(),

FOREIGN KEY (reaction_id) REFERENCES reactions_list(id),
FOREIGN KEY (message_id) REFERENCES private_messages(id),
FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS channel_message_reactions;
CREATE TABLE channel_message_reactions (
	reaction_id BIGINT UNSIGNED NOT NULL,
	message_id BIGINT UNSIGNED NOT NULL,
	user_id BIGINT UNSIGNED NOT NULL,
	created_at DATETIME DEFAULT NOW(),

FOREIGN KEY (reaction_id) REFERENCES reactions_list(id),
FOREIGN KEY (message_id) REFERENCES channel_messages(id),
FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS group_message_reactions;
CREATE TABLE group_message_reactions (
	reaction_id BIGINT UNSIGNED NOT NULL,
	message_id BIGINT UNSIGNED NOT NULL,
	user_id BIGINT UNSIGNED NOT NULL,
	created_at DATETIME DEFAULT NOW(),

FOREIGN KEY (reaction_id) REFERENCES reactions_list(id),
FOREIGN KEY (message_id) REFERENCES group_messages(id),
FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS stories;
CREATE TABLE stories (
	id SERIAL,
	user_id BIGINT UNSIGNED NOT NULL,
	caption VARCHAR(140),
	filename VARCHAR(100),
	views_count INT UNSIGNED,
	created_at DATETIME DEFAULT NOW(),
	
FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS stories_likes;
CREATE TABLE stories_likes (
	id SERIAL,
	story_id BIGINT UNSIGNED NOT NULL,
	user_id BIGINT UNSIGNED NOT NULL,
	created_at DATETIME DEFAULT NOW(),
	
FOREIGN KEY (user_id) REFERENCES users(id),
FOREIGN KEY (story_id) REFERENCES stories(id)
);

DROP TABLE IF EXISTS contacts;
CREATE TABLE contacts(
	user_id BIGINT UNSIGNED NOT NULL COMMENT 'владелец контакта',
	contact_id BIGINT UNSIGNED NOT NULL COMMENT 'человек в списке контактов',
	firstname VARCHAR(100) DEFAULT NULL,
  	lastname VARCHAR(100) DEFAULT NULL,	
  	userpic VARCHAR(100) COMMENT 'фотка контакта, имя файла',
  	date_added DATETIME,
  	
  	FOREIGN KEY (user_id) REFERENCES users (id),
  	FOREIGN KEY (contact_id) REFERENCES users (id)
);



































