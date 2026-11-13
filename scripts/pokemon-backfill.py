#!/usr/bin/env python3
"""Historique de prix TCGplayer (USD) via l'archive quotidienne de TCGCSV.

Telecharge prices-AAAA-MM-JJ.ppmd.7z pour chaque jour de la periode, garde les
cartes Pokemon (categorie 3) dont le prix marche etait >= --min-market USD le
dernier jour, et les range dans une base SQLite :

  prices(date, product_id, sub_type, market, low)
  products(product_id, name, group_id, set_name, number, rarity, image)

Relancer le script reprend la ou il s'est arrete (les jours deja presents sont ignores).

Usage : pokemon-backfill.py [--days 730] [--min-market 25] [--db FICHIER]
"""
import argparse
import datetime as dt
import json
import os
import shutil
import sqlite3
import subprocess
import sys
import tempfile
import time
import urllib.error
import urllib.request

BASE = "https://tcgcsv.com"
UA = {"User-Agent": "pokemon-tracker/0.1 (personal project)"}


MISSING = object()  # 404 : l'archive n'existe vraiment pas
FAILED = object()   # erreur reseau ou serveur apres tous les essais : a relancer plus tard


def fetch(url, dest=None, retries=6):
    for attempt in range(retries):
        try:
            req = urllib.request.Request(url, headers=UA)
            with urllib.request.urlopen(req, timeout=120) as r:
                data = r.read()
            if dest:
                with open(dest, "wb") as f:
                    f.write(data)
                return True
            return data
        except urllib.error.HTTPError as e:
            if e.code == 404:
                return MISSING
            print(f"  HTTP {e.code} sur {url.rsplit('/', 1)[-1]} (essai {attempt + 1}/{retries})", flush=True)
            time.sleep(5 * (attempt + 1))
        except Exception as e:
            print(f"  {type(e).__name__} sur {url.rsplit('/', 1)[-1]} (essai {attempt + 1}/{retries})", flush=True)
            time.sleep(5 * (attempt + 1))
    return FAILED


def read_day(archive, date, workdir):
    """Extrait seulement la categorie 3 et renvoie {group_id: [lignes de prix]}."""
    out = os.path.join(workdir, date)
    shutil.rmtree(out, ignore_errors=True)
    subprocess.run(["7z", "x", "-y", "-bso0", "-bsp0", "-o" + workdir, archive, date + "/3/*"],
                   check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    groups = {}
    base = os.path.join(out, "3")
    if not os.path.isdir(base):
        return groups
    for g in os.listdir(base):
        p = os.path.join(base, g, "prices")
        try:
            with open(p) as f:
                groups[int(g)] = json.load(f).get("results", [])
        except Exception:
            continue
    shutil.rmtree(out, ignore_errors=True)
    return groups


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--days", type=int, default=730)
    ap.add_argument("--min-market", type=float, default=25.0)
    ap.add_argument("--all", action="store_true",
                    help="garde toute ligne >= --min-market chaque jour (sans biais de survie), sans table products")
    ap.add_argument("--db", default=os.path.join(
        os.environ.get("XDG_DATA_HOME", os.path.expanduser("~/.local/share")),
        "pokemon-tracker", "tcgplayer-history.sqlite"))
    args = ap.parse_args()

    os.makedirs(os.path.dirname(args.db), exist_ok=True)
    db = sqlite3.connect(args.db)
    db.executescript("""
      CREATE TABLE IF NOT EXISTS prices(date TEXT, product_id INTEGER, sub_type TEXT, market REAL, low REAL,
        PRIMARY KEY(date, product_id, sub_type)) WITHOUT ROWID;
      CREATE TABLE IF NOT EXISTS products(product_id INTEGER PRIMARY KEY, name TEXT, group_id INTEGER,
        set_name TEXT, number TEXT, rarity TEXT, image TEXT);
      CREATE TABLE IF NOT EXISTS days(date TEXT PRIMARY KEY, rows INTEGER);
    """)
    done = {r[0] for r in db.execute("SELECT date FROM days")}
    work = tempfile.mkdtemp(prefix="tcgcsv-")

    # Dernier jour disponible : sert a choisir les produits a garder.
    today = dt.date.today()
    latest = None
    for back in range(1, 6):
        d = (today - dt.timedelta(days=back)).isoformat()
        arc = os.path.join(work, "latest.7z")
        if fetch(f"{BASE}/archive/tcgplayer/prices-{d}.ppmd.7z", arc) is True:
            latest = d
            break
    if not latest:
        sys.exit("aucune archive recente trouvee")
    keep = set()
    groups = read_day(arc, latest, work)
    for rows in groups.values():
        for r in rows:
            if (r.get("marketPrice") or 0) >= args.min_market:
                keep.add(r["productId"])
    print(f"dernier jour {latest} : {len(keep)} produits >= {args.min_market} USD", flush=True)

    # Noms, numeros, raretes, images (une requete par set).
    have = {r[0] for r in db.execute("SELECT product_id FROM products")}
    if not args.all and not keep <= have:
        gl = json.loads(fetch(f"{BASE}/tcgplayer/3/groups"))["results"]
        for g in gl:
            data = fetch(f"{BASE}/tcgplayer/3/{g['groupId']}/products")
            if not isinstance(data, bytes):
                continue
            for p in json.loads(data).get("results", []):
                if p["productId"] not in keep:
                    continue
                ext = {e["name"]: e["value"] for e in p.get("extendedData", [])}
                db.execute("INSERT OR REPLACE INTO products VALUES(?,?,?,?,?,?,?)",
                           (p["productId"], p["name"], g["groupId"], g["name"],
                            ext.get("Number"), ext.get("Rarity"), p.get("imageUrl")))
            time.sleep(0.2)
        db.commit()
        print("produits enregistres :", db.execute("SELECT COUNT(*) FROM products").fetchone()[0], flush=True)

    end = dt.date.fromisoformat(latest)
    days = [(end - dt.timedelta(days=i)).isoformat() for i in range(args.days)][::-1]
    t0, got = time.time(), 0
    for i, d in enumerate(days, 1):
        if d in done:
            continue
        arc = os.path.join(work, "day.7z")
        res = fetch(f"{BASE}/archive/tcgplayer/prices-{d}.ppmd.7z", arc)
        if res is MISSING:
            db.execute("INSERT OR REPLACE INTO days VALUES(?,?)", (d, 0))
            db.commit()
            print(f"{d} : archive inexistante (404)", flush=True)
            continue
        if res is FAILED:
            print(f"{d} : ECHEC, a relancer", flush=True)
            continue
        n = 0
        for rows in read_day(arc, d, work).values():
            for r in rows:
                mp = r.get("marketPrice")
                if mp is not None and ((mp >= args.min_market) if args.all else r["productId"] in keep):
                    db.execute("INSERT OR REPLACE INTO prices VALUES(?,?,?,?,?)",
                               (d, r["productId"], r.get("subTypeName") or "", r["marketPrice"], r.get("lowPrice")))
                    n += 1
        db.execute("INSERT OR REPLACE INTO days VALUES(?,?)", (d, n))
        db.commit()
        os.remove(arc)
        got += 1
        if got % 20 == 0:
            print(f"{d} ({i}/{len(days)}) {n} lignes, {time.time() - t0:.0f}s", flush=True)
        time.sleep(0.3)
    shutil.rmtree(work, ignore_errors=True)
    nd, nr = db.execute("SELECT COUNT(*), SUM(rows) FROM days").fetchone()
    print(f"termine : {nd} jours, {nr} lignes -> {args.db}", flush=True)


if __name__ == "__main__":
    main()
