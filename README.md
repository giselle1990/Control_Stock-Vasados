# 📦 Control de Stock – Vasados

Sistema de gestión de stock desarrollado en **R + Shiny**, pensado para organizaciones y equipos de voluntariado que necesitan controlar insumos de manera simple, visual y en tiempo real.

---

## 🌿 Características principales

- ✅ Stock inicial configurable
- ✅ Gestión multi-voluntario
- ✅ Movimientos de Entrada / Salida / Ajuste
- ✅ Dashboard general automático
- ✅ Filtros por categoría y unidad
- ✅ Resumen individual por voluntario
- ✅ Historial de movimientos
- ✅ Confirmaciones visuales (modal)
- ✅ Interfaz personalizada verde manzana 🍏
- ✅ Fondo temático con capibaras translúcidas

---

## 🧠 Lógica del sistema

- El **Stock General** parte del `stock_inicial`.
- Los movimientos precargados son solo informativos.
- Solo los **movimientos futuros** modifican el total general.
- Cada voluntario tiene su propio stock visible.
- El Dashboard siempre refleja el total actualizado automáticamente.

---

## 🗂️ Estructura de la aplicación

### 1️⃣ Stock General
- Totales por categoría
- Totales por subcategoría
- Reporte visual (gráfico de barras)
- Filtros dinámicos

### 2️⃣ Gestión por Voluntario
- Selección de voluntario
- Registro de movimientos
- Vista de stock individual
- Historial personal

### 3️⃣ Resumen por Voluntario
- Selector individual
- Comparativo general
- Tabla consolidada

---

## 📊 Tecnologías utilizadas

- R  
- Shiny  
- dplyr  
- DT  
- ggplot2  
- lubridate  

---

## 🚀 Cómo ejecutar la app

1. Clonar el repositorio:

```bash
git clone https://github.com/giselle1990/Control_Stock-Vasados.git
