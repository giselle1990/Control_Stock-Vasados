# app.R
library(shiny)
library(dplyr)
library(DT)
library(ggplot2)
library(lubridate)

# ====== Stock inicial (Categoría -> Subcategoría(producto)) ======
stock_inicial <- tibble::tribble(
  ~categoria,          ~subcategoria,      ~unidad,    ~cantidad,
  "Bandejas",          "bandejas",         "unidad",   930,
  "Vasos",             "Comunes",          "unidad",   490,
  "Vasos",             "Térmicos",         "unidad",   260,
  "Utensilios",        "tenedores",        "unidad",   94,
  "Papel Film",        "film",             "unidad",   0,
  "Servilletas",       "servilletas",      "unidad",   3,
  
  "Condimentos",       "azucar",           "kg",       2,
  "Condimentos",       "edulcorante",      "kg",       0,
  "Condimentos",       "sal",              "kg",       1,
  "Condimentos",       "aceite",           "l",        1,
  "Condimentos",       "vinagre",          "l",        2,
  "Condimentos",       "jugo de limon",    "l",        1,
  
  "Alimentos Secos",   "fideos",           "kg",       7.5,
  "Alimentos Secos",   "arroz",            "kg",       17,
  "Alimentos Secos",   "legumbre",         "kg",       4.3,
  "Alimentos Secos",   "salsa de tomate",  "l",        0.5,
  "Alimentos Secos",   "harina",           "kg",       6,
  "Alimentos Secos",   "mayonesa",         "kg",       1.5,
  "Alimentos Secos",   "polenta",          "kg",       3,
  
  "Bebidas Calientes", "cafe",             "unidad",   6,
  "Bebidas Calientes", "té",               "unidad",   0,
  "Bebidas Calientes", "mate cocido",      "unidad",   200,
  "Bebidas Calientes", "sopa (caldo)",     "paquete",  0,
  
  "Bebidas Frías",     "jugo",             "unidad",   0
)

