<?php
declare(strict_types=1);

// getenv() liest Einstellungen, die Docker dem PHP-Container beim Start übergibt.
// DB_HOST ist der Dienstname db. Das Passwort erhält der Stack aus Portainer.
$host = getenv('DB_HOST');
$datenbank = getenv('DB_NAME');
$benutzer = getenv('DB_USER');
$passwort = getenv('DB_PASSWORD');

// PDO ist die Datenbankschnittstelle von PHP. Die Verbindungszeichenfolge nennt
// Host, Datenbank und Zeichensatz. utf8mb4 unterstützt auch Umlaute und Emojis.
$pdo = new PDO(
    "mysql:host=$host;dbname=$datenbank;charset=utf8mb4",
    $benutzer,
    $passwort,
    [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_EMULATE_PREPARES => false,
    ]
);

// Zuerst die Kategorien anlegen. AUTO_INCREMENT vergibt bei jeder neuen Zeile eine ID.
$pdo->exec(<<<'SQL'
    CREATE TABLE IF NOT EXISTS speisekarte_kategorie (
        id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(50) NOT NULL UNIQUE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    SQL
);

// Der Fremdschlüssel verweist auf eine vorhandene Kategorie.
// DECIMAL speichert den Preis mit zwei festen Nachkommastellen.
$pdo->exec(<<<'SQL'
    CREATE TABLE IF NOT EXISTS speisekarte_gericht (
        id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        kategorie_id INT UNSIGNED NOT NULL,
        name VARCHAR(80) NOT NULL,
        beschreibung VARCHAR(160) NOT NULL DEFAULT '',
        preis DECIMAL(7,2) NOT NULL,
        CONSTRAINT fk_speisekarte_kategorie
            FOREIGN KEY (kategorie_id) REFERENCES speisekarte_kategorie (id),
        CONSTRAINT chk_speisekarte_preis CHECK (preis > 0)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    SQL
);

// index.php nutzt diese fertige Verbindung für seine SQL-Abfragen.
return $pdo;
