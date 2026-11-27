---
lang: de-DE
title: "SQL-Übungen mit der Speisekarte"
subtitle: "Praxis für Tag 04"
module: "Datenbanken und SQL 2"
toc: false
---

# Mit der Speisekarte in phpMyAdmin arbeiten

Du arbeitest mit der Speisekarte, die du bereits eingerichtet hast. Gemeinsam mit der Gruppe prüfst du eine Preisänderung in MariaDB, nimmst sie zurück und speicherst sie in einem zweiten Durchlauf. Anschließend modellierst du Zusatzstoffe und verknüpfst sie mit eigenen Testgerichten. Die Preise kannst du auf der Webseite kontrollieren. Die Zusatzstoffe siehst du in phpMyAdmin.

## Speisekarte als Übungsdaten importieren

1. Öffne zuerst die [Speisekarte](http://docker.local:8090/) einmal im Browser. Dadurch legt PHP die Tabellen an, falls sie noch fehlen.
2. Öffne [phpMyAdmin](http://docker.local:8091/), melde dich als `demo_app` an und wähle links `datenbank_demo`. Öffne oben **SQL**.
3. Öffne die [SQL-Datei mit der Rhodos-Speisekarte](sql/02-rhodos-speisekarte-import.sql). Kopiere ihren gesamten Inhalt in das SQL-Feld. Klicke einmal auf **OK**. Der Import läuft in einer Verbindung.
4. Lies unten `neue_kategorien` und `neue_gerichte` ab. Lade die Speisekarte neu und suche die Kategorie **Salate**.

Der Datenstand enthält **16 Kategorien und 110 Gerichte**. Je nach Bestand kommen beim ersten Lauf weniger Einträge hinzu. Dein bisheriger Bestand bleibt erhalten. Zum Abgleich nutzt der Import Kategorie und Gerichtsname. Bei mehreren gleichnamigen Varianten in einer Kategorie prüft er zusätzlich die Beschreibung. So bleiben zum Beispiel der kleine und der große Bauernsalat getrennte Gerichte. Der Preis dient nur als Wert für neue Gerichte.

Führe den Import direkt danach ein zweites Mal aus. Beide Zahlen sollen dann **0** sein. Das zeigt dir, dass sich der Import wiederholen lässt.

## Gerichte abfragen

Tippe die Abfragen für die ersten drei Übungen selbst. Vergleiche die Ergebnisse mit der Speisekarte im Browser.

### Übung 1 Angebote im passenden Preisbereich finden

Schreibe eine Abfrage für Gerichte von **8,00 bis 12,00 Euro**. Gib `id`, `name` und `preis` aus. Sortiere zunächst nach Preis aufsteigend und bei gleichem Preis nach Name.

**Tipp.** Nutze `WHERE preis BETWEEN … AND …` und schreibe die Preise in SQL mit einem Punkt.

**Kontrolle.** Beide Grenzen zählen mit. Die ID eines Treffers entspricht seiner Nummer auf der Webseite.

### Übung 2 Gerichte mit ihrem Kategorienamen anzeigen

Zeige nur Gerichte aus **Vorspeisen**. Die Ergebnisliste soll eine Spalte `kategorie` und daneben Gerichtsname und Preis enthalten.

**Tipp.** Verbinde `speisekarte_gericht.kategorie_id` mit `speisekarte_kategorie.id`. Filtere nach dem Namen der Kategorie.

**Kontrolle.** In der Spalte `kategorie` steht bei jeder Zeile **Vorspeisen**. Eigene Gerichte aus dieser Kategorie darfst du dort ebenfalls sehen.

### Übung 3 Gerichte je Kategorie zählen

Gib für jede Kategorie den Namen und die Anzahl der zugeordneten Gerichte aus. Lege bei Bedarf im Browser eine leere Kategorie **Tag 04 Reserve** an und nutze sie zur Kontrolle.

**Tipp.** Starte bei `speisekarte_kategorie`, nutze einen `LEFT JOIN` und gruppiere nach Kategorie-ID und -Name. Zähle mit `COUNT(g.id)` die Gerichte.

**Kontrolle.** Die leere Kategorie erscheint mit der Anzahl **0**. Ihre Zeile bleibt durch den `LEFT JOIN` im Ergebnis. Wenn du `COUNT(*)` verwendest, zählt MariaDB auch diese Ergebniszeile mit.

## Einen Preis Schritt für Schritt ändern

Lege auf der Webseite unter **Vorspeisen** ein eigenes Testgericht **SQL-Übung Kräuterbrot** für **4,20 Euro** an. Notiere die Nummer, die neben dem Gericht steht. Verwende in den folgenden SQL-Blöcken deine Nummer überall dort, wo bei `@gericht_id` die `0` steht. Die `0` ist ein Platzhalter. MariaDB vergibt für die Gerichte beim Anlegen positive IDs.

In phpMyAdmin öffnest du für jeden Versuch den SQL-Tab, tippst den vollständigen Block und klickst erst am Ende auf **OK**. Eine Transaktion und ihre Variablen gehören zu derselben Datenbankverbindung. Ein weiterer Klick auf **OK** kann eine neue Verbindung öffnen. Daher enthält jeder Block seine eigenen `SET`-Anweisungen und endet mit `COMMIT` oder `ROLLBACK`, wenn er eine Transaktion startet.

### Übung 4 Mit SET einen Wert merken

Tippe zunächst diesen kleinen Block. Ersetze die `0` durch deine Nummer.

```sql
SET @gericht_id = 0;
SET @probe_preis = 4.80;

SELECT id, name, preis, @probe_preis AS geplanter_preis
FROM speisekarte_gericht
WHERE id = @gericht_id;
```

1. `SET @gericht_id = …` legt in dieser Verbindung eine Variable an und speichert darin deine Nummer. Variablennamen dieser Art beginnen mit `@`. Du kannst dir eine Variable als beschriftetes Feld für einen Wert vorstellen.
2. `SET @probe_preis = 4.80` merkt sich den geplanten Preis. Die Tabelle enthält weiterhin den bisherigen Preis.
3. `WHERE id = @gericht_id` verwendet die gespeicherte Nummer. `AS geplanter_preis` gibt der Ergebnisspalte einen lesbaren Namen.

**Kontrolle.** Du siehst dein Kräuterbrot mit **4,20** unter `preis` und **4,80** unter `geplanter_preis`. Prüfe vor jedem schreibenden Block auf diese Weise, ob deine Nummer und der Name stimmen. [MariaDB-Dokumentation zu Benutzervariablen](https://mariadb.com/docs/server/reference/sql-structure/sql-language-structure/user-defined-variables)

### Übung 5 Eine Preisänderung mit ROLLBACK zurücknehmen

Mit `SELECT @@autocommit AS automatisch_speichern;` kannst du zuerst prüfen, wie MariaDB einzelne Änderungen normalerweise behandelt. Der Wert `1` bedeutet, dass MariaDB eine erfolgreiche Änderung außerhalb einer ausdrücklich geöffneten Transaktion sofort bestätigt.

Jetzt öffnest du mit `START TRANSACTION` einen Vorgang, dessen Änderungen du gemeinsam bestätigen oder zurücknehmen kannst. Vor dem Ausführen sagst du voraus, welche beiden Preise die letzte Abfrage zeigen wird. Tippe dann den Block mit deiner ID.

```sql
SET @gericht_id = 0;
SET @probe_preis = 4.80;

START TRANSACTION;

UPDATE speisekarte_gericht
SET preis = @probe_preis
WHERE id = @gericht_id AND name = 'SQL-Übung Kräuterbrot';

SELECT preis INTO @preis_waehrenddessen
FROM speisekarte_gericht
WHERE id = @gericht_id;

ROLLBACK;

SELECT name, @preis_waehrenddessen AS testpreis,
       preis AS gespeicherter_preis
FROM speisekarte_gericht
WHERE id = @gericht_id;
```

1. `START TRANSACTION` öffnet die Transaktion.
2. `UPDATE … SET preis = …` ändert die Tabellenspalte `preis`. In Übung 4 hat `SET @probe_preis = …` nur eine Variable gesetzt. Hier gibt `SET` als Teil von `UPDATE` an, welche Spalte einen neuen Wert bekommt. `WHERE` begrenzt die Änderung auf dein Kräuterbrot.
3. `SELECT preis INTO @preis_waehrenddessen` liest den tatsächlich geänderten Tabellenwert und merkt ihn in einer Variablen. Innerhalb dieser Verbindung ist die Änderung schon sichtbar.
4. `ROLLBACK` nimmt die Tabellenänderung der offenen Transaktion zurück. Der gemerkte Wert in der Variablen bleibt für die letzte Abfrage erhalten.
5. Das letzte `SELECT` zeigt den gemerkten Wert neben dem Preis, der jetzt in der Tabelle steht.

**Kontrolle.** Die Abfrage zeigt **4,80** als Testpreis und **4,20** als gespeicherten Preis. Lade die Webseite neu. Dort steht wieder **4,20 Euro**. `ROLLBACK` hat ein tatsächlich ausgeführtes `UPDATE` rückgängig gemacht. [MariaDB-Dokumentation zu START TRANSACTION](https://mariadb.com/docs/server/reference/sql-statements/transactions/start-transaction)

### Übung 6 Eine Änderung mit COMMIT speichern

1. Tippe denselben Block erneut und verwende wieder deine ID.
2. Setze `@probe_preis` diesmal auf `4.60`. Ersetze `ROLLBACK` durch `COMMIT`.
3. Sage voraus, welche Preise das letzte `SELECT` zeigt. Führe den Block mit einem Klick aus und lade die Webseite neu.

**Kontrolle.** Beide Spalten und die Webseite zeigen **4,60 Euro**. `COMMIT` hat die Änderung bestätigt. `ROLLBACK` wirkt auf die gerade offene Transaktion. Um den bestätigten Preis wieder zu ändern, brauchst du ein neues `UPDATE`.

## Zusatzstoffe in der Datenbank modellieren

Ein Gericht kann mehrere Zusatzstoff-Einträge haben. Derselbe Eintrag kann zu mehreren Gerichten gehören. Dafür bauen wir eine **n:m-Beziehung** auf. `speisekarte_zusatzstoff` enthält die Legende. `speisekarte_gericht_zusatzstoff` speichert je Zuordnung genau zwei IDs, die ID des Gerichts und die ID des Zusatzstoff-Eintrags.

Die drei Bezeichnungen stammen aus der Legende der Rhodos-Speisekarte. Die Zuordnungen in dieser Übung sind frei gewählt. Verwende sie ausschließlich mit deinen SQL-Testgerichten. Die Webseite liest weiterhin ihre bisherigen Tabellen. Du kontrollierst die neuen Zuordnungen mit SQL.

### Übung 7 Zwei Tabellen anlegen

Führe die beiden `CREATE TABLE`-Anweisungen zuerst als eigenen Block aus. `CREATE TABLE` ist eine Änderung am Tabellenaufbau. MariaDB kann damit eine offene Transaktion automatisch bestätigen. Für die späteren Tests fangen wir erst nach dem Anlegen eine Transaktion an.

```sql
CREATE TABLE IF NOT EXISTS speisekarte_zusatzstoff (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code TINYINT UNSIGNED NOT NULL UNIQUE,
    bezeichnung VARCHAR(80) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS speisekarte_gericht_zusatzstoff (
    gericht_id INT UNSIGNED NOT NULL,
    zusatzstoff_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (gericht_id, zusatzstoff_id),
    FOREIGN KEY (gericht_id) REFERENCES speisekarte_gericht (id),
    FOREIGN KEY (zusatzstoff_id) REFERENCES speisekarte_zusatzstoff (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

- `code` ist die Nummer aus der Legende. `id` ist die interne Nummer, die MariaDB vergibt. `UNIQUE` erlaubt jeden Code nur einmal.
- Der zusammengesetzte `PRIMARY KEY` erlaubt jedes Paar aus Gericht und Zusatzstoff nur einmal. Jede einzelne ID darf in verschiedenen Paaren vorkommen.
- Die beiden `FOREIGN KEY`-Regeln erlauben nur Verweise auf vorhandene Gerichte und Zusatzstoff-Einträge. Die ID-Spalten verwenden jeweils denselben Typ `INT UNSIGNED` wie ihre Ziele.

**Kontrolle.** Aktualisiere links die Tabellenliste. Öffne die Struktur der Verbindungstabelle. Dort findest du zwei Spalten, die zusammen den Primärschlüssel bilden. [MariaDB-Dokumentation zu Anweisungen mit automatischem COMMIT](https://mariadb.com/docs/server/reference/sql-statements/transactions/sql-statements-that-cause-an-implicit-commit)

### Übung 8 Die Zusatzstoff-Legende eintragen

Prüfe zuerst mit `SELECT * FROM speisekarte_zusatzstoff;`, welche Einträge es bereits gibt. Ist die Tabelle leer, tippe den folgenden Block. Sind schon Einträge vorhanden, ergänze mit `INSERT` nur die fehlenden Codes.

```sql
INSERT INTO speisekarte_zusatzstoff (code, bezeichnung)
VALUES (1, 'Konservierungsstoffe'),
       (2, 'Farbstoffe'),
       (3, 'Säurungsmittel');

SELECT id, code, bezeichnung
FROM speisekarte_zusatzstoff
ORDER BY code;
```

**Kontrolle.** Du siehst die drei Codes mit ihren Bezeichnungen. Die automatisch vergebenen IDs können auf deinem System anders aussehen als die Codes.

### Übung 9 Gerichte mit Zusatzstoffen verknüpfen

1. Lege auf der Webseite ein zweites Testgericht mit dem Namen **SQL-Übung Kräuterdip** für **3,20 Euro** an. Notiere auch dessen ID.
2. Schreibe zuerst die folgende `SELECT`-Abfrage mit dem `SET` darüber. Sie zeigt dir, welche beiden ID-Paare für dein Kräuterbrot entstehen. Passe die Platzhalter-ID an.

```sql
SET @gericht_id = 0;

SELECT g.id, z.id
FROM speisekarte_gericht AS g
CROSS JOIN speisekarte_zusatzstoff AS z
WHERE g.id = @gericht_id
  AND g.name = 'SQL-Übung Kräuterbrot'
  AND z.code IN (1, 2);
```

3. Wenn die Vorschau zwei Paare liefert, füge direkt vor `SELECT g.id, z.id` diese Zeile ein und führe den ganzen Block aus. `INSERT … SELECT` speichert für jede Ergebniszeile ein ID-Paar.

```sql
INSERT INTO speisekarte_gericht_zusatzstoff (gericht_id, zusatzstoff_id)
```

4. Passe den Block für deinen Kräuterdip an. Verwende seine eigene ID, ändere den Namen in der `WHERE`-Bedingung und wähle nur den Code `2`. Führe zuerst die Vorschau, dann das `INSERT` aus.

**Kontrolle.** In der Verbindungstabelle stehen jetzt zwei Zeilen für dein Kräuterbrot und eine für deinen Kräuterdip. Beide Gerichte teilen sich den Zusatzstoff-Eintrag mit Code `2`. Füge jedes Paar nur einmal ein. Wenn MariaDB bei einer Wiederholung einen doppelten Schlüssel meldet, findest du das Paar bereits in der Tabelle.

### Übung 10 Drei Tabellen mit JOIN lesen

Tippe die folgende Abfrage und trage beide IDs ein. Die Abfrage startet beim Gericht. Der erste `JOIN` findet seine Verknüpfungen, der zweite liest zu jedem Treffer die Bezeichnung aus der Legende.

```sql
SET @brot_id = 0;
SET @dip_id = 0;

SELECT g.name AS gericht, z.code, z.bezeichnung
FROM speisekarte_gericht AS g
JOIN speisekarte_gericht_zusatzstoff AS gz ON gz.gericht_id = g.id
JOIN speisekarte_zusatzstoff AS z ON z.id = gz.zusatzstoff_id
WHERE g.id IN (@brot_id, @dip_id)
ORDER BY g.id, z.code;
```

**Kontrolle.** Die Abfrage zeigt insgesamt drei Zeilen. Dein Kräuterbrot hat die Codes `1` und `2`, dein Kräuterdip den Code `2`.

**Selbst weiterarbeiten.** Ändere die Abfrage so, dass sie nur Code `2` zeigt. Erstelle danach eine zweite Abfrage, die alle Gerichte mit der Anzahl ihrer Zusatzstoff-Zuordnungen ausgibt. Nutze einen `LEFT JOIN`, `COUNT(gz.zusatzstoff_id)` und gruppiere nach Gerichts-ID und Name. Zum Schluss kannst du mit `HAVING COUNT(gz.zusatzstoff_id) >= 2` nur Gerichte mit mindestens zwei Zuordnungen anzeigen.

## Zwei Änderungen in einer Transaktion prüfen

### Übung 11 Preis und Zuordnung gemeinsam zurücknehmen

Dein Kräuterbrot kostet nach Übung 6 **4,60 Euro** und hat die Codes `1` und `2`. Prüfe diesen Stand, bevor du den Block ausführst. Jetzt soll der Preis auf **5,10 Euro** steigen und eine Zuordnung zu Code `3` dazukommen. Führe zuerst einen Test mit `ROLLBACK` aus.

```sql
SET @gericht_id = 0;
SET @probe_preis = 5.10;

START TRANSACTION;

UPDATE speisekarte_gericht
SET preis = @probe_preis
WHERE id = @gericht_id AND name = 'SQL-Übung Kräuterbrot';

INSERT INTO speisekarte_gericht_zusatzstoff (gericht_id, zusatzstoff_id)
SELECT g.id, z.id
FROM speisekarte_gericht AS g
CROSS JOIN speisekarte_zusatzstoff AS z
WHERE g.id = @gericht_id
  AND g.name = 'SQL-Übung Kräuterbrot' AND z.code = 3;

SELECT preis INTO @testpreis
FROM speisekarte_gericht WHERE id = @gericht_id;

SELECT COUNT(*) INTO @testanzahl
FROM speisekarte_gericht_zusatzstoff WHERE gericht_id = @gericht_id;

ROLLBACK;

SELECT g.name, @testpreis AS testpreis, g.preis AS gespeicherter_preis,
       @testanzahl AS testanzahl, COUNT(gz.zusatzstoff_id) AS gespeichert
FROM speisekarte_gericht AS g
LEFT JOIN speisekarte_gericht_zusatzstoff AS gz ON gz.gericht_id = g.id
WHERE g.id = @gericht_id
GROUP BY g.id, g.name, g.preis;
```

1. Die beiden Änderungen gehören zu derselben offenen Transaktion. `SELECT … INTO` merkt den Zwischenstand für die letzte Abfrage.
2. `ROLLBACK` nimmt Preisänderung und neue Zuordnung gemeinsam zurück.
3. Die letzte Abfrage vergleicht den gemerkten Teststand mit dem aktuellen Inhalt beider Tabellen.

**Kontrolle.** Als Zwischenstand siehst du **5,10 Euro** und **3 Zuordnungen**. Nach dem `ROLLBACK` bleiben **4,60 Euro** und **2 Zuordnungen** gespeichert. Wiederhole den Block mit `COMMIT`. Jetzt sollen **5,10 Euro** und **3 Zuordnungen** gespeichert sein. Lade die Webseite neu und prüfe den Preis. Die Zuordnungen siehst du mit der Abfrage aus Übung 10.

### Übung 12 Eine Zuordnung löschen und zurückholen

Schreibe selbst einen Transaktionsblock für deinen Kräuterbrot-Eintrag mit Code `2`. `DELETE` soll genau diese Zuordnung aus `speisekarte_gericht_zusatzstoff` entfernen. Ermittle zuvor per `SELECT` die IDs des Gerichts und des Zusatzstoff-Eintrags. Verwende für beide ID-Spalten eine `WHERE`-Bedingung. Beende den Block mit `ROLLBACK` und prüfe mit der Abfrage aus Übung 10, dass die Zuordnung wieder vorhanden ist.

**Tipp.** Teste zuerst dieselbe `WHERE`-Bedingung mit `SELECT`. Sie soll genau eine Zeile finden. Nach dem `DELETE` und vor `ROLLBACK` kannst du mit derselben Abfrage prüfen, dass diese Zeile in der offenen Transaktion verschwunden ist.

**Zusatzaufgabe.** Warum würde MariaDB das direkte Löschen eines Gerichts mit vorhandenen Zuordnungen ablehnen? Prüfe es anhand der Fremdschlüssel. Wenn du deine beiden Testgerichte anschließend dauerhaft aufräumen willst, löschst du zuerst ihre Zuordnungen und dann die Gerichte. Verwende dabei ausschließlich die vorher geprüften IDs deiner eigenen Testgerichte.

## Quellen und Hilfsmittel

- Übungsdaten und Zusatzstoff-Legende aus `data/menu.json` der Rhodos-Webseite, Stand 04.10.2026. Die in den Übungen zugeordneten Testgerichte wurden für den Unterricht erfunden.
- [Speisekarten-Handout zur Einführung](02-handout-speisekarte.md)
- KI-Unterstützung bei der Aufbereitung des Imports und der Ausarbeitung der Übungen.