# ====== UI ======
ui <- fluidPage(
  tags$head(
    tags$style(HTML("
  :root{
    --apple:#66d16e;
    --apple-dark:#2f8f46;
    --cream:#f6fff5;
    --ink:#123018;
    --card:#ffffff;
    --shadow: 0 8px 22px rgba(0,0,0,.08);
    --radius: 18px;
  }

  body{
    background: var(--cream);
    color: var(--ink);
    position: relative;
  }

  /* Fondo con capibaras MUY traslúcidas repetidas */
  body::before{
    content:'';
    position: fixed;
    inset: 0;
    pointer-events: none;
    z-index: 0;
    opacity: 0.07; /* bien traslúcido */
    background-image: url('https://twemoji.maxcdn.com/v/latest/svg/1f9ab.svg');
    background-repeat: repeat;
    background-size: 90px 90px;
    background-position: 20px 20px;
  }

  /* Asegura que el contenido quede arriba del watermark */
  .container-fluid, .row, .col-sm-4, .col-sm-8, .col-sm-12 {
    position: relative;
    z-index: 1;
  }

  .titleWrap{
    background: linear-gradient(90deg, var(--apple), #b9f5b6);
    padding: 18px 22px;
    border-radius: var(--radius);
    box-shadow: var(--shadow);
    margin-bottom: 14px;
    display:flex; align-items:center; justify-content:space-between;
  }

  .brandLeft{ display:flex; gap:14px; align-items:center; }
  .brandName{ font-size: 22px; font-weight: 800; letter-spacing:.2px; }
  .brandSub{ font-size: 12px; opacity:.9; margin-top:2px; }

  .pill{
    background: rgba(255,255,255,.75);
    border: 1px solid rgba(255,255,255,.6);
    padding: 7px 10px;
    border-radius: 999px;
    font-weight: 700;
    display:flex; gap:8px; align-items:center;
  }

  .card{
    background: var(--card);
    border-radius: var(--radius);
    box-shadow: var(--shadow);
    padding: 14px;
    margin-bottom: 12px;
  }

  .sidebar{
    background: var(--card);
    border-radius: var(--radius);
    box-shadow: var(--shadow);
    padding: 14px;
  }

  .control-label{ font-weight:700; }

  .btn{
    border-radius: 12px !important;
    font-weight: 800;
  }
  .btn-default, .btn-primary{
    background: var(--apple-dark) !important;
    border: 0 !important;
    color: white !important;
  }
  .btn-default:hover, .btn-primary:hover{
    filter: brightness(1.05);
  }

  .dataTables_wrapper{
    background: var(--card);
    border-radius: var(--radius);
    box-shadow: var(--shadow);
    padding: 10px;
  }

  h4{ font-weight: 900; margin-top: 10px; }
  .note{ font-size: 12px; opacity:.85; }
"))
  ),
  
  div(class="titleWrap",
      div(class="brandLeft",
          # “logo vegan” simple (hojita) + guiño capibara
          div(style="font-size:28px; line-height:1;", "🌿"),
          div(
            div(class="brandName", "Control de Stock Vasados"),
            div(class="brandSub", "Categorías → Subcategorías (productos) • Movimientos en tiempo real")
          )
      ),
      div(class="pill", span("🍏"), span(""), span("•"), span(class="capy",""))
  ),
  
  sidebarLayout(
    sidebarPanel(
      class="sidebar",
      h4("Registrar movimiento"),
      selectInput("mov_tipo", "Tipo", choices = c("Entrada","Salida","Ajuste")),
      uiOutput("mov_cat_ui"),
      uiOutput("mov_subcat_ui"),
      numericInput("mov_qty", "Cantidad", value = 1, min = 0),
      actionButton("add_mov_btn", "Guardar movimiento"),
      tags$hr(),
      h4("Filtros de reporte"),
      selectInput("f_cat", "Categoría", choices = c("Todas")),
      selectInput("f_unidad", "Unidad", choices = c("Todas")),
      div(class="note", "Tip: si querés reporte prolijo, filtrá por unidad (kg/l/unidad).")
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Dashboard",
                 div(class="card",
                     h4("Totales por Categoría"),
                     DTOutput("tabla_cat")
                 ),
                 div(class="card",
                     h4("Totales por Subcategoría (productos)"),
                     DTOutput("tabla_subcat")
                 ),
                 div(class="card",
                     h4("Reporte visual"),
                     plotOutput("plot_cat", height = 320)
                 )
        ),
        tabPanel("Movimientos",
                 div(class="card",
                     DTOutput("tabla_mov")
                 )
        ),
        tabPanel("Stock actual (detalle)",
                 div(class="card",
                     DTOutput("tabla_stock")
                 )
        )
      )
    )
  )
)

# ====== SERVER ======
server <- function(input, output, session) {
  
  stock0 <- reactiveVal(stock_inicial)
  
  movimientos <- reactiveVal(
    tibble::tibble(
      fecha = as.POSIXct(character()),
      tipo = character(),
      categoria = character(),
      subcategoria = character(),
      cantidad = numeric()
    )
  )
  
  # UI dinámica: categoría y subcategoría
  output$mov_cat_ui <- renderUI({
    cats <- sort(unique(stock0()$categoria))
    selectInput("mov_cat", "Categoría", choices = cats)
  })
  
  output$mov_subcat_ui <- renderUI({
    req(input$mov_cat)
    subs <- stock0() %>% filter(categoria == input$mov_cat) %>% pull(subcategoria) %>% unique() %>% sort()
    selectInput("mov_subcat", "Subcategoría (producto)", choices = subs)
  })
  
  # Stock actual calculado
  stock_actual <- reactive({
    s0 <- stock0()
    mov <- movimientos()
    
    if (nrow(mov) == 0) {
      return(s0 %>% mutate(stock = cantidad) %>% select(categoria, subcategoria, unidad, stock))
    }
    
    mov_signed <- mov %>%
      mutate(delta = case_when(
        tipo == "Entrada" ~ cantidad,
        tipo == "Salida"  ~ -cantidad,
        tipo == "Ajuste"  ~ cantidad,  # Ajuste: podés cargar positivo o negativo
        TRUE ~ 0
      )) %>%
      group_by(categoria, subcategoria) %>%
      summarise(delta = sum(delta, na.rm = TRUE), .groups = "drop")
    
    s0 %>%
      left_join(mov_signed, by = c("categoria","subcategoria")) %>%
      mutate(delta = ifelse(is.na(delta), 0, delta),
             stock = cantidad + delta) %>%
      select(categoria, subcategoria, unidad, stock) %>%
      arrange(categoria, subcategoria)
  })
  
  # Filtros
  observe({
    st <- stock_actual()
    updateSelectInput(session, "f_cat", choices = c("Todas", sort(unique(st$categoria))))
    updateSelectInput(session, "f_unidad", choices = c("Todas", sort(unique(st$unidad))))
  })
  
  stock_filtrado <- reactive({
    st <- stock_actual()
    if (input$f_cat != "Todas") st <- st %>% filter(categoria == input$f_cat)
    if (input$f_unidad != "Todas") st <- st %>% filter(unidad == input$f_unidad)
    st
  })
  
  # Guardar movimiento
  observeEvent(input$add_mov_btn, {
    req(input$mov_tipo, input$mov_cat, input$mov_subcat)
    
    qty <- input$mov_qty
    if (is.na(qty) || qty < 0) {
      showNotification("Cantidad inválida.", type = "error")
      return()
    }
    
    mov <- movimientos()
    mov <- bind_rows(mov, tibble::tibble(
      fecha = Sys.time(),
      tipo = input$mov_tipo,
      categoria = input$mov_cat,
      subcategoria = input$mov_subcat,
      cantidad = qty
    ))
    movimientos(mov)
    
    showNotification("Movimiento guardado.", type = "message")
  })
  
  # Tablas (orden pedido)
  output$tabla_cat <- renderDT({
    stock_filtrado() %>%
      group_by(categoria, unidad) %>%
      summarise(total = sum(stock, na.rm = TRUE), .groups = "drop") %>%
      arrange(desc(total)) %>%
      datatable(options = list(pageLength = 10), rownames = FALSE)
  })
  
  output$tabla_subcat <- renderDT({
    stock_filtrado() %>%
      group_by(categoria, subcategoria, unidad) %>%
      summarise(total = sum(stock, na.rm = TRUE), .groups = "drop") %>%
      arrange(categoria, desc(total)) %>%
      datatable(options = list(pageLength = 15), rownames = FALSE)
  })
  
  output$tabla_stock <- renderDT({
    datatable(stock_filtrado(), options = list(pageLength = 20), rownames = FALSE)
  })
  
  output$tabla_mov <- renderDT({
    movimientos() %>%
      arrange(desc(fecha)) %>%
      mutate(fecha = format(fecha, "%Y-%m-%d %H:%M:%S")) %>%
      datatable(options = list(pageLength = 20), rownames = FALSE)
  })
  
  # Plot por categoría (recomendado filtrar por unidad)
  output$plot_cat <- renderPlot({
    df <- stock_filtrado() %>%
      group_by(categoria) %>%
      summarise(total = sum(stock, na.rm = TRUE), .groups = "drop") %>%
      arrange(desc(total))
    
    ggplot(df, aes(x = reorder(categoria, total), y = total)) +
      geom_col(fill = "#2f8f46", color = "black", linewidth = 0.7) +  # ~2px visual
      geom_text(aes(label = round(total, 2)), hjust = -0.1, size = 4, fontface = "bold") +
      coord_flip(clip = "off") +
      labs(
        x = NULL,
        y = "Total",
        title = "Stock total por categoría"
      ) +
      theme_minimal() +
      theme(
        plot.margin = margin(10, 40, 10, 10)  # deja lugar para etiquetas a la derecha
      )
  })
}


shinyApp(ui, server)
