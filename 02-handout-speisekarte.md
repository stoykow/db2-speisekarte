---
lang: de-DE
title: "Die Speisekarte mit SQL pflegen"
subtitle: "Praxis für Tag 04"
module: "Datenbanken und SQL 2"
toc: true
---

# Die Speisekarte einrichten und mit SQL pflegen

**Voraussetzung.** Du erreichst Portainer und die SMB-Freigabe `docker` auf deiner Debian-VM. Wenn der Stack schon läuft und die Dateien im Ordner `Speisekarte` liegen, steige bei [Ein Gericht anlegen](#ein-gericht-anlegen) ein. [Projektanleitung](README.md)

## Den Stack in Portainer starten

1. Öffne [Portainer](https://docker.local:9443/) im Browser. Wähle **Stacks → Add stack → Web editor**.
2. Gib dem Stack den Namen `datenbank-demo` und füge den Inhalt von [stack.yaml](stack.yaml) ein.
3. Klicke unter **Environment variables** auf **Add environment variable**. Gib als **Name** `DEMO_DB_PASSWORT` ein. Trage unter **Value** dein Datenbankpasswort ein und klicke auf **Deploy the stack**. [Portainer-Dokumentation](https://docs.portainer.io/user/docker/stacks/add)
4. Öffne [phpMyAdmin für die Speisekarte](http://docker.local:8091/) in einem eigenen Browser-Tab. Melde dich als `demo_app` mit dem eben gesetzten Passwort an und wähle links `datenbank_demo`. Bei einem frischen Stack ist die Datenbank zunächst leer.

Falls der Stack `datenbank-demo` bereits vorhanden ist, füge den aktuellen YAML-Inhalt im **Editor** dieses Stacks ein und klicke auf **Update the stack**. Verwende dabei dein bisheriges Datenbankpasswort.

## Webdateien über SMB kopieren

1. Öffne im Windows-Explorer die Freigabe `\\docker.local\docker\Speisekarte`. Die Unterordner `html` und `config` entstehen beim Bereitstellen des Stacks.
2. Kopiere [index.php](html/index.php) und [style.css](html/style.css) in `html`. Kopiere [datenbank.php](config/datenbank.php) in `config`.
3. Öffne die [Speisekarte](http://docker.local:8090/) in einem weiteren Browser-Tab. Beim ersten Aufruf legt PHP die Tabellen an. Aktualisiere in phpMyAdmin die Tabellenliste für `datenbank_demo`.

## Ein Gericht anlegen

Öffne die [Speisekarte](http://docker.local:8090/) und scrolle zu **Karte pflegen**. Lege **Vorspeisen** an, falls die Kategorie noch fehlt. Speichere darin ein neues Gericht **Kräuterpita** für **6,90 €**. Merke dir die Nummer, die neben dem neu angelegten Gericht steht.

## SQL in phpMyAdmin öffnen

1. Wechsle zum [phpMyAdmin-Tab für die Speisekarte](http://docker.local:8091/). Melde dich bei Bedarf als `demo_app` an.
2. Wähle links `datenbank_demo` und oben **SQL**.
3. Tippe die Befehle eines Codeblocks in das Eingabefeld und klicke am Ende des Blocks einmal auf **OK**. Kehre für den nächsten Block zum SQL-Tab zurück.

Führe bei Transaktionen alle Anweisungen von `START TRANSACTION` bis `COMMIT` oder `ROLLBACK` zusammen aus. Auch die zugehörigen `SET`-Anweisungen gehören in denselben Block. So bleiben alle Befehle in derselben Verbindung. Jeder Klick auf **OK** sendet einen eigenen Auftrag an phpMyAdmin. Falls das Kontrollkästchen zur automatischen Rücknahme am Ende sichtbar ist, lass es frei. Die SQL-Befehle im Block steuern die Transaktion.

## Das Gericht in MariaDB finden

```sql
SELECT DATABASE(), @@autocommit;
```

Die erste Spalte zeigt `datenbank_demo`. Bei `@@autocommit = 1` bestätigt MariaDB eine einzelne erfolgreiche Änderung unmittelbar, wenn wir vorher keine Transaktion eröffnet haben.

```sql
SELECT id, kategorie_id, name, preis FROM speisekarte_gericht
WHERE name = 'Kräuterpita'
ORDER BY id DESC;
```

**Kontrolle.** Vergleiche die ID mit der Nummer auf der Webseite. Die Kategorie und das Gericht haben jeweils eine eigene ID. `kategorie_id` ist der Fremdschlüssel zur Kategorie. Der Preis ist als `DECIMAL(7,2)` mit zwei festen Nachkommastellen gespeichert. In SQL schreiben wir `6.90`.

In den folgenden Blöcken ist die `1` eine Beispielnummer. Ersetze sie beim Tippen jeweils durch **deine Gerichtsnummer**. `SET` merkt sie sich für die Dauer des Blocks.

## Kategorien und Gerichte verbinden

Lege im Browser eine Kategorie **Tag 04 Reserve** an und lass sie leer. Falls sie bereits existiert und leer ist, verwende sie für die Abfrage.

MariaDB speichert den Namen der Kategorie einmal. Alle Gerichte in dieser Kategorie verweisen auf dieselbe Kategorie-ID. `ON` legt fest, welche IDs beim `JOIN` zusammengehören.

```sql
SET @gericht_id = 1;
SELECT k.name AS kategorie, g.name AS gericht, g.preis
FROM speisekarte_kategorie AS k
INNER JOIN speisekarte_gericht AS g ON g.kategorie_id = k.id
WHERE g.id = @gericht_id OR k.name = 'Tag 04 Reserve';
```

Tippe den Block erneut ein und ersetze `INNER JOIN` durch `LEFT JOIN`. Du siehst zusätzlich die leere Reserve-Kategorie. Gericht und Preis stehen dort auf `NULL`. Die Webseite verwendet ebenfalls einen `LEFT JOIN` und kann deshalb leere Kategorien anzeigen.

## Ein Testgericht einfügen und wieder löschen

`INSERT ... SELECT` liest die Kategorie-ID deiner Kräuterpita und nutzt sie für eine neue Zeile. `LAST_INSERT_ID()` liefert die gerade vergebene Nummer.

```sql
SET @gericht_id = 1;
INSERT INTO speisekarte_gericht (kategorie_id, name, preis)
SELECT kategorie_id, 'Tag 04 Testgericht', 4.50
FROM speisekarte_gericht WHERE id = @gericht_id;
SELECT id, name, preis FROM speisekarte_gericht
WHERE id = LAST_INSERT_ID();
```

Lade die Karte neu und suche das Testgericht. Merke dir seine Nummer. Ersetze im folgenden Block die Beispielnummer `2` durch **die Nummer des Testgerichts**. Die zusätzliche Bedingung begrenzt die Löschung auf die so benannte Testzeile.

```sql
DELETE FROM speisekarte_gericht
WHERE id = 2 AND name = 'Tag 04 Testgericht';
```

**Kontrolle.** Lade die Karte neu. Die Kräuterpita ist weiterhin sichtbar. Das Testgericht ist weg.

## Den Preis ausprobieren und zurücknehmen

Wir testen, wie **7,40 €** aussehen würden. Der Block merkt sich den Preis vor der Änderung und während des Tests. `SELECT ... INTO` speichert einen Wert in einer Variablen, damit wir am Ende alle drei Werte nebeneinander sehen.

Tippe den **ganzen Block** in den SQL-Tab, ersetze die Beispielnummer und klicke einmal auf **OK**.

```sql
SET @gericht_id = 1;
START TRANSACTION;
SELECT preis INTO @vorher FROM speisekarte_gericht
WHERE id = @gericht_id;
UPDATE speisekarte_gericht SET preis = 7.40 WHERE id = @gericht_id;
SELECT preis INTO @im_test FROM speisekarte_gericht
WHERE id = @gericht_id;
ROLLBACK;
SELECT @vorher AS vorher, @im_test AS im_test, preis AS danach
FROM speisekarte_gericht WHERE id = @gericht_id;
```

**Kontrolle.** Die drei Spalten zeigen **6,90 → 7,40 → 6,90**. Lade die Karte neu. Sie zeigt den ursprünglichen Preis.

## Preis und Protokoll gemeinsam speichern

Lege eine Protokolltabelle an. Sie speichert die Gerichts-ID, den alten und den neuen Preis. `CHECK` verlangt zwei unterschiedliche Preise. Führe die Tabellendefinition als eigenen Block vor der Transaktion aus.

```sql
CREATE TABLE IF NOT EXISTS tag04_preisprotokoll (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    gericht_id INT UNSIGNED NOT NULL,
    alter_preis DECIMAL(7,2) NOT NULL,
    neuer_preis DECIMAL(7,2) NOT NULL,
    CONSTRAINT fk_tag04_gericht
        FOREIGN KEY (gericht_id) REFERENCES speisekarte_gericht (id),
    CONSTRAINT chk_tag04_preis_geaendert
        CHECK (alter_preis <> neuer_preis)
) ENGINE=InnoDB;
```

Der nächste Block führt die Preisänderung aus und schreibt das Protokoll. `FOR UPDATE` hält die ausgewählte Zeile für diesen Vorgang fest. Die Bedingungen stellen sicher, dass Preis und Protokoll nur für den vorgesehenen Wechsel von **6,90 €** auf **7,40 €** geschrieben werden.

```sql
SET @gericht_id = 1;
SET @alter_preis = NULL;
START TRANSACTION;
SELECT preis INTO @alter_preis FROM speisekarte_gericht
WHERE id = @gericht_id LIMIT 1 FOR UPDATE;
UPDATE speisekarte_gericht SET preis = 7.40
WHERE id = @gericht_id AND @alter_preis = 6.90;
INSERT INTO tag04_preisprotokoll (gericht_id, alter_preis, neuer_preis)
SELECT id, @alter_preis, preis FROM speisekarte_gericht
WHERE id = @gericht_id AND @alter_preis = 6.90 AND preis = 7.40;
COMMIT;
SELECT id, name, preis FROM speisekarte_gericht WHERE id = @gericht_id;
```

**Kontrolle.** Lade die Karte neu. Das Gericht kostet **7,40 €**. Sieh danach die Protokollzeile im SQL-Tab an.

```sql
SELECT gericht_id, alter_preis, neuer_preis
FROM tag04_preisprotokoll
WHERE gericht_id = 1;
```

## Einen Fehler gezielt beobachten

Verwende wieder deine Gerichtsnummer. Der folgende einzelne Befehl versucht, zweimal denselben Preis einzutragen. MariaDB lehnt den Eintrag wegen `chk_tag04_preis_geaendert` ab. Lies die Fehlermeldung und finde den Namen der Regel.

```sql
INSERT INTO tag04_preisprotokoll (gericht_id, alter_preis, neuer_preis)
SELECT id, preis, preis FROM speisekarte_gericht WHERE id = 1;
```

**Was bedeutet das für eine Transaktion?** Preisänderung und Protokoll gehören fachlich zusammen. Scheitert einer der beiden Schritte, soll der Preis aus derselben Transaktion ebenfalls zurückgenommen werden. Im SQL-Tab üben wir die Rücknahme mit dem vollständigen `ROLLBACK`-Block oben. phpMyAdmin kann die Ausführung eines Blocks bei einem Fehler abbrechen.

## Jetzt selbst

1. Lege ein weiteres Gericht an und notiere seine Nummer.
2. Übertrage den Block mit `ROLLBACK` auf dieses Gericht. Wähle einen eigenen Testpreis und sage vorher voraus, was die drei Spalten zeigen.
3. Prüfe den Preis nach dem Neuladen der Karte.

## Optionale Vertiefung

### Einen Zwischenschritt mit SAVEPOINT sichern

Teste zwei Preisänderungen und kehre nach der zweiten zum Sicherungspunkt zurück. Das abschließende `ROLLBACK` nimmt auch die erste Änderung zurück.

```sql
SET @gericht_id = 1;
START TRANSACTION;
UPDATE speisekarte_gericht SET preis = 7.90 WHERE id = @gericht_id;
SAVEPOINT erster_preis;
UPDATE speisekarte_gericht SET preis = 8.90 WHERE id = @gericht_id;
ROLLBACK TO SAVEPOINT erster_preis;
SELECT preis INTO @am_sicherungspunkt FROM speisekarte_gericht
WHERE id = @gericht_id;
ROLLBACK;
SELECT @am_sicherungspunkt AS sicherungspunkt, preis AS danach
FROM speisekarte_gericht WHERE id = @gericht_id;
```

Die beiden Spalten zeigen **7,90** und **7,40**, wenn du mit der zuvor bestätigten Kräuterpita arbeitest.

### Einen Index mit EXPLAIN untersuchen

Führe diese Abfrage einmal vor und einmal nach dem Anlegen des Index aus.

```sql
EXPLAIN SELECT name FROM speisekarte_gericht WHERE preis = 7.40;
```

```sql
CREATE INDEX IF NOT EXISTS idx_speisekarte_preis
ON speisekarte_gericht (preis);
```

`possible_keys` nennt mögliche Indizes. `key` zeigt den gewählten Index. `ALL` unter `type` beschreibt einen vollständigen Tabellenscan. Bei wenigen Gerichten kann der sinnvoll sein. Ein vollständiger Scan wächst näherungsweise mit `O(n)`. Die Suche nach einer passenden Position in einem balancierten Baumindex liegt näherungsweise bei `O(log n)`. Das Lesen der Treffer kommt hinzu.

## Quellen und Hilfsmittel

- [Speisekarte mit PHP und MariaDB](README.md)
- [MariaDB-Dokumentation zur Transaktionssteuerung](https://mariadb.com/docs/server/reference/sql-statements/transactions/start-transaction)
- [phpMyAdmin-Dokumentation zur Ausführung mehrerer Anweisungen](https://docs.phpmyadmin.net/en/latest/config.html#cfg_IgnoreMultiSubmitErrors)
- KI-Unterstützung bei der didaktischen Aufbereitung, den Erklärungen und dem SQL-Übungsbeispiel.
