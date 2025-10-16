# combine_csvs.py
from pathlib import Path
import pandas as pd

# ---- CONFIG ----
INPUT_DIR = Path(r"C:\Users\mateu\Arquivos de Programas Faculdade\Repositorios\Analise-SCZ\Data\processed")
OUTPUT_DIR = INPUT_DIR
OUTPUT_CSV = OUTPUT_DIR / "dados_unificados.csv"
OUTPUT_PARQUET = OUTPUT_DIR / "dados_unificados.parquet"
# ----------------

def encontrar_csvs(input_dir: Path):
    # procura recursivamente (vai pegar processed\parquet\*.csv também)
    return sorted(p for p in input_dir.rglob("*.csv") if p.is_file())

def read_csv(path: Path) -> pd.DataFrame:
    try:
        df = pd.read_csv(path, dtype=str, encoding="utf-8", na_values=["", "NA", "NaN"], low_memory=False)
    except UnicodeDecodeError:
        df = pd.read_csv(path, dtype=str, encoding="latin1", na_values=["", "NA", "NaN"], low_memory=False)
    df.columns = [c.strip() for c in df.columns]
    df["__source_file"] = path.name
    return df

def pad_ibge(s: pd.Series) -> pd.Series:
    return s.astype("string").str.replace(r"\.0$", "", regex=True).str.zfill(6)

def parse_dates(df: pd.DataFrame) -> pd.DataFrame:
    date_cols = [c for c in df.columns if c.startswith("DT_")]
    for c in date_cols:
        df[c] = pd.to_datetime(df[c].astype("string").str.strip(), format="%d%m%Y", errors="coerce")
    return df

def unify_columns(dfs: list[pd.DataFrame]) -> list[pd.DataFrame]:
    all_cols = sorted(set().union(*(set(d.columns) for d in dfs)))
    return [d.reindex(columns=all_cols) for d in dfs]

def main():
    csvs = encontrar_csvs(INPUT_DIR)
    if not csvs:
        raise SystemExit(f"Nenhum CSV encontrado em: {INPUT_DIR}")

    print(f"→ {len(csvs)} arquivos encontrados. Ex.: {csvs[0]}")
    dfs = [read_csv(p) for p in csvs]

    # padronizações ANTES de unir (agora salvando de volta no array)
    for i, df in enumerate(dfs):
        for col in ("CODMUNRES", "CODMUNNOT"):
            if col in df.columns:
                df[col] = pad_ibge(df[col])
        dfs[i] = parse_dates(df)  # <-- grava de volta

    dfs = unify_columns(dfs)
    big = pd.concat(dfs, ignore_index=True)

    # numéricos úteis
    for col in ("PESO", "COMPRIMENT", "PERIMCEFAL", "DIAMCEFAL", "IDADEGES", "ANO_NOT", "ANO_NASC"):
        if col in big.columns:
            big[col] = pd.to_numeric(big[col], errors="coerce")

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    print(f"→ Salvando CSV: {OUTPUT_CSV}")
    big.to_csv(OUTPUT_CSV, index=False, encoding="utf-8")

    try:
        import pyarrow  # noqa
        print(f"→ Salvando Parquet: {OUTPUT_PARQUET}")
        big.to_parquet(OUTPUT_PARQUET, index=False)
    except Exception as e:
        print("! Parquet não salvo (instale pyarrow se quiser):", e)

    print("✔ Concluído. Linhas:", len(big), " | Colunas:", big.shape[1])

if __name__ == "__main__":
    main()
