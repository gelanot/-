-- Тема №48: Учёт результатов соревнований (SQLite)
PRAGMA foreign_keys = ON;

-- Удаление: сначала зависимые таблицы
DROP TABLE IF EXISTS results;
DROP TABLE IF EXISTS registrations;
DROP TABLE IF EXISTS participants;
DROP TABLE IF EXISTS competitions;
DROP TABLE IF EXISTS judges;
DROP TABLE IF EXISTS teams;
DROP TABLE IF EXISTS sports;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS user_roles;

-- Справочники
CREATE TABLE user_roles (
    user_role_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE sports (
    sport_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE teams (
    team_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    city TEXT NOT NULL
);

-- Основные таблицы
CREATE TABLE users (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    login TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    user_role INTEGER NOT NULL,
    FOREIGN KEY (user_role) REFERENCES user_roles (user_role_id)
);

-- Судья (1:1 с учётной записью пользователя)
CREATE TABLE judges (
    judge_id INTEGER PRIMARY KEY AUTOINCREMENT,
    full_name TEXT NOT NULL,
    specialization TEXT NOT NULL,
    user_id INTEGER UNIQUE,
    FOREIGN KEY (user_id) REFERENCES users (user_id)
);

CREATE TABLE competitions (
    competition_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    event_date TEXT NOT NULL,
    sport_id INTEGER NOT NULL,
    FOREIGN KEY (sport_id) REFERENCES sports (sport_id)
);

CREATE TABLE participants (
    participant_id INTEGER PRIMARY KEY AUTOINCREMENT,
    full_name TEXT NOT NULL,
    category TEXT NOT NULL,
    team_id INTEGER,
    FOREIGN KEY (team_id) REFERENCES teams (team_id)
);

-- Связка M:N: участник <-> соревнование
CREATE TABLE registrations (
    registration_id INTEGER PRIMARY KEY AUTOINCREMENT,
    competition_id INTEGER NOT NULL,
    participant_id INTEGER NOT NULL,
    start_number INTEGER NOT NULL,
    UNIQUE (competition_id, participant_id),
    UNIQUE (competition_id, start_number),
    FOREIGN KEY (competition_id) REFERENCES competitions (competition_id),
    FOREIGN KEY (participant_id) REFERENCES participants (participant_id)
);

-- Результат выступления (1:1 с регистрацией): время, очки, место
CREATE TABLE results (
    result_id INTEGER PRIMARY KEY AUTOINCREMENT,
    registration_id INTEGER NOT NULL UNIQUE,
    judge_id INTEGER NOT NULL,
    time_seconds REAL,
    points REAL,
    place INTEGER,
    CHECK (time_seconds IS NOT NULL OR points IS NOT NULL),
    FOREIGN KEY (registration_id) REFERENCES registrations (registration_id),
    FOREIGN KEY (judge_id) REFERENCES judges (judge_id)
);

-- Тестовые данные
INSERT INTO user_roles (name) VALUES ('Administrator'), ('Judge'), ('Viewer');

INSERT INTO sports (name) VALUES ('Бег 100 м'), ('Плавание 100 м'), ('Шахматы');

INSERT INTO teams (name, city) VALUES
    ('Волга', 'Нижний Новгород'),
    ('Динамо', 'Москва'),
    ('Звезда', 'Казань');

INSERT INTO users (login, password_hash, user_role) VALUES
    ('admin', 'hash_admin', 1),
    ('judge1', 'hash_judge1', 2),
    ('judge2', 'hash_judge2', 2),
    ('viewer1', 'hash_viewer1', 3);

INSERT INTO judges (full_name, specialization, user_id) VALUES
    ('Смирнова Анна Олеговна', 'Лёгкая атлетика', 2),
    ('Кузнецов Дмитрий Игоревич', 'Плавание и шахматы', 3);

INSERT INTO competitions (name, event_date, sport_id) VALUES
    ('Кубок города по бегу', '2026-05-10', 1),
    ('Открытое первенство по плаванию', '2026-06-15', 2),
    ('Шахматный турнир', '2026-09-20', 3);

INSERT INTO participants (full_name, category, team_id) VALUES
    ('Петров Алексей', 'Взрослые', 1),
    ('Сидорова Мария', 'Юниоры', 2),
    ('Орлов Николай', 'Взрослые', 3),
    ('Фёдорова Екатерина', 'Юниоры', 1);

INSERT INTO registrations (competition_id, participant_id, start_number) VALUES
    (1, 1, 11), (1, 2, 12), (1, 3, 13),
    (2, 2, 21), (2, 4, 22),
    (3, 1, 31), (3, 3, 32), (3, 4, 33);

INSERT INTO results (registration_id, judge_id, time_seconds, points, place) VALUES
    (1, 1, 12.8, NULL, 2),
    (2, 1, 12.3,


NULL, 1),
    (3, 1, 13.1, NULL, 3),
    (4, 2, 58.4, NULL, 1),
    (5, 2, 61.0, NULL, 2),
    (6, 2, NULL, 4.5, 2),
    (7, 2, NULL, 5.0, 1),
    (8, 2, NULL, 3.0, 3);