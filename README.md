# 🌿 Control de Stock Vegan – Shiny App

Aplicación desarrollada en **R Shiny** para la gestión dinámica de stock con estructura jerárquica:

> Categoría → Subcategoría (producto) → Unidad → Movimientos

Diseñada con enfoque minimalista, estética verde manzana y visualización clara de métricas operativas.

---

## 🍏 Funcionalidades principales

- ✔ Registro de movimientos en tiempo real (Entrada / Salida / Ajuste)
- ✔ Cálculo automático de stock actual
- ✔ Resumen por **categoría**
- ✔ Resumen por **subcategoría (producto)**
- ✔ Reporte visual con etiquetas de cantidad
- ✔ Filtro por unidad de medida (kg / l / unidad / paquete)
- ✔ Historial completo de movimientos

---

## 📊 Lógica de cálculo

El stock actual se calcula automáticamente mediante:

```
Stock actual = Stock inicial + Entradas − Salidas ± Ajustes
```

Todos los reportes se actualizan en tiempo real gracias al modelo reactivo de Shiny.

---

## 🧠 Estructura del modelo de datos

```
Categoría
   └── Subcategoría (Producto)
          └── Unidad de medida
                 └── Movimientos
```

Esto permite:

- Agregación por categoría
- Agregación por producto
- Filtrado por unidad
- Reportes visuales consistentes

---

## 🎨 Diseño

- Paleta verde manzana 🌿
- Estética minimalista tipo vegan dashboard
- Fondo con patrón translúcido
- Tarjetas con sombra suave
- Gráficos con:
  - Barras verde oscuro
  - Borde negro
  - Etiquetas visibles de cantidad

Diseñado para lectura rápida y control operativo eficiente.

---

## 🛠 Tecnologías utilizadas

- R
- Shiny
- dplyr
- ggplot2
- DT
- CSS personalizado

---

## 🚀 Cómo ejecutar la app

### 1️⃣ Clonar el repositorio

```bash
git clone https://github.com/tuusuario/control-stock-vegan.git
cd control-stock-vegan
```

### 2️⃣ Instalar paquetes necesarios

```r
install.packages(c("shiny","dplyr","ggplot2","DT","lubridate"))
```

### 3️⃣ Ejecutar la aplicación

```r
shiny::runApp()
```

---

## 📈 Roadmap / Mejoras futuras

- Persistencia en base de datos (SQLite)
- Control de usuarios y permisos
- Alertas de stock mínimo (semáforo)
- Exportación a Excel / CSV
- Dashboard KPI avanzado
- Deploy en shinyapps.io o servidor propio

---

## 👩‍💻 Autora

Desarrollado por **Giselle San German**  
Abogada | Analista de Datos | BI & Auditoría  

Soluciones prácticas basadas en datos para gestión operativa y control interno.

---

## 📄 Licencia

Proyecto desarrollado con fines de gestión y portfolio profesional.
