CREATE TABLE football_clubs (
    club_id SERIAL PRIMARY KEY,
    club_name VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    founded_year INT
);
INSERT INTO football_clubs (club_name, city, country, founded_year) VALUES
('Real Madrid', 'Madrid', 'Spain', 1902),
('Barcelona', 'Barcelona', 'Spain', 1899),
('Manchester United', 'Manchester', 'England', 1878),
('Bayern Munich', 'Munich', 'Germany', 1900);
CREATE TABLE tournaments (
    tournament_id SERIAL PRIMARY KEY,
    tournament_name VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20)
);
INSERT INTO tournaments (tournament_name, start_date, end_date, status) VALUES
('UEFA Champions League', '2025-09-01', '2026-05-20', 'Ongoing'),
('Europa League', '2025-09-10', '2026-05-25', 'Upcoming');
CREATE TABLE tournament_groups (
    group_id SERIAL PRIMARY KEY,
    group_name VARCHAR(100) NOT NULL,
    tournament_id INT REFERENCES tournaments(tournament_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO tournament_groups (group_name, tournament_id) VALUES
('Group A', 1),
('Group B', 1),
('Group C', 2);
CREATE TABLE teams (
    team_id SERIAL PRIMARY KEY,
    team_name VARCHAR(100) NOT NULL,
    club_id INT REFERENCES football_clubs(club_id) ON DELETE CASCADE,
    group_id INT REFERENCES tournament_groups(group_id) ON DELETE SET NULL,
    coach_name VARCHAR(100)
);
INSERT INTO teams (team_name, club_id, group_id, coach_name) VALUES
('Real Madrid First Team', 1, 1, 'Carlo Ancelotti'),
('Barcelona First Team', 2, 1, 'Xavi Hernandez'),
('Manchester United First Team', 3, 2, 'Erik ten Hag'),
('Bayern Munich First Team', 4, 2, 'Thomas Tuchel');

CREATE TABLE players (
    player_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    position VARCHAR(50) NOT NULL,
    team_id INT REFERENCES teams(team_id) ON DELETE CASCADE,
    jersey_number INT
);
INSERT INTO players (full_name, date_of_birth, position, team_id, jersey_number) VALUES
('Karim Benzema', '1987-12-19', 'Forward', 1, 9),
('Luka Modric', '1985-09-09', 'Midfielder', 1, 10),
('Lionel Messi', '1987-06-24', 'Forward', 2, 10),
('Pedri Gonzalez', '2002-11-25', 'Midfielder', 2, 8),
('Marcus Rashford', '1997-10-31', 'Forward', 3, 10),
('Bruno Fernandes', '1994-09-08', 'Midfielder', 3, 8),
('Thomas Muller', '1989-09-13', 'Forward', 4, 25),
('Joshua Kimmich', '1995-02-08', 'Midfielder', 4, 6);
CREATE TABLE match_fixtures (
    match_id SERIAL PRIMARY KEY,
    match_date TIMESTAMP NOT NULL,
    venue VARCHAR(100),
    home_team_id INT REFERENCES teams(team_id) ON DELETE CASCADE,
    away_team_id INT REFERENCES teams(team_id) ON DELETE CASCADE,
    home_score INT,
    away_score INT,
    tournament_id INT REFERENCES tournaments(tournament_id) ON DELETE CASCADE,
    match_status VARCHAR(20)
);
INSERT INTO match_fixtures (match_date, venue, home_team_id, away_team_id, home_score, away_score, tournament_id, match_status) VALUES
('2025-09-15 20:00:00', 'Santiago Bernabeu', 1, 2, 2, 1, 1, 'Finished'),
('2025-09-16 21:00:00', 'Old Trafford', 3, 4, 1, 3, 1, 'Finished'),
('2025-10-01 20:00:00', 'Camp Nou', 2, 3, NULL, NULL, 1, 'Scheduled');

INSERT INTO football_clubs (club_name, city, country, founded_year)
VALUES ('Arsenal', 'London', 'England', 1886);
SELECT * FROM football_clubs;
SELECT * FROM football_clubs WHERE club_id = 1;
UPDATE football_clubs
SET city = 'Madrid (Spain)'
WHERE club_id = 1;
DELETE FROM football_clubs WHERE club_id = 5;
INSERT INTO tournaments (tournament_name, start_date, end_date, status)
VALUES ('Conference League', '2025-09-20', '2026-05-15', 'Upcoming');
SELECT * FROM tournaments;
UPDATE tournaments
SET status = 'Finished'
WHERE tournament_id = 1;
DELETE FROM tournaments WHERE tournament_id = 3;
INSERT INTO tournament_groups (group_name, tournament_id)
VALUES ('Group D', 1);
SELECT * FROM tournament_groups;
UPDATE tournament_groups
SET group_name = 'Group A1'
WHERE group_id = 1;
DELETE FROM tournament_groups WHERE group_id = 4;
INSERT INTO teams (team_name, club_id, group_id, coach_name)
VALUES ('Arsenal First Team', 5, 3, 'Mikel Arteta');
SELECT t.team_id, t.team_name, f.club_name, tg.group_name, t.coach_name
FROM teams t
JOIN football_clubs f ON t.club_id = f.club_id
LEFT JOIN tournament_groups tg ON t.group_id = tg.group_id;
UPDATE teams
SET coach_name = 'Zinedine Zidane'
WHERE team_id = 1;
DELETE FROM teams WHERE team_id = 5;
INSERT INTO players (full_name, date_of_birth, position, team_id, jersey_number)
VALUES ('Jude Bellingham', '2003-06-29', 'Midfielder', 1, 5);
SELECT p.full_name, p.position, t.team_name
FROM players p
JOIN teams t ON p.team_id = t.team_id;
UPDATE players
SET jersey_number = 7
WHERE player_id = 9;
DELETE FROM players WHERE player_id = 8;
INSERT INTO match_fixtures (match_date, venue, home_team_id, away_team_id, home_score, away_score, tournament_id, match_status)
VALUES ('2025-11-01 21:00:00', 'Emirates Stadium', 5, 1, NULL, NULL, 1, 'Scheduled');
SELECT m.match_id, m.match_date, m.venue, 
       ht.team_name AS home_team, 
       at.team_name AS away_team, 
       m.home_score, m.away_score, 
       m.match_status
FROM match_fixtures m
JOIN teams ht ON m.home_team_id = ht.team_id
JOIN teams at ON m.away_team_id = at.team_id;
UPDATE match_fixtures
SET home_score = 3, away_score = 2, match_status = 'Finished'
WHERE match_id = 3;
DELETE FROM match_fixtures WHERE match_id = 4;
