-- DB2-Übungsimport der Rhodos-Speisekarte, Datenstand 04.10.2026.
-- Der Datenstand stammt aus data/menu.json der Originalwebseite.
-- Die App speichert Kategorie, Name, Beschreibung und Preis. Die Gerichts-ID
-- vergibt deine Datenbank. Bilder und Zusatzstoffangaben gehören zum Original.
--
-- Öffne zuvor die DB2-Speisekarte einmal, damit PHP beide Tabellen anlegt.
-- Kopiere in phpMyAdmin den gesamten Inhalt in den SQL-Tab und führe ihn einmal aus.
-- Der Import ergänzt fehlende Zeilen. Vorhandene Gerichte und Preise bleiben erhalten.

USE datenbank_demo;
SET NAMES utf8mb4;

-- Die temporäre Tabelle ist ein Zwischenspeicher für diese Verbindung.
DROP TEMPORARY TABLE IF EXISTS tmp_db2_rhodos_import;
CREATE TEMPORARY TABLE tmp_db2_rhodos_import (
    position SMALLINT UNSIGNED PRIMARY KEY,
    kategorie_position SMALLINT UNSIGNED NOT NULL,
    kategorie VARCHAR(50) NOT NULL,
    name VARCHAR(80) NOT NULL,
    beschreibung VARCHAR(160) NOT NULL,
    preis DECIMAL(7,2) NOT NULL,
    namensvariante BOOLEAN NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO tmp_db2_rhodos_import
    (position, kategorie_position, kategorie, name, beschreibung, preis, namensvariante)
VALUES
    -- Vorspeisen
    (1, 1, 'Vorspeisen', 'Oliven und Peperoni mit Zaziki',
     'dazu Brot', 6.50, 0),
    (2, 1, 'Vorspeisen', 'Gemischter Teller II',
     'Zaziki, Schafskäsesalat und Auberginensalat', 6.50, 0),
    (3, 1, 'Vorspeisen', 'Tiropitakia',
     'warm Blätterteig gefüllt mit Schafskäse, dazu Zaziki', 6.50, 0),
    (4, 1, 'Vorspeisen', 'Schafskäsesalat',
     'püriert mit Paprika, feinem Knoblauch, Peperoni, Öl und frischen Kräutern, dazu Brot', 6.50, 0),
    (5, 1, 'Vorspeisen', 'Gemischter Teller III',
     'warm Auberginen und Zucchini, Tiropitakia, Zaziki u. Brot', 6.50, 0),
    (6, 1, 'Vorspeisen', 'Folienkartoffeln mit Zaziki',
     '', 6.00, 0),
    (7, 1, 'Vorspeisen', 'Spanakopitakia',
     'warm Blätterteig gefüllt mit Spinat, dazu Zaziki', 6.50, 0),
    (8, 1, 'Vorspeisen', 'Zaziki',
     'griechische Hirtenspeise aus Joghurt, Knoblauch und Kräutern, dazu Brot', 5.00, 0),
    (9, 1, 'Vorspeisen', 'Tarama',
     'Fischrogensalat, dazu Brot', 5.50, 0),
    (10, 1, 'Vorspeisen', 'Dolmadakia',
     'warm gefüllte Weinblätter mit Reis, überbacken mit Schafskäse, dazu Brot', 5.90, 0),
    (11, 1, 'Vorspeisen', 'Kalamariasalat',
     'Tintenfischsalat, dazu Brot', 6.90, 0),
    (12, 1, 'Vorspeisen', 'Melitzanosalata',
     'Auberginencreme dazu Brot', 5.50, 0),
    (13, 1, 'Vorspeisen', 'Dicke Bohnen',
     'warm mit Schafskäse Überbacken, dazu Brot', 5.50, 0),
    (14, 1, 'Vorspeisen', 'Oliven und Peperoni',
     'dazu Brot', 5.50, 0),
    (15, 1, 'Vorspeisen', 'Peperoni gegrillt mit frischem Knoblauch',
     'dazu Brot', 5.00, 0),
    (16, 1, 'Vorspeisen', 'Mese-Platte',
     'Tarama, Zaziki, Oliven, Peperoni, Dolmadakia, Auberginensalat, Kalamariasalat, Schafskäsesalat, Schafskäse und Brot', 13.90, 0),
    (17, 1, 'Vorspeisen', 'Gebackene Auberginen mit Zaziki',
     '', 5.50, 0),
    (18, 1, 'Vorspeisen', 'Gebackene Zucchini mit Zaziki',
     '', 5.50, 0),
    (19, 1, 'Vorspeisen', 'Knoblauchbrot',
     'gehackte Tomaten und Knoblauch mit frischen Kräutern auf knusprig gebackenen Weißbrot', 5.50, 0),
    -- Salate
    (20, 2, 'Salate', 'Gemischter Salat',
     'Tomaten und Gurken', 5.00, 0),
    (21, 2, 'Salate', 'Bauernsalat „griechischer Art“',
     'klein, dazu Brot', 8.50, 1),
    (22, 2, 'Salate', 'Bauernsalat „griechischer Art“',
     'mit Gurken, Tomaten, Krautsalat, grünen Salat, Peperoni , Oliven und Schafskäse, dazu Brot', 13.00, 1),
    (23, 2, 'Salate', 'Krautsalat',
     'oder gemischter grüner Salat', 4.50, 0),
    -- Beilagen
    (24, 3, 'Beilagen', 'Pommes Frites',
     '', 4.50, 0),
    (25, 3, 'Beilagen', 'Reis in Tomatensauce',
     '', 4.00, 0),
    (26, 3, 'Beilagen', 'Reisnudeln in Tomatensauce',
     '', 4.00, 0),
    (27, 3, 'Beilagen', 'Kretanische Kartoffeln',
     'gebratene Kartoffelscheiben mit Sahnesauce überbacken', 5.00, 0),
    (28, 3, 'Beilagen', 'Kroketten',
     '', 4.00, 0),
    -- Käse
    (29, 4, 'Käse', 'Portion Schafskäse',
     'dazu Brot', 6.00, 0),
    (30, 4, 'Käse', 'Saganaki',
     'Schafskäse paniert, warm, dazu Brot', 6.50, 0),
    (31, 4, 'Käse', 'Portion Schafskäse aus dem Ofen',
     'mit Peperoni, Paprika, Zwiebeln, Tomaten und Öl dazu Brot', 7.50, 0),
    -- Suppen
    (32, 5, 'Suppen', 'Bohnensuppe',
     '', 4.50, 0),
    (33, 5, 'Suppen', 'Gulaschsuppe',
     '', 4.50, 0),
    (34, 5, 'Suppen', 'Hühnersuppe',
     '', 4.50, 0),
    -- Für unsere kleinen Gäste
    (35, 6, 'Für unsere kleinen Gäste', 'Spaghetti',
     'mit Hackfleisch in Tomatensauce', 6.50, 0),
    (36, 6, 'Für unsere kleinen Gäste', 'Gyros',
     'mit Pommes Frites und Salatbeilagen', 8.50, 0),
    (37, 6, 'Für unsere kleinen Gäste', 'Souflaki',
     'mit Pommes Frites und Salatbeilagen', 8.50, 0),
    (38, 6, 'Für unsere kleinen Gäste', 'Souzouki',
     'mit Pommes Frites und Salatbeilagen', 8.50, 0),
    (39, 6, 'Für unsere kleinen Gäste', 'Schweinesteak',
     'oder Hähnchenbrust oder Schweineschnitzel mit Pommes Frites und Salatbeilagen', 8.50, 0),
    -- Gemischte Spezialitäten
    (40, 7, 'Gemischte Spezialitäten', 'Irodion-Platte',
     '2 Scheiben Rinderleber, Gyros, Reis und Salat', 15.90, 0),
    (41, 7, 'Gemischte Spezialitäten', 'Giouvetzi-Gyros',
     'Gyros und Reisnudeln mit Butterkäse überbacken, dazu Salat', 15.90, 0),
    (42, 7, 'Gemischte Spezialitäten', 'Evelina-Spezialität',
     'Gyros mit Zaziki und Reis in Tomatensauce, ein halbes Mousaka, dazu Salat', 17.50, 0),
    (43, 7, 'Gemischte Spezialitäten', 'Jolandas-Spezialität',
     'Gyros, Kalamaria mit Reis, Zaziki und Salat', 17.50, 0),
    (44, 7, 'Gemischte Spezialitäten', 'Vicky-Spezialität',
     '1 Suflaki, 1 Souzouki, 1 Lammkotelett, Gyros, Zaziki Reis und Salat', 17.90, 0),
    (45, 7, 'Gemischte Spezialitäten', 'Pita Gyros',
     'mit Fladenbrot, Zaziki, Zwiebeln, Tomaten und Salat', 15.90, 0),
    (46, 7, 'Gemischte Spezialitäten', 'Ouzo Platte',
     '1 Souzouki, 1 Lammkotelett, Gyros, Reis und Salat', 16.50, 0),
    (47, 7, 'Gemischte Spezialitäten', 'Santorini Platte',
     '2 Souzouki, Gyros, Reis und Salat', 15.90, 0),
    (48, 7, 'Gemischte Spezialitäten', 'Hellas Platte',
     'Lammkotelett, Leber, Souzouki, Gyros, Reis und Salat', 17.50, 0),
    (49, 7, 'Gemischte Spezialitäten', 'Athen Platte',
     'Gyros, Schweinefilet, Schweinesteak, Reis mit Salat', 16.90, 0),
    -- Aus dem Backofen
    (50, 8, 'Aus dem Backofen', 'Moussaka',
     'Eine griechische Spezialität aus gebratenen Auberginenscheiben, frittierten Kartoffelscheiben, lecker angemachtem Hackfleisch, überbacken mit Bechamelsauce', 16.90, 0),
    (51, 8, 'Aus dem Backofen', 'Lammfleisch-Haxe',
     'mit Spaghetti und Käse überbacken, dazu Salat', 18.90, 1),
    (52, 8, 'Aus dem Backofen', 'Lammfleisch-Haxe',
     'mit Kretanischen Kartoffeln, dazu Salat', 18.90, 1),
    (53, 8, 'Aus dem Backofen', 'Lammfleisch-Haxe',
     'mit grünen Bohnen und Salat', 18.90, 1),
    (54, 8, 'Aus dem Backofen', 'Lammfleisch-Haxe',
     'mit dicken Bohnen und Salat', 19.90, 1),
    (55, 8, 'Aus dem Backofen', 'Giouvetzi ,',
     'Lammfleisch-Haxe mit Reisnudeln, Käse überbacken und Salat', 19.90, 1),
    (56, 8, 'Aus dem Backofen', 'Giouvetzi ,',
     'Lammfleisch-Haxe mit Auberginen, Käse überbacken und Salat', 19.90, 1),
    (57, 8, 'Aus dem Backofen', 'Giouvetzi ,',
     'Lammfleisch-Haxe, mit dicken Bohnen, Käse überbacken und Salat', 19.90, 1),
    (58, 8, 'Aus dem Backofen', 'Stifado',
     'Lammfleisch-Haxe, mit kleinen Zwiebelchen in Tomatensauce, leicht süßlich und Salat', 18.90, 0),
    -- Grillspezialitäten
    (59, 9, 'Grillspezialitäten', 'Gyros',
     'mit Reis, Zaziki und Salat', 15.90, 0),
    (60, 9, 'Grillspezialitäten', 'Gyros überbacken',
     'mit Sauce, Käse, Reis und Salat', 16.90, 0),
    (61, 9, 'Grillspezialitäten', 'Bifteki',
     'Hacksteak mit Schafskäse gefüllt, Reis, Sauce und Salat', 16.90, 0),
    (62, 9, 'Grillspezialitäten', 'Souzouki',
     'Fleischküchle mit Reis und Salat', 15.90, 1),
    (63, 9, 'Grillspezialitäten', 'Souflaki',
     '2 gegrillte Fleischspieße mit Reis und Salat', 16.50, 0),
    (64, 9, 'Grillspezialitäten', 'Souzouki',
     'mit Sauce und Käse überbacken dazu Reis und Salat', 16.90, 1),
    (65, 9, 'Grillspezialitäten', 'Lammkoteletts',
     '(5 Stück) mit Zitrone, Reis und Salat', 19.00, 0),
    (66, 9, 'Grillspezialitäten', 'Rinderleber',
     'mit gerösteten Zwiebeln, Reis und Salat', 15.90, 0),
    (67, 9, 'Grillspezialitäten', '3 kleine Schweinesteaks',
     'mit Kräuterbutter und Salat', 15.50, 0),
    -- Filet- und Steakgerichte
    (68, 10, 'Filet- und Steakgerichte', 'Schweinefilet',
     'mit Ananas, Käse und Metaxasauce, überbacken, Pommes Frites und Salat', 18.50, 1),
    (69, 10, 'Filet- und Steakgerichte', 'Schweinefilet',
     'mit Kräuterbutter, Pommes Frites und Salat', 17.50, 1),
    (70, 10, 'Filet- und Steakgerichte', 'Schweinefilet',
     'gefüllt mit Schafskäse, Sauce, Pommes Frites und Salat', 18.50, 1),
    (71, 10, 'Filet- und Steakgerichte', 'Olympia-Teller',
     '2 kleine Schweinesteaks mit Ananas, Sauce und Käse überbacken, dazu Reis und Salat', 16.50, 0),
    (72, 10, 'Filet- und Steakgerichte', 'Schweinefilet und Rinderleber',
     'mit gerösteten Zwiebeln, Pommes Frites und Salat', 17.90, 0),
    (73, 10, 'Filet- und Steakgerichte', 'Kotopoulo',
     'gegrilltes Hähnchenbrustfilet in pikanter Sauce (mit Pilzen), dazu Butterreis und Salat', 16.50, 0),
    (74, 10, 'Filet- und Steakgerichte', 'Hähnchenschnitzel',
     '2 Hähnchenbrustfiletschnitzel in pikanter Sauce (mit Pilzen), mit Pommes Frites und Salat', 16.50, 0),
    (75, 10, 'Filet- und Steakgerichte', 'Naxos-Platte',
     'Lammfilet mit Kräuterbutter, Pommes Frites und Salat', 19.90, 0),
    (76, 10, 'Filet- und Steakgerichte', 'Kotopoulo-Teller',
     'Hähnchenbrustfilet mit Ananas, Sauce und Käse überbacken, dazu Reis und Salat', 17.50, 0),
    (77, 10, 'Filet- und Steakgerichte', 'Schweinefiletröllchen',
     'gefüllt mit Butterkäse, gerösteten Zwiebeln, Pommes Frites und Salat', 18.50, 0),
    (78, 10, 'Filet- und Steakgerichte', 'Schweinesteak',
     'überbacken mit Butterkäse und Rahmsauce, kretanischen Kartoffeln und Salat', 17.00, 0),
    (79, 10, 'Filet- und Steakgerichte', 'Lammfilet',
     'überbacken mit Butterkäse in pikanter Sauce, kretanischen Kartoffeln und Salat', 20.90, 0),
    -- Pfännchengerichte
    (80, 11, 'Pfännchengerichte', 'Gyros in pikanter Sauce',
     'verfeinert mit Creme fraiche, frischen Champignons und frische Kräuter, dazu Brot und Salat', 16.90, 0),
    (81, 11, 'Pfännchengerichte', '2 Schweinemedallions in Chassisrahmsauce',
     'verfeinert mit Creme fraiche, frischen Champignons und frischen Kräutern, dazu Brot und Salat', 18.00, 0),
    (82, 11, 'Pfännchengerichte', '2 Schweinesteaks in Chassisrahmsauce',
     'verfeinert mit Creme fraiche, frischen Champignons und frischen Kräutern, dazu Brot und Salat', 18.00, 0),
    (83, 11, 'Pfännchengerichte', 'Scampi-Pfännchen in pikanter Sauce',
     'verfeinert mit Metaxa, Schafskäse, dazu Brot u. Salat', 17.50, 0),
    (84, 11, 'Pfännchengerichte', 'Lammfilet in pikanter Sauce',
     'verfeinert mit Metaxa, Creme fraiche, frischen Champignons und frischen Kräutern, dazu Brot und Salat', 20.90, 0),
    (85, 11, 'Pfännchengerichte', 'Kotopoulo-Pfännchen',
     'Hähnchenbrustfilet in pikanter Weinsauce, verfeinert mit Creme fraiche, frischen Champignons und frische Kräuter, Salat, dazu Brot', 17.00, 0),
    -- Gemischte Fleischplatte
    (86, 12, 'Gemischte Fleischplatte', 'Zeus-Platte',
     'Gyros, Suflaki mit Reis und Salat', 17.50, 0),
    (87, 12, 'Gemischte Fleischplatte', 'Dionysos-Platte',
     'Gyros, Suflaki, Leber mit Reis und Salat', 18.50, 0),
    (88, 12, 'Gemischte Fleischplatte', 'Apollon-Platte',
     'Suflaki, Steak, Lammkotelett, 2 Souzouki mit Reis und Salat', 18.50, 0),
    (89, 12, 'Gemischte Fleischplatte', 'Kreta-Platte',
     'Gyros, Lammkotelett, Suflaki, Schweinekotelett, mit Reis und Salat', 18.50, 0),
    (90, 12, 'Gemischte Fleischplatte', 'Delphi-Platte',
     'Schweinesteak, Schweinefilet, Leber, 2 Souzouki mit Reis und Salat', 18.90, 0),
    (91, 12, 'Gemischte Fleischplatte', 'Grill-Platte',
     '2 Lammkotelett, 1 Suflaki, Gyros, Zaziki, dazu Reis und Salat', 18.90, 0),
    (92, 12, 'Gemischte Fleischplatte', 'Schnitzel',
     'paniert mit Sauce, Pommes Frites, Salat', 14.90, 0),
    -- Fischgerichte
    (93, 13, 'Fischgerichte', 'Kalamaria, fritiert',
     'mit Reis, Knoblauchsauce und Salat', 15.90, 0),
    (94, 13, 'Fischgerichte', 'Seezungenfilet, fritiert',
     'mit Reis, Knoblauchsauce und Salat', 15.90, 0),
    (95, 13, 'Fischgerichte', 'Scampis, geschält, fritiert',
     'mit Reis, Knoblauchsauce und Salat', 16.90, 0),
    (96, 13, 'Fischgerichte', 'Fischplatte',
     'mit Kalamaria, Seezungenfilet, Scampis, Reis, Knoblauchsauce und Salat', 18.50, 0),
    (97, 13, 'Fischgerichte', 'Thunfischsteak, gegrillt',
     'mit Reis, Knoblauchsauce und Salat', 18.50, 0),
    -- Nudelgerichte
    (98, 14, 'Nudelgerichte', 'Spaghetti mit Hackfleisch in Tomatensauce',
     '', 9.90, 0),
    (99, 14, 'Nudelgerichte', 'Spagetti à la Griechisch',
     'Spaghetti mit Hackfleisch in Tomatensauce und Käse überbacken', 10.50, 0),
    -- Gemista-Gerichte
    (100, 15, 'Gemista-Gerichte', 'Gemista , kretanisch',
     'Paprika und Tomaten mit Kräuterreis gefüllt, dazu kretanische Kartoffeln und Salat', 14.90, 0),
    (101, 15, 'Gemista-Gerichte', 'Gemista mit Fleischklößchen',
     'Paprika und Tomaten mit Kräuterreis gefüllt und Hackfleischklößchen in Tomatensauce, dazu Salat', 14.90, 0),
    -- Mittags- und Seniorenkarte
    (102, 16, 'Mittags- und Seniorenkarte', 'Seezungenfilet',
     'mit Reis, Knoblauchsauce und Salat', 11.90, 0),
    (103, 16, 'Mittags- und Seniorenkarte', 'Schweinesteak',
     'mit Ananas, Sauce und Butterkäse überbacken, Reis und Salat', 11.90, 0),
    (104, 16, 'Mittags- und Seniorenkarte', 'Gyros',
     'mit Reis, Zaziki und Salat', 11.90, 0),
    (105, 16, 'Mittags- und Seniorenkarte', 'Souflaki',
     '1 Fleischspieß mit Reis und Salat', 11.90, 0),
    (106, 16, 'Mittags- und Seniorenkarte', 'Souzouki',
     'Fleischküchle mit Reis und Salat', 11.90, 0),
    (107, 16, 'Mittags- und Seniorenkarte', 'Schweinsteak',
     'mit Reis und Salat', 11.90, 0),
    (108, 16, 'Mittags- und Seniorenkarte', 'Gyros in pikanter Sauce',
     'verfeinert mit Creme fraiche, frischen Champignons und frischen Kräutern, dazu Brot und Salat', 13.50, 0),
    (109, 16, 'Mittags- und Seniorenkarte', 'Schweinemedaillon in Chassisrahmsauce',
     'verfeinert mit Creme fraiche, frischen Champignons und frischen Kräutern, dazu Brot und Salat', 13.50, 0),
    (110, 16, 'Mittags- und Seniorenkarte', 'Kotopoulo Pfännchen',
     'Hühnerbrustfilet verfeinert mit Creme fraiche, frische Champignons, frische Kräuter dazu Brot und Salat', 13.50, 0);

-- Die Sperre lässt zwei gleichzeitige Importe nacheinander arbeiten.
SET @db2_import_sperre = GET_LOCK('db2_datenbank_demo_rhodos_import', 10);
START TRANSACTION;

-- phpMyAdmin kann zwischen Befehlen eigene Abfragen ausführen.
-- Deshalb vergleichen wir die Bestände der Tabellen vor und nach dem Import.
SET @db2_kategorien_vorher = (SELECT COUNT(*) FROM speisekarte_kategorie);
SET @db2_gerichte_vorher = (SELECT COUNT(*) FROM speisekarte_gericht);

-- Kategorienamen vergleichen. ORDER BY hält beim Neuimport die Kartenreihenfolge ein.
INSERT INTO speisekarte_kategorie (name)
SELECT src.kategorie
FROM tmp_db2_rhodos_import AS src
WHERE @db2_import_sperre = 1
  AND NOT EXISTS (
      SELECT 1 FROM speisekarte_kategorie AS vorhanden
      WHERE vorhanden.name = src.kategorie
  )
GROUP BY src.kategorie, src.kategorie_position
ORDER BY src.kategorie_position;

-- Ein Gericht ist in seiner Kategorie am Namen erkennbar.
-- Bei namensgleichen Varianten vergleichen wir zusätzlich die Beschreibung.
-- Der Preis gehört bewusst nicht zum Vergleich.
INSERT INTO speisekarte_gericht (kategorie_id, name, beschreibung, preis)
SELECT k.id, src.name, src.beschreibung, src.preis
FROM tmp_db2_rhodos_import AS src
JOIN speisekarte_kategorie AS k ON k.name = src.kategorie
WHERE @db2_import_sperre = 1
  AND NOT EXISTS (
      SELECT 1 FROM speisekarte_gericht AS vorhanden
      WHERE vorhanden.kategorie_id = k.id
        AND vorhanden.name = src.name
        AND (src.namensvariante = 0 OR vorhanden.beschreibung = src.beschreibung)
  )
ORDER BY src.position;

SET @db2_neue_kategorien = IF(@db2_import_sperre = 1,
    (SELECT COUNT(*) FROM speisekarte_kategorie) - @db2_kategorien_vorher, 0);
SET @db2_neue_gerichte = IF(@db2_import_sperre = 1,
    (SELECT COUNT(*) FROM speisekarte_gericht) - @db2_gerichte_vorher, 0);

COMMIT;
SET @db2_freigabe = IF(@db2_import_sperre = 1,
                      RELEASE_LOCK('db2_datenbank_demo_rhodos_import'), NULL);
DROP TEMPORARY TABLE tmp_db2_rhodos_import;

SELECT CASE
           WHEN @db2_import_sperre = 1 THEN 'Import abgeschlossen'
           ELSE 'Import besetzt. Führe den Block später erneut aus.'
       END AS status,
       @db2_neue_kategorien AS neue_kategorien,
       @db2_neue_gerichte AS neue_gerichte;
