# 🧭 Análise Espacial e Temporal da Síndrome Congênita do Zika Vírus (SCZ) — Pernambuco (2015–2024)

## 📄 Descrição do Projeto
Este projeto realiza uma **análise exploratória, temporal e espacial** dos casos da **Síndrome Congênita associada ao Vírus Zika (SCZ)** notificados no estado de **Pernambuco, Brasil**, no período de **2015 a 2024**.

A partir de dados oficiais consolidados, o estudo busca compreender:
- A **evolução temporal** dos casos confirmados, descartados e óbitos;
- A **distribuição espacial** da SCZ entre os municípios pernambucanos;
- A **presença de padrões espaciais significativos** (clusters, difusão regional);
- E os **fatores associados** à variação territorial dos casos confirmados, por meio de **modelos de regressão espacial (SAR e SEM)**.

---

## 🎯 Objetivos
1. **Preparação e transformação dos dados** (limpeza, padronização e mapeamento de categorias).
2. **Análise exploratória** de variáveis clínicas e epidemiológicas.
3. **Análise temporal** da evolução da SCZ (casos, confirmações, óbitos e proporções).
4. **Mapeamento espacial** da distribuição de casos por município.
5. **Testes de autocorrelação espacial** (Moran’s I, LISA).
6. **Modelagem espacial** via Regressão Espacial (OLS, Spatial Lag, Spatial Error).
7. **Visualização interativa** dos resultados em mapas e gráficos dinâmicos.

---

## 🧰 Tecnologias Utilizadas
- **Python 3.12+**
- **Bibliotecas principais:**
  - `pandas`, `numpy` → manipulação e transformação de dados  
  - `matplotlib`, `plotly.express`, `seaborn` → visualização gráfica  
  - `geopandas`, `folium`, `branca` → geoprocessamento e mapas interativos  
  - `esda`, `libpysal`, `spreg` → estatística espacial e regressões espaciais  
  - `itables` → visualização tabular interativa no Jupyter  
  - `scipy`, `statsmodels` → análises estatísticas complementares  

---

## 🧮 Metodologia Analítica

### 🔹 1. Preparação de Dados
- Padronização e mapeamento de variáveis categóricas conforme o dicionário DIC_DADOS_RESP.pdf.  
- Correção de tipos, formatação de datas e códigos municipais (IBGE).  
- Integração dos shapefiles de municípios de Pernambuco (`PE_Municipios_2024.shp`).

### 🔹 2. Análise Exploratória
- Distribuições de sintomas, tipos de microcefalia e classificação final.
- Histogramas, scatterplots e boxplots para variáveis quantitativas (peso, perímetro cefálico etc.).
- Correlações entre variáveis clínicas e epidemiológicas.

### 🔹 3. Análise Temporal
- Evolução anual de notificações, confirmações e óbitos.
- Proporção de casos confirmados (%), taxa de óbitos (%) e variação por sexo/região.
- Séries temporais interativas com `plotly.express`.

### 🔹 4. Análise Espacial
- Junção (`merge`) entre dados epidemiológicos e shapefile municipal.
- Criação de mapas coropléticos e de bolhas (`geopandas`, `folium`, `plotly.mapbox`).
- Cálculo de indicadores:
  - Casos confirmados por município  
  - Proporção de confirmados (%)  
  - Taxa de óbitos (%)  
  - Densidade espacial de casos  

### 🔹 5. Modelagem Espacial
Três modelos foram testados:

| Modelo | Tipo | Interpretação |
|--------|------|---------------|
| **OLS** | Regressão Linear Tradicional | Explica fatores globais, mas ignora o espaço |
| **SAR (Spatial Lag)** | Inclui o efeito dos vizinhos (ρ) | Captura **difusão espacial direta** entre municípios |
| **SEM (Spatial Error)** | Considera dependência nos resíduos (λ) | Captura **fatores regionais ocultos** (ex: infraestrutura, clima) |

**Principais resultados:**
- O modelo **SAR apresentou melhor ajuste (R² = 0.95)**, indicando forte **efeito de vizinhança**.  
- O modelo **SEM também foi significativo**, mas com menor ganho, mostrando influência indireta.  
- Ambos confirmam a **presença de padrões espaciais significativos** na distribuição dos casos de SCZ.

---

## 📈 Principais Resultados

### 🔹 Análise Temporal
- Pico de casos em **2015–2016**, seguido de queda acentuada.
- Predominância de casos **confirmados por Zika vírus**.
- **Óbitos** concentrados no período inicial do surto.
- Maior ocorrência em **gestantes do litoral e zona da mata**.

### 🔹 Análise Espacial
- **Clusters de alta incidência** nas regiões metropolitanas e costeiras.  
- **Baixa incidência** em regiões do sertão.
- **Efeito de difusão territorial**: municípios com altos casos tendem a estar cercados por outros também afetados.

### 🔹 Modelagem Espacial
- O **modelo SAR** foi o mais eficiente (AIC = 711.9), confirmando autocorrelação espacial positiva (ρ = 0.21).  
- O **modelo SEM** captou efeitos regionais (λ = -0.32), mas de forma mais fraca.  
- O **OLS** apresentou boa explicação global, mas ignorou o padrão espacial dos resíduos.

---

## 🧠 Conclusão
A análise confirmou que a **Síndrome Congênita associada ao Zika Vírus não se distribui aleatoriamente** em Pernambuco.  
Os resultados mostram **forte estrutura espacial e temporal**, com **áreas de alta concentração** (clusters) especialmente no litoral e regiões metropolitanas.  
O modelo espacial demonstrou que **a dinâmica da SCZ segue um padrão de difusão regional**, onde a proximidade entre municípios aumenta a probabilidade de ocorrência de casos.

Esses achados reforçam a importância de **ações integradas e regionais de vigilância epidemiológica**, principalmente em surtos com propagação territorial.

---

## 🌍 Referências
- Anselin, L. (1995). *Local Indicators of Spatial Association — LISA*. Geographical Analysis.  
- ESDA & PySAL Documentation — [https://pysal.org](https://pysal.org)  
- Ministério da Saúde (BR). *Boletim Epidemiológico da Síndrome Congênita do Zika Vírus*.  
- IBGE — *Malhas Municipais de Pernambuco 2024*.  

---

## 👩‍💻 Autor
**Mateus Ribeiro de Albuquerque**  
Estudante de Sistemas de Informação — UFPE  

