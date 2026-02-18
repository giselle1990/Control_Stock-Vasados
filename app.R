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
  "Condimentos",       "mayonesa",         "l",        1,
  
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

      body{ background: var(--cream); color: var(--ink); }

      body::before{
        content:'';
        position: fixed;
        inset: 0;
        pointer-events: none;
        z-index: 0;
        opacity: 0.05;
        background-image: url('https://twemoji.maxcdn.com/v/latest/svg/1f9ab.svg');
        background-repeat: repeat;
        background-size: 80px 80px;
      }

      .container-fluid{ position: relative; z-index: 1; }

      .titleWrap{
        background: linear-gradient(90deg, var(--apple), #b9f5b6);
        padding: 18px;
        border-radius: var(--radius);
        margin-bottom: 15px;
        box-shadow: var(--shadow);
      }

      .card{
        background: var(--card);
        border-radius: var(--radius);
        box-shadow: var(--shadow);
        padding: 15px;
        margin-bottom: 15px;
      }

      .btn-primary{
        background: var(--apple-dark) !important;
        border: none !important;
        font-weight: bold;
      }
    "))
  ),
  
  div(class="titleWrap",
      h2("🌿 Control de Stock General"),
      p("Sistema multi-voluntario con actualización automática")
  ),
  
  tabsetPanel(
    
    tabPanel("Stock General",
             fluidRow(
               column(3,
                      div(class="card",
                          h4("Filtros"),
                          selectInput("f_cat_general", "Categoría", choices = c("Todas")),
                          selectInput("f_unidad_general", "Unidad", choices = c("Todas"))
                      )
               ),
               column(9,
                      div(class="card",
                          h4("Totales por Categoría"),
                          DTOutput("tabla_cat")
                      ),
                      div(class="card",
                          h4("Totales por Subcategoría"),
                          DTOutput("tabla_subcat")
                      ),
                      div(class="card",
                          h4("Reporte visual"),
                          plotOutput("plot_cat", height = 320)
                      )
               )
             )
    ),
    
    tabPanel("Gestión por Voluntario",
             fluidRow(
               column(4,
                      div(class="card",
                          h4("Seleccionar voluntario"),
                          selectInput("voluntario_nombre", NULL,
                                      choices = c("Jazz","Agus","Sofi/Tom","Aye","Belu",
                                                  "Aby","Cris","Ricardo","Flor","Yami","Giselle")
                          ),
                          hr(),
                          h4("Registrar movimiento"),
                          selectInput("mov_tipo", "Tipo", choices = c("Entrada","Salida","Ajuste")),
                          uiOutput("mov_cat_ui"),
                          uiOutput("mov_subcat_ui"),
                          numericInput("mov_qty", "Cantidad", value = 1, min = 0),
                          actionButton("add_mov_btn", "Guardar movimiento", class="btn-primary")
                      )
               ),
               column(8,
                      div(class="card",
                          h4("Stock del voluntario"),
                          DTOutput("tabla_mi_stock")
                      ),
                      div(class="card",
                          h4("Historial de movimientos"),
                          DTOutput("tabla_mov")
                      )
               )
             )
    ),
    
    tabPanel("Resumen por Voluntario",
             div(class="card",
                 h4("Seleccionar voluntario"),
                 selectInput("selector_resumen", NULL,
                             choices = c("Jazz","Agus","Sofi/Tom","Aye","Belu",
                                         "Aby","Cris","Ricardo","Flor","Yami","Giselle")
                 )
             ),
             div(class="card",
                 h4("Stock individual"),
                 DTOutput("tabla_resumen_individual")
             ),
             div(class="card",
                 h4("Comparativo general"),
                 DTOutput("tabla_por_voluntario")
             )
    )
  )
)

