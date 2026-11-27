---
lang: de-DE
title: "SQL-Übungen mit der Speisekarte"
subtitle: "Praxis für Tag 04"
module: "Datenbanken und SQL 2"
toc: false
---

# Mit der Speisekarte in phpMyAdmin arbeiten

Du arbeitest mit der Speisekarte, die du bereits eingerichtet hast. Am Ende kannst du Gerichte filtern, Kategorien per `JOIN` zuordnen und eine Preisänderung ausprobieren. Die Webseite zeigt dir direkt, welcher Preis nach der Transaktion gespeichert ist.

## Speisekarte als Übungsdaten importieren

1. Öffne zuerst die [Speisekarte](http://docker.local:8090/) einmal im Browser. Dadurch legt PHP die Tabellen an, falls sie noch fehlen.
2. Öffne [phpMyAdmin](http://docker.local:8091/), melde dich als `demo_app` an und wähle links `datenbank_demo`. Öffne oben **SQL**.
3. Öffne die [SQL-Datei mit der Rhodos-Speisekarte](sql/02-rhodos-speisekarte-import.sql). Kopiere ihren gesamten Inhalt in das SQL-Feld. Klicke einmal auf **OK**. Der Import läuft in einer Verbindung.
4. Lies unten `neue_kategorien` und `neue_gerichte` ab. Lade die Speisekarte neu und suche die Kategorie **Salate**.

Der Datenstand enthält **16 Kategorien und 110 Gerichte**. Je nach Bestand kommen beim ersten Lauf weniger Einträge hinzu. Dein bisheriger Bestand bleibt erhalten. Zum Abgleich nutzt der Import Kategorie und Gerichtsname. Bei mehreren gleichnamigen Varianten in einer Kategorie prüft er zusätzlich die Beschreibung. So bleiben zum Beispiel der kleine und der große Bauernsalat getrennte Gerichte. Der Preis dient nur als Wert für neue Gerichte.

Führe den Import direkt danach ein zweites Mal aus. Beide Zahlen sollen dann **0** sein. Das zeigt dir, dass sich der Import wiederholen lässt.

## Übung 1 Angebote im passenden Preisbereich finden

Schreibe eine Abfrage für Gerichte von **8,00 bis 12,00 Euro**. Gib `id`, `name` und `preis` aus. Sortiere zunächst nach Preis aufsteigend und bei gleichem Preis nach Name.

**Tipp.** Nutze `WHERE preis BETWEEN … AND …` und schreibe die Preise in SQL mit einem Punkt.

**Kontrolle.** Beide Grenzen zählen mit. Die ID eines Treffers entspricht seiner Nummer auf der Webseite.

## Übung 2 Gerichte mit ihrem Kategorienamen anzeigen

Zeige nur Gerichte aus **Vorspeisen**. Die Ergebnisliste soll eine Spalte `kategorie` und daneben Gerichtsname und Preis enthalten.

**Tipp.** Verbinde `speisekarte_gericht.kategorie_id` mit `speisekarte_kategorie.id`. Filtere nach dem Namen der Kategorie.

**Kontrolle.** In der Spalte `kategorie` steht bei jeder Zeile **Vorspeisen**. Eigene Gerichte aus dieser Kategorie darfst du dort ebenfalls sehen.

## Übung 3 Gerichte je Kategorie zählen

Gib für jede Kategorie den Namen und die Anzahl der zugeordneten Gerichte aus. Lege bei Bedarf im Browser eine leere Kategorie **Tag 04 Reserve** an und nutze sie zur Kontrolle.

**Tipp.** Starte bei `speisekarte_kategorie`, nutze einen `LEFT JOIN` und gruppiere nach Kategorie-ID und -Name. Zähle mit `COUNT(g.id)` die Gerichte.

**Kontrolle.** Die leere Kategorie erscheint mit der Anzahl **0**. Ihre Zeile bleibt durch den `LEFT JOIN` im Ergebnis. Wenn du `COUNT(*)` verwendest, zählt MariaDB auch diese Ergebniszeile mit.

## Übung 4 Einen neuen Preis ausprobieren

Lege auf der Webseite unter **Vorspeisen** ein eigenes Testgericht **SQL-Übung Kräuterbrot** für **4,20 Euro** an. Merke dir seine Nummer. Suche das Gericht zunächst mit einer passenden `SELECT`-Abfrage in phpMyAdmin.

Tippe danach diesen Block in den SQL-Tab. Ersetze `1` durch die ID deines Testgerichts. Führe den gesamten Block mit einem Klick auf **OK** aus.

```sql
SET @uebung_id = 1;
START TRANSACTION;

UPDATE speisekarte_gericht SET preis = 4.80
WHERE id = @uebung_id AND name = 'SQL-Übung Kräuterbrot';

SELECT preis INTO @testpreis FROM speisekarte_gericht
WHERE id = @uebung_id AND name = 'SQL-Übung Kräuterbrot';

ROLLBACK;

SELECT name, @testpreis AS testpreis, preis AS gespeicherter_preis
FROM speisekarte_gericht
WHERE id = @uebung_id AND name = 'SQL-Übung Kräuterbrot';
```

**Kontrolle.** Die Abfrage zeigt **4,80** als Testpreis und **4,20** als gespeicherten Preis. Lade die Webseite neu und prüfe die **4,20 Euro**. `ROLLBACK` hat die Änderung an deinem Gericht zurückgenommen.

## Übung 5 Einen Preis bestätigen

Wiederhole Übung 4 mit demselben Testgericht. Wähle einen anderen Preis und ersetze diesmal `ROLLBACK` durch `COMMIT`. Sage vor dem Ausführen voraus, welche Zahlen die beiden Preisspalten zeigen. Lade die Webseite danach neu und vergleiche.

Wenn du fertig bist, lösche dein Testgericht über seine ID und seinen Namen. Prüfe vor dem `DELETE` dieselbe `WHERE`-Bedingung mit `SELECT`. Lade anschließend die Karte neu.

## Quellen und Hilfsmittel

- Übungsdaten aus `data/menu.json` der Rhodos-Webseite, Stand 04.10.2026. Der Import übernimmt die Kategorien, Gerichte, Beschreibungen und Preise für das DB2-Tabellenmodell.
- [Speisekarten-Handout zur Einführung](02-handout-speisekarte.md)
- KI-Unterstützung bei der Aufbereitung des Imports und der Ausarbeitung der Übungen.
