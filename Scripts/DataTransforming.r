## CONVERSOR DBC -> CSV/Parquet

## CONFIGURE AQUI O CAMINHO DE ENTRADA (pasta que contém os .dbc)
INPUT_DIR  <- "C:/Users/mateu/Arquivos de Programas Faculdade/Repositorios/Analise-SCZ/Data/raw"

## ================================================================================

## Prepara repositório e biblioteca do usuário 
options(repos = c(CRAN = "https://cloud.r-project.org"),
        install.packages.check.source = "no")

ver_major <- R.version$major
ver_minor_main <- strsplit(R.version$minor, "\\.")[[1]][1]
userlib <- file.path(Sys.getenv("USERPROFILE"),
                     "AppData","Local","R","win-library",
                     paste0(ver_major,".",ver_minor_main))
dir.create(userlib, recursive = TRUE, showWarnings = FALSE)
.libPaths(c(userlib, .libPaths()))

## Garante pacotes necessários (read.dbc obrigatório; arrow opcional)
pkg_ok <- function(p) isTRUE(requireNamespace(p, quietly = TRUE))

if (!pkg_ok("read.dbc")) {
  message("Instalando 'read.dbc' (tentativa 1 - CRAN cloud)...")
  try(install.packages("read.dbc", lib = .libPaths()[1], type = "binary"), silent = TRUE)
}
if (!pkg_ok("read.dbc")) {
  message("Instalando 'read.dbc' (tentativa 2 - snapshot Posit com binários)...")
  orepo <- getOption("repos")
  options(repos = c(CRAN = "https://packagemanager.posit.co/cran/2024-07-05"))
  try(install.packages("read.dbc", lib = .libPaths()[1], type = "binary"), silent = TRUE)
  options(repos = orepo)  # volta pro CRAN padrão
}
if (!pkg_ok("read.dbc")) stop("Falha ao instalar/carregar 'read.dbc'. Avise-me com a mensagem acima.")

## arrow é opcional (para salvar .parquet). Se falhar, seguimos só com CSV.
if (!pkg_ok("arrow")) {
  message("Instalando 'arrow' (opcional)...")
  try(install.packages("arrow", lib = .libPaths()[1], type = "binary"), silent = TRUE)
}

suppressPackageStartupMessages({
  library(read.dbc)
  ok_arrow <- pkg_ok("arrow")
  if (ok_arrow) library(arrow)
})

## Definir pasta de saída (dentro de INPUT_DIR)
OUTPUT_DIR <- file.path(INPUT_DIR, "convertidos")
dir.create(OUTPUT_DIR, recursive = TRUE, showWarnings = FALSE)

## Lista todos os .dbc (inclui subpastas; ignora maiúsc./minúsc.)
dbc_files <- list.files(INPUT_DIR, pattern = "(?i)\\.dbc$", recursive = TRUE, full.names = TRUE)
cat("Arquivos .dbc encontrados:", length(dbc_files), "\n")
if (length(dbc_files) == 0) {
  cat("Verifique o caminho INPUT_DIR e se os arquivos possuem extensão .dbc/.DBC\n")
  cat("INPUT_DIR: ", normalizePath(INPUT_DIR, winslash = "/", mustWork = FALSE), "\n")
  cat("getwd():   ", normalizePath(getwd(), winslash = "/", mustWork = FALSE), "\n")
  stop("Nenhum .dbc encontrado.")
}

## Função para espelhar subpastas de INPUT_DIR em OUTPUT_DIR
to_out <- function(f, ext) {
  in_root <- normalizePath(INPUT_DIR, winslash = "/", mustWork = TRUE)
  f_norm  <- normalizePath(f, winslash = "/", mustWork = TRUE)
  rel <- sub(paste0("^", gsub("\\\\","\\\\\\\\", in_root), "/?"), "", f_norm)
  base <- sub("(?i)\\.dbc$", paste0(".", ext), rel, perl = TRUE)
  out_path <- file.path(OUTPUT_DIR, base)
  dir.create(dirname(out_path), recursive = TRUE, showWarnings = FALSE)
  out_path
}

## Converte todos (com logs e tryCatch)
n_ok <- 0; n_err <- 0
for (f in dbc_files) {
  cat("\n>> Lendo:", f, "\n")
  tryCatch({
    df <- read.dbc::read.dbc(f)   # lê DBC (descompacta DBF por baixo)
    ## converter datas DDMMAAAA -> Date:
    ## dn <- names(df)[grepl("^DT_", names(df))]
    ## for (nm in dn) df[[nm]] <- as.Date(df[[nm]], "%d%m%Y")

    # Salva CSV 
    csv_out <- to_out(f, "csv")
    utils::write.csv(df, csv_out, row.names = FALSE, fileEncoding = "UTF-8")
    cat("   CSV salvo em:", csv_out, "\n")

    # Salva em Parquet 
    if (ok_arrow) {
      pq_out <- to_out(f, "parquet")
      arrow::write_parquet(as.data.frame(df), pq_out)
      cat("   Parquet salvo em:", pq_out, "\n")
    }

    n_ok <- n_ok + 1
  }, error = function(e) {
    cat("   [ERRO] ", conditionMessage(e), "\n")
    n_err <<- n_err + 1
  })
}

cat("\n===== RESUMO =====\n",
    "Convertidos com sucesso:", n_ok, "\n",
    "Com erro:", n_err, "\n",
    "Saída:", normalizePath(OUTPUT_DIR, winslash = "/", mustWork = TRUE), "\n", sep = "")