# ====== SERVER ======
server <- function(input, output, session) {
  
  stock0 <- reactiveVal(stock_inicial)
  
  # ========= Movimientos precargados (INICIAL) =========
  movimientos <- reactiveVal(
    tibble::tribble(
      ~fecha, ~voluntario, ~tipo, ~categoria, ~subcategoria, ~cantidad, ~inicial,
      
      Sys.time(), "Jazz", "Entrada", "Bandejas", "bandejas", 0, TRUE,
      
      Sys.time(), "Agus", "Entrada", "Bandejas", "bandejas", 200,TRUE,
      Sys.time(), "Agus", "Entrada", "Vasos", "Comunes", 35,TRUE,
      Sys.time(), "Agus", "Entrada", "Vasos", "Térmicos", 64,TRUE,
      
      Sys.time(), "Sofi/Tom", "Entrada", "Bandejas", "bandejas", 80,TRUE,
      Sys.time(), "Sofi/Tom", "Entrada", "Vasos", "Comunes", 138,TRUE,
      Sys.time(), "Sofi/Tom", "Entrada", "Vasos", "Térmicos", 71,TRUE,
      Sys.time(), "Sofi/Tom", "Entrada", "Condimentos", "azucar", 1,TRUE,
      Sys.time(), "Sofi/Tom", "Entrada", "Condimentos", "vinagre", 1,TRUE,
      Sys.time(), "Sofi/Tom", "Entrada", "Alimentos Secos", "legumbre", 2.3,TRUE,
      Sys.time(), "Sofi/Tom", "Entrada", "Alimentos Secos", "salsa de tomate", 0.5,TRUE,
      Sys.time(), "Sofi/Tom", "Entrada", "Bebidas Calientes", "mate cocido", 100,TRUE,
      Sys.time(), "Sofi/Tom", "Entrada", "Condimentos", "mayonesa", 1.5,TRUE,
      Sys.time(), "Sofi/Tom", "Entrada", "Alimentos Secos", "polenta", 2.5,TRUE,
      
      Sys.time(), "Aye", "Entrada", "Bandejas", "bandejas", 100,TRUE,
      Sys.time(), "Aye", "Entrada", "Alimentos Secos", "harina", 6,TRUE,
      
      Sys.time(), "Belu", "Entrada", "Alimentos Secos", "polenta", 1.5,TRUE,
      Sys.time(), "Belu", "Entrada", "Alimentos Secos", "legumbre", 1.2,TRUE,
      
      Sys.time(), "Aby", "Entrada", "Bandejas", "bandejas", 20,TRUE,
      Sys.time(), "Aby", "Entrada", "Vasos", "Comunes", 20,TRUE,
      Sys.time(), "Aby", "Entrada", "Utensilios", "tenedores", 21,TRUE,
      Sys.time(), "Aby", "Entrada", "Alimentos Secos", "fideos", 1,TRUE,
      Sys.time(), "Aby", "Entrada", "Alimentos Secos", "legumbre", 2,TRUE,
      Sys.time(), "Aby", "Entrada", "Alimentos Secos", "salsa de tomate", 1.5,TRUE,
      Sys.time(), "Aby", "Entrada", "Bebidas Calientes", "mate cocido", 100,TRUE,
      
      Sys.time(), "Cris", "Entrada", "Bandejas", "bandejas", 10,TRUE,
      Sys.time(), "Cris", "Entrada", "Vasos", "Comunes", 87,TRUE,
      Sys.time(), "Cris", "Entrada", "Vasos", "Térmicos", 5,TRUE,
      Sys.time(), "Cris", "Entrada", "Utensilios", "tenedores", 23,TRUE,
      Sys.time(), "Cris", "Entrada", "Condimentos", "sal", 1,TRUE,
      Sys.time(), "Cris", "Entrada", "Condimentos", "aceite", 1,TRUE,
      Sys.time(), "Cris", "Entrada", "Condimentos", "vinagre", 1,TRUE,
      Sys.time(), "Cris", "Entrada", "Alimentos Secos", "arroz", 15,TRUE,
      Sys.time(), "Cris", "Entrada", "Condimentos", "jugo de limon", 1,TRUE,
      
      Sys.time(), "Ricardo", "Entrada", "Bandejas", "bandejas", 200,TRUE,
      Sys.time(), "Ricardo", "Entrada", "Vasos", "Comunes", 10,TRUE,
      Sys.time(), "Ricardo", "Entrada", "Vasos", "Térmicos", 5,TRUE,
      Sys.time(), "Ricardo", "Entrada", "Utensilios", "tenedores", 50,TRUE,
      Sys.time(), "Ricardo", "Entrada", "Alimentos Secos", "arroz", 2,TRUE,
      
      Sys.time(), "Flor", "Entrada", "Bandejas", "bandejas", 60,TRUE,
      Sys.time(), "Flor", "Entrada", "Vasos", "Comunes", 40,TRUE,
      Sys.time(), "Flor", "Entrada", "Vasos", "Térmicos", 10,TRUE,
      Sys.time(), "Flor", "Entrada", "Condimentos", "sal", 0.5,TRUE,
      Sys.time(), "Flor", "Entrada", "Condimentos", "aceite", 0.5,TRUE,
      Sys.time(), "Flor", "Entrada", "Bebidas Calientes", "cafe", 6,TRUE,
      
      Sys.time(), "Yami", "Entrada", "Bandejas", "bandejas", 60,TRUE,
      Sys.time(), "Yami", "Entrada", "Vasos", "Comunes", 80,TRUE,
      Sys.time(), "Yami", "Entrada", "Vasos", "Térmicos", 25,TRUE,
      
      Sys.time(), "Giselle", "Entrada", "Condimentos", "mayonesa", 1,TRUE,
      Sys.time(), "Giselle", "Entrada", "Alimentos Secos", "arroz", 3,TRUE,
      Sys.time(), "Giselle", "Entrada", "Bandejas", "bandejas", 100,TRUE,
      Sys.time(), "Giselle", "Entrada", "Vasos", "Térmicos", 88,TRUE,
      Sys.time(), "Giselle", "Entrada", "Vasos", "Comunes", 80,TRUE
    )
  )
  
  # UI dinámica: categoría / subcategoría
  output$mov_cat_ui <- renderUI({
    cats <- sort(unique(stock0()$categoria))
    selectInput("mov_cat", "Categoría", choices = cats)
  })
  
  output$mov_subcat_ui <- renderUI({
    req(input$mov_cat)
    subs <- stock0() %>%
      filter(categoria == input$mov_cat) %>%
      pull(subcategoria) %>%
      unique() %>%
      sort()
    selectInput("mov_subcat", "Subcategoría (producto)", choices = subs)
  })
  
  # Movimientos firmados
  movimientos_firmados <- reactive({
    mov <- movimientos()
    if (nrow(mov) == 0) return(tibble(voluntario=character(), categoria=character(), subcategoria=character(), delta=numeric()))
    
    mov %>%
      mutate(delta = case_when(
        tipo == "Entrada" ~ cantidad,
        tipo == "Salida"  ~ -cantidad,
        tipo == "Ajuste"  ~ cantidad,
        TRUE ~ 0
      )) %>%
      group_by(voluntario, categoria, subcategoria) %>%
      summarise(delta = sum(delta, na.rm = TRUE), .groups = "drop")
  })
  
  # Stock por voluntario (lo que "tiene" cada uno)
  stock_por_voluntario <- reactive({
    ms <- movimientos_firmados()
    s0 <- stock0()
    
    if (nrow(ms) == 0) {
      return(tibble(voluntario=character(), categoria=character(), subcategoria=character(), unidad=character(), stock=numeric()))
    }
    
    ms %>%
      left_join(s0 %>% select(categoria, subcategoria, unidad), by = c("categoria","subcategoria")) %>%
      mutate(unidad = ifelse(is.na(unidad), "-", unidad),
             stock = delta) %>%
      select(voluntario, categoria, subcategoria, unidad, stock) %>%
      arrange(voluntario, categoria, subcategoria)
  })
  
  # Stock general = stock inicial - (lo que tienen los voluntarios)
  stock_general <- reactive({
    s0 <- stock0()
    
    mov_total_futuro <- movimientos() %>%
      filter(inicial == FALSE) %>%   # 👈 IGNORA precarga
      mutate(delta = case_when(
        tipo == "Entrada" ~ cantidad,
        tipo == "Salida"  ~ -cantidad,
        tipo == "Ajuste"  ~ cantidad,
        TRUE ~ 0
      )) %>%
      group_by(categoria, subcategoria) %>%
      summarise(delta = sum(delta, na.rm = TRUE), .groups = "drop")
    
    s0 %>%
      left_join(mov_total_futuro, by = c("categoria","subcategoria")) %>%
      mutate(
        delta = ifelse(is.na(delta), 0, delta),
        stock = cantidad + delta
      ) %>%
      select(categoria, subcategoria, unidad, stock) %>%
      arrange(categoria, subcategoria)
  })
  
  
  # Filtros stock general
  observe({
    sg <- stock_general()
    updateSelectInput(session, "f_cat_general", choices = c("Todas", sort(unique(sg$categoria))))
    updateSelectInput(session, "f_unidad_general", choices = c("Todas", sort(unique(sg$unidad))))
  })
  
  stock_general_filtrado <- reactive({
    sg <- stock_general()
    if (!is.null(input$f_cat_general) && input$f_cat_general != "Todas") sg <- sg %>% filter(categoria == input$f_cat_general)
    if (!is.null(input$f_unidad_general) && input$f_unidad_general != "Todas") sg <- sg %>% filter(unidad == input$f_unidad_general)
    sg
  })
  
  # Guardar movimiento
  observeEvent(input$add_mov_btn, {
    
    req(input$mov_tipo, input$mov_cat, input$mov_subcat, input$voluntario_nombre)
    
    qty <- input$mov_qty
    
    if (is.na(qty) || qty < 0) {
      showModal(modalDialog(
        title = "Error",
        div(style="color:red; font-weight:bold;",
            "Cantidad inválida."),
        easyClose = TRUE,
        footer = NULL
      ))
      return()
    }
    
    mov <- movimientos()
    
    mov <- bind_rows(mov, tibble::tibble(
      fecha = Sys.time(),
      voluntario = input$voluntario_nombre,
      tipo = input$mov_tipo,
      categoria = input$mov_cat,
      subcategoria = input$mov_subcat,
      cantidad = qty,
      inicial = FALSE
    ))
    
    movimientos(mov)
    
    # 🎯 Modal según tipo
    mensaje <- ""
    color   <- ""
    
    if (input$mov_tipo == "Entrada") {
      mensaje <- "Elemento agregado exitosamente ✔️"
      color   <- "#2f8f46"
    }
    
    if (input$mov_tipo == "Salida") {
      mensaje <- "Elemento eliminado exitosamente 🗑️"
      color   <- "#c0392b"
    }
    
    if (input$mov_tipo == "Ajuste") {
      mensaje <- "Stock ajustado correctamente 🔧"
      color   <- "#2980b9"
    }
    
    showModal(modalDialog(
      title = NULL,
      div(style=paste0("font-size:18px; font-weight:bold; color:", color, ";"),
          mensaje),
      easyClose = TRUE,
      footer = NULL
    ))
    
  })
  
  
  
  # Tablas stock general
  output$tabla_cat <- renderDT({
    stock_general_filtrado() %>%
      group_by(categoria, unidad) %>%
      summarise(total = sum(stock, na.rm = TRUE), .groups = "drop") %>%
      arrange(desc(total)) %>%
      datatable(options = list(pageLength = 10), rownames = FALSE)
  })
  
  output$tabla_subcat <- renderDT({
    stock_general_filtrado() %>%
      group_by(categoria, subcategoria, unidad) %>%
      summarise(total = sum(stock, na.rm = TRUE), .groups = "drop") %>%
      arrange(categoria, desc(total)) %>%
      datatable(options = list(pageLength = 15), rownames = FALSE)
  })
  
  # Tablas voluntario
  output$tabla_mi_stock <- renderDT({
    req(input$voluntario_nombre)
    stock_por_voluntario() %>%
      filter(voluntario == input$voluntario_nombre) %>%
      datatable(options = list(pageLength = 15), rownames = FALSE)
  })
  
  output$tabla_mov <- renderDT({
    req(input$voluntario_nombre)
    movimientos() %>%
      filter(voluntario == input$voluntario_nombre) %>%
      arrange(desc(fecha)) %>%
      mutate(fecha = format(fecha, "%Y-%m-%d %H:%M:%S")) %>%
      datatable(options = list(pageLength = 20), rownames = FALSE)
  })
  
  output$tabla_por_voluntario <- renderDT({
    stock_por_voluntario() %>%
      group_by(voluntario, categoria, unidad) %>%
      summarise(total = sum(stock, na.rm = TRUE), .groups = "drop") %>%
      arrange(voluntario, categoria) %>%
      datatable(options = list(pageLength = 25), rownames = FALSE)
  })
  
  output$tabla_resumen_individual <- renderDT({
    req(input$selector_resumen)
    stock_por_voluntario() %>%
      filter(voluntario == input$selector_resumen) %>%
      datatable(options = list(pageLength = 20), rownames = FALSE)
  })
  
  # Plot stock general
  output$plot_cat <- renderPlot({
    df <- stock_general_filtrado() %>%
      group_by(categoria) %>%
      summarise(total = sum(stock, na.rm = TRUE), .groups = "drop") %>%
      arrange(desc(total))
    
    ggplot(df, aes(x = reorder(categoria, total), y = total)) +
      geom_col(fill = "#2f8f46", color = "black", linewidth = 0.7) +
      geom_text(aes(label = round(total, 2)), hjust = -0.1, size = 4, fontface = "bold") +
      coord_flip(clip = "off") +
      labs(x = NULL, y = "Total", title = "Stock total por categoría — Total general") +
      theme_minimal() +
      theme(plot.margin = margin(10, 40, 10, 10))
  })
}

shinyApp(ui, server)
