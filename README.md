# Speisekarte mit PHP und MariaDB

Lege im Browser eine Kategorie und ein Gericht an. PHP speichert beides in MariaDB. Die Webseite gruppiert die Gerichte nach Kategorie und zeigt neben jedem Namen den Preis und die Tabellen-ID.

**Voraussetzung.** Die Debian-Docker-VM mit Portainer und der SMB-Freigabe `docker` ist eingerichtet. Die Freigabe zeigt auf `/srv/docker` und dein SMB-Konto darf dort schreiben.

## Handout zum Nachlesen

- Speisekarten-Handout als [Markdown](02-handout-speisekarte.md), [PDF](02-handout-speisekarte.pdf) oder [Word-Datei](02-handout-speisekarte.docx)

Ersetze `docker.local` in den Adressen durch den Hostnamen oder die IP deiner VM, falls du einen anderen Namen verwendest.

## Den Stack in Portainer starten

1. Öffne [Portainer](https://docker.local:9443/) im Browser und wähle **Stacks → Add stack → Web editor**.
2. Gib dem Stack den Namen `datenbank-demo` und füge den Inhalt von [stack.yaml](stack.yaml) ein.
3. Klicke unter **Environment variables** auf **Add environment variable**. Gib als **Name** `DEMO_DB_PASSWORT` ein. Unter **Value** trägst du dein Datenbankpasswort ein. Klicke auf **Deploy the stack**. [Portainer-Dokumentation](https://docs.portainer.io/user/docker/stacks/add)
4. Öffne [phpMyAdmin für die Speisekarte](http://docker.local:8091/) in einem eigenen Browser-Tab. Melde dich als `demo_app` mit dem eben gesetzten Passwort an und wähle links `datenbank_demo`. Bei einem frischen Stack erscheint die Datenbank zunächst ohne Tabellen.

MariaDB läuft als Dienst `db`. phpMyAdmin und der PHP-Container erreichen sie über diesen Namen im Stack-Netz. Port `8080` gehört zu phpMyAdmin aus Tag 02. Für die Speisekarte verwenden wir Port `8090` und für ihr phpMyAdmin Port `8091`.

Falls `datenbank-demo` bereits existiert, füge den aktuellen YAML-Inhalt in seinen **Editor** ein und klicke auf **Update the stack**. Beim bestehenden Datenvolume verwendest du das bisherige Datenbankpasswort.

## Die Webdateien über SMB kopieren

1. Öffne im Windows-Explorer `\\docker.local\docker\Speisekarte`. Docker legt beim Bereitstellen des Stacks die Unterordner `html` und `config` bei Bedarf an. [Compose-Spezifikation zu eingebundenen Ordnern](https://github.com/compose-spec/compose-spec/blob/main/spec.md#volumes)
2. Kopiere [index.php](html/index.php) und [style.css](html/style.css) in den vorhandenen Ordner `html`. Kopiere [datenbank.php](config/datenbank.php) in `config`.
3. Öffne die [Speisekarte](http://docker.local:8090/) in einem zweiten Tab. Beim ersten Aufruf legt PHP die beiden Tabellen an. Aktualisiere anschließend die Tabellenliste für `datenbank_demo` in phpMyAdmin.

Wenn du später einen Text, das Layout oder den PHP-Code änderst, bearbeitest du die betreffende Datei im Projektordner auf der SMB-Freigabe. Speichere sie und lade die Seite im Browser neu.

## Vom Formular zur SQL-Tabelle

1. **Datenweg zeigen.** In `8090:80` ist `8090` der Port der VM und `80` der Port im Webcontainer. PHP erreicht MariaDB im Stack über den Dienstnamen `db`.
2. **Eine Kategorie und ein Gericht anlegen.** Scrolle zu **Karte pflegen**. Lege **Vorspeisen** an. Wähle danach diese Kategorie und speichere **Kräuterpita** mit dem Preis **6,90**. Die Seite zeigt die neue Zeile und ihre automatisch vergebene Nummer.
3. **Dieselbe Zeile abfragen.** Wechsle zum offenen phpMyAdmin-Tab. Wähle links `datenbank_demo` und öffne oben **SQL**.

   ```sql
   SELECT id, kategorie_id, name, preis
   FROM speisekarte_gericht
   ORDER BY id;
   ```

   Die [kommentierte SQL-Datei](sql/01-speisekarte-verstehen.sql) verbindet beide Tabellen per `JOIN` und fügt optional ein Gericht direkt über SQL hinzu. Lade dann die Webseite neu.

4. **Den Code zeigen.** [datenbank.php](config/datenbank.php) verbindet PHP mit MariaDB und legt beide Tabellen an. [index.php](html/index.php) speichert Formulareingaben mit `INSERT` und liest die Karte per `LEFT JOIN`. Eine Kategorie kann mehrere Gerichte enthalten. Jedes Gericht gehört zu einer Kategorie.
5. **Im Browser weiterarbeiten.** Das [Speisekarten-Handout](02-handout-speisekarte.md) führt Schritt für Schritt durch die Preisänderung im SQL-Tab. Auf der Karte vergleichst du das Ergebnis nach dem Neuladen.
6. **Mit mehr Daten üben.** Das [Übungs-Handout](03-handout-uebungen.md) verlinkt den [SQL-Import der Rhodos-Speisekarte](sql/02-rhodos-speisekarte-import.sql). Er ergänzt fehlende Gerichte und Kategorien. Danach kannst du filtern, verknüpfen, zählen und Preise in Transaktionen bearbeiten.

## Tabellen im Überblick

| Tabelle | Spalten |
|---|---|
| `speisekarte_kategorie` | `id`, `name` |
| `speisekarte_gericht` | `id`, `kategorie_id`, `name`, `beschreibung`, `preis` |

Die ID eines Gerichts entspricht seiner Nummer auf der Webseite. Der Preis ist ein Dezimalwert mit zwei Nachkommastellen. In SQL schreibst du beispielsweise `6.90`. Das Formular akzeptiert auch `6,90`.

## Quellen und Hilfsmittel

- [Portainer-Dokumentation zum Webeditor](https://docs.portainer.io/user/docker/stacks/add)
- [Docker-Dokumentation zu Variablen in Compose](https://docs.docker.com/reference/compose-file/interpolation/)
- [phpMyAdmin-Dokumentation zur Docker-Konfiguration](https://docs.phpmyadmin.net/en/release_5_2_0/setup.html#installing-using-docker)
- Kräuterpita und weitere manuell angelegte Beispiele sind fiktive Übungsdaten. Der optionale SQL-Import enthält die Rhodos-Speisekarte mit Stand vom 04.10.2026. Die Preise geben diesen Datenstand wieder.
- KI-Unterstützung bei der Erstellung und Prüfung dieses Laborbeispiels.
