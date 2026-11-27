<?php
declare(strict_types=1);

header('Content-Type: text/html; charset=UTF-8');

function html(string $wert): string
{
    return htmlspecialchars($wert, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

function eingabe(string $feld): string
{
    $wert = $_POST[$feld] ?? '';
    return is_string($wert) ? trim($wert) : '';
}

$kategorien = [];
$meldung = '';
$bereit = false;
$name = '';
$beschreibung = '';
$preisEingabe = '';
$kategorieName = '';
$kategorieId = 0;

try {
    $db = require __DIR__ . '/../config/datenbank.php';

    // Per POST werden Daten geschrieben. Eine normale Seitenabfrage liest nur.
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $aktion = eingabe('aktion');
        if ($aktion === 'kategorie') {
            $kategorieName = eingabe('kategorie_name');

            if (preg_match('/\A[^\p{C}]{1,50}\z/u', $kategorieName) !== 1) {
                $meldung = 'Gib einen Kategorienamen mit höchstens 50 Zeichen ein.';
            } else {
                try {
                    $speichern = $db->prepare(
                        'INSERT INTO speisekarte_kategorie (name) VALUES (?)'
                    );
                    $speichern->execute([$kategorieName]);
                } catch (PDOException $fehler) {
                    if (($fehler->errorInfo[1] ?? null) !== 1062) {
                        throw $fehler;
                    }
                    $meldung = 'Diese Kategorie gibt es schon.';
                }
            }
        } elseif ($aktion === 'gericht') {
            $name = eingabe('name');
            $beschreibung = eingabe('beschreibung');
            $preisEingabe = eingabe('preis');
            $preis = str_replace(',', '.', $preisEingabe);
            $kategorieId = filter_var(eingabe('kategorie_id'), FILTER_VALIDATE_INT, [
                'options' => ['min_range' => 1],
            ]) ?: 0;

            // HTML hilft bei der Eingabe. PHP prüft die Werte vor dem Schreiben.
            if (preg_match('/\A[^\p{C}]{1,80}\z/u', $name) !== 1
                || preg_match('/\A[^\p{C}]{0,160}\z/u', $beschreibung) !== 1) {
                $meldung = 'Prüfe Name und Beschreibung. Sie haben höchstens 80 bzw. 160 Zeichen.';
            } elseif (preg_match('/\A[0-9]{1,5}(?:\.[0-9]{1,2})?\z/', $preis) !== 1
                || (float) $preis <= 0) {
                $meldung = 'Gib einen Preis größer als null ein, zum Beispiel 6,90.';
            } elseif (!$kategorieId) {
                $meldung = 'Wähle eine Kategorie aus.';
            } else {
                // Das Fragezeichen ist ein Platzhalter. Der FK prüft die gewählte Kategorie.
                $speichern = $db->prepare(<<<'SQL'
                    INSERT INTO speisekarte_gericht
                        (kategorie_id, name, beschreibung, preis)
                    VALUES (?, ?, ?, ?)
                    SQL
                );
                try {
                    $speichern->execute([$kategorieId, $name, $beschreibung, $preis]);
                } catch (PDOException $fehler) {
                    if (($fehler->errorInfo[1] ?? null) !== 1452) {
                        throw $fehler;
                    }
                    $meldung = 'Wähle eine vorhandene Kategorie aus.';
                }
            }
        } else {
            $meldung = 'Wähle ein Formular und versuche es erneut.';
        }

        if ($meldung === '') {
            // Nach dem Speichern lädt der Browser die Karte per GET.
            header('Location: /#karte', true, 303);
            exit;
        }
        http_response_code(400);
    }

    // LEFT JOIN liefert auch Kategorien, zu denen es noch keine Gerichte gibt.
    $zeilen = $db->query(<<<'SQL'
        SELECT k.id AS kategorie_id, k.name AS kategorie,
               g.id AS gericht_id, g.name, g.beschreibung, g.preis
        FROM speisekarte_kategorie AS k
        LEFT JOIN speisekarte_gericht AS g ON g.kategorie_id = k.id
        ORDER BY k.id, g.id
        SQL
    )->fetchAll(PDO::FETCH_ASSOC);

    // Die SQL-Zeilen nach Kategorie gruppieren, damit jede Überschrift einmal erscheint.
    foreach ($zeilen as $zeile) {
        $id = (int) $zeile['kategorie_id'];
        $kategorien[$id] ??= ['name' => $zeile['kategorie'], 'gerichte' => []];
        if ($zeile['gericht_id'] !== null) {
            $kategorien[$id]['gerichte'][] = $zeile;
        }
    }
    $bereit = true;
} catch (PDOException $fehler) {
    http_response_code(503);
    error_log('Speisekarte: Datenbankfehler ' . $fehler->getCode());
    $meldung = 'Die Speisekarte ist gerade nicht erreichbar. Prüfe den Dienst db in Portainer.';
}
?>
<!doctype html>
<html lang="de">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Speisekarte | DB2-Labor</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
<header class="kopf">
    <div class="rahmen kopf-inhalt">
        <div>
            <p class="kurs">DB2-Labor</p>
            <h1>Speisekarte</h1>
        </div>
        <?php if ($bereit): ?>
            <a class="sprung" href="#pflege">Karte pflegen</a>
        <?php endif; ?>
    </div>
</header>
<main class="rahmen aufteilung">
    <section id="karte" class="karte" aria-label="Gerichte nach Kategorie">
        <?php if (!$bereit): ?>
            <p class="meldung" role="alert"><?= html($meldung) ?></p>
        <?php elseif ($kategorien === []): ?>
            <p class="leer">Lege eine Kategorie an, um das erste Gericht einzutragen.</p>
        <?php endif; ?>

        <?php foreach ($kategorien as $kategorie): ?>
            <section class="kategorie">
                <h2><?= html($kategorie['name']) ?></h2>
                <?php if ($kategorie['gerichte'] === []): ?>
                    <p class="leer">Für diese Kategorie sind noch keine Gerichte eingetragen.</p>
                <?php else: ?>
                    <ul class="gerichte">
                        <?php foreach ($kategorie['gerichte'] as $gericht): ?>
                            <li class="gericht">
                                <div>
                                    <span class="nummer">Nr. <?= (int) $gericht['gericht_id'] ?></span>
                                    <h3><?= html($gericht['name']) ?></h3>
                                    <?php if ($gericht['beschreibung'] !== ''): ?>
                                        <p><?= html($gericht['beschreibung']) ?></p>
                                    <?php endif; ?>
                                </div>
                                <span class="preis"><?= number_format((float) $gericht['preis'], 2, ',', '.') ?> €</span>
                            </li>
                        <?php endforeach; ?>
                    </ul>
                <?php endif; ?>
            </section>
        <?php endforeach; ?>
    </section>

    <?php if ($bereit): ?>
        <section id="pflege" class="pflege">
            <h2>Karte pflegen</h2>
            <?php if ($meldung !== ''): ?>
                <p class="meldung" role="alert"><?= html($meldung) ?></p>
            <?php endif; ?>

            <?php /* Zwei Formulare schreiben in zwei getrennte SQL-Tabellen. */ ?>
            <form method="post" action="/#pflege">
                <label for="kategorie-name">Neue Kategorie</label>
                <div class="eingabe">
                    <input id="kategorie-name" name="kategorie_name" maxlength="50" required
                           value="<?= html($kategorieName) ?>">
                    <button name="aktion" value="kategorie">Anlegen</button>
                </div>
            </form>

            <?php if ($kategorien !== []): ?>
                <form method="post" action="/#pflege">
                    <h3>Neues Gericht</h3>
                    <label for="kategorie-id">Kategorie</label>
                    <select id="kategorie-id" name="kategorie_id" required>
                        <?php foreach ($kategorien as $id => $kategorie): ?>
                            <option value="<?= $id ?>"<?= $id === $kategorieId ? ' selected' : '' ?>>
                                <?= html($kategorie['name']) ?>
                            </option>
                        <?php endforeach; ?>
                    </select>
                    <label for="gericht-name">Name</label>
                    <input id="gericht-name" name="name" maxlength="80" required value="<?= html($name) ?>">
                    <label for="beschreibung">Beschreibung (optional)</label>
                    <input id="beschreibung" name="beschreibung" maxlength="160" value="<?= html($beschreibung) ?>">
                    <label for="preis">Preis in Euro</label>
                    <input id="preis" name="preis" inputmode="decimal" maxlength="8" required
                           placeholder="6,90" value="<?= html($preisEingabe) ?>">
                    <button name="aktion" value="gericht">Speichern</button>
                </form>
            <?php endif; ?>
        </section>
    <?php endif; ?>
</main>
</body>
</html>
