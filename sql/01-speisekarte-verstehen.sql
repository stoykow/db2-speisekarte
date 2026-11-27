-- Speisekarte: Dasselbe Gericht im Browser und in MariaDB ansehen.
-- Lege im Browser zuerst die Kategorie Vorspeisen und das Gericht Kräuterpita an.
-- Wähle in phpMyAdmin die Datenbank datenbank_demo und öffne den SQL-Tab.
-- Führe die Abfragen einzeln aus und lies jeweils das Ergebnis.

-- 1. USE wählt die Datenbank dieses Stacks aus.
USE datenbank_demo;

-- 2. SHOW CREATE TABLE zeigt, wie die beiden Tabellen aufgebaut sind.
-- PRIMARY KEY kennzeichnet die ID als eindeutigen Schlüssel einer Zeile.
-- AUTO_INCREMENT vergibt beim Einfügen automatisch eine neue Nummer.
-- FOREIGN KEY prüft, ob die Kategorie-ID auf eine vorhandene Kategorie zeigt.
SHOW CREATE TABLE speisekarte_kategorie;
SHOW CREATE TABLE speisekarte_gericht;

-- 3. SELECT wählt die Spalten aus. Prüfe die ID deines Gerichts im Browser.
SELECT id, kategorie_id, name, preis
FROM speisekarte_gericht
ORDER BY id;

-- 4. Der JOIN ergänzt den Kategorienamen. ON vergleicht die beiden IDs.
-- g und k sind Kurznamen für die Tabellen Gericht und Kategorie.
SELECT g.id, g.name AS gericht, k.name AS kategorie, g.preis
FROM speisekarte_gericht AS g
JOIN speisekarte_kategorie AS k ON k.id = g.kategorie_id
ORDER BY g.id;

-- 5. Optional: Füge ein Gericht direkt mit SQL ein.
-- SELECT liest die vorhandene ID der Kategorie Vorspeisen.
-- INSERT speichert mit dieser ID die neue Zeile. Der Preis hat einen Punkt.
-- Führe diesen Block einmal aus. Lade danach die Webseite neu.
INSERT INTO speisekarte_gericht
    (kategorie_id, name, beschreibung, preis)
SELECT id, 'Feta mit Oliven', 'Mit Kräutern und Brot', 7.50
FROM speisekarte_kategorie
WHERE name = 'Vorspeisen';
