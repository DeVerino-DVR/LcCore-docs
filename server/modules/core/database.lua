-- LcCore Server Module - Database Auto-Setup
-- Cree automatiquement les tables si elles n'existent pas au demarrage.

Citizen.CreateThread(function()
    -- lc_characters
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `lc_characters` (
            `id`        INT AUTO_INCREMENT PRIMARY KEY,
            `discord`   VARCHAR(50) NOT NULL,
            `group`     VARCHAR(50) DEFAULT 'user',
            `firstname` VARCHAR(50) DEFAULT '',
            `lastname`  VARCHAR(50) DEFAULT '',
            `job`       JSON,
            `gang`      VARCHAR(50) DEFAULT 'none',
            `money`     DOUBLE DEFAULT 50.0,
            `gold`      DOUBLE DEFAULT 0.0,
            `inventory` JSON,
            `skin`      JSON,
            `coords`    JSON,
            `slots`     INT DEFAULT 50,
            `isdead`    TINYINT(1) DEFAULT 0,
            `xp`        INT DEFAULT 0,
            INDEX `idx_discord` (`discord`)
        )
    ]])

    -- lc_bans
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `lc_bans` (
            `id`         INT AUTO_INCREMENT PRIMARY KEY,
            `discord`    VARCHAR(50) NOT NULL,
            `reason`     VARCHAR(255) DEFAULT NULL,
            `expire`     DATETIME DEFAULT NULL,
            `banned_by`  VARCHAR(50) DEFAULT NULL,
            `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ]])

    -- lc_counties
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `lc_counties` (
            `id`    VARCHAR(50) PRIMARY KEY,
            `name`  VARCHAR(100) NOT NULL,
            `label` VARCHAR(100) NOT NULL,
            `tax`   DOUBLE DEFAULT 0.0,
            `mayor` INT DEFAULT NULL
        )
    ]])

    -- Insert default counties if empty
    local count = MySQL.scalar.await('SELECT COUNT(*) FROM lc_counties')
    if count == 0 then
        MySQL.query.await([[
            INSERT INTO `lc_counties` (`id`, `name`, `label`, `tax`) VALUES
                ('new_hanover',   'New Hanover',   'Comte de New Hanover',   0.0),
                ('lemoyne',       'Lemoyne',       'Comte de Lemoyne',       0.0),
                ('new_austin',    'New Austin',    'Comte de New Austin',    0.0),
                ('west_elizabeth','West Elizabeth', 'Comte de West Elizabeth',0.0),
                ('ambarino',      'Ambarino',      'Comte d Ambarino',       0.0)
        ]])
        print('[LcCore] ^2Default counties inserted^0')
    end

    print('[LcCore] ^2Database ready^0')
end)
