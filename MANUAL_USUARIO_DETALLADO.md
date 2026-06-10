# MANUAL DE USUARIO
# TEST VOCACIONAL - CONOCET

**Elaborado por:** Equipo de Desarrollo CEPRUNSA
**Revisado por:** Área de Desarrollo
**Aprobado por:** Dirección del Proyecto
**Cargo:** Desarrollador / Analista
**Fecha:** 10/06/2026

---

## HOJA DE CONTROL

| Organismo | Proyecto | Entregable | Autor | Versión | Fecha |
| :--- | :--- | :--- | :--- | :--- | :--- |
| CEPRUNSA | Test Vocacional CONOCET | Manual de Usuario Detallado | Equipo de Desarrollo | 02.00 | 10/06/2026 |

---

## CONTROL DE CAMBIOS

| Versión | Causa del Cambio | Responsable del Cambio | Fecha del Cambio |
| :--- | :--- | :--- | :--- |
| 01.00 | Versión inicial del manual de usuario | Equipo de Desarrollo | 24/05/2024 |
| 02.00 | Manual detallado con descripción de todas las pantallas y flujos reales de la aplicación | Equipo de Desarrollo | 10/06/2026 |

---

## 1. INTRODUCCIÓN

La aplicación **ConoceT** es una herramienta de orientación vocacional desarrollada para el **CEPRUNSA** (Centro Preuniversitario de la Universidad Nacional de San Agustín de Arequipa). Está diseñada para ayudar a los estudiantes y postulantes a descubrir su perfil profesional a través de tests estructurados por áreas de conocimiento.

La aplicación permite:
- Gestionar múltiples perfiles de usuario locales en el mismo dispositivo.
- Realizar evaluaciones vocacionales divididas por áreas temáticas.
- Guardar el progreso automáticamente (borradores) para poder reanudar un test interrumpido.
- Visualizar resultados detallados con gráficos interactivos (podio de carreras, gráfico de radar de personalidad, gráfico circular de macro-áreas).
- Sincronizar los resultados con la nube (Firebase/Firestore) cuando hay conexión a internet.

---

## 2. OBJETIVO

Orientar al usuario en el uso correcto de todas las funcionalidades de la aplicación móvil **ConoceT**, describiendo paso a paso cada pantalla, sus elementos y comportamientos, para garantizar una experiencia de evaluación fluida y que permita al usuario identificar sus fortalezas, intereses académicos y rasgos de personalidad.

---

## 3. ALCANCE

El presente manual cubre todas las pantallas y funciones disponibles en la aplicación, incluyendo:

- Pantalla de presentación (Onboarding) — solo en el primer acceso.
- Selección y gestión de perfiles de usuario.
- Formulario de creación de perfil con datos personales y académicos.
- Panel principal (Inicio) con acceso a las funciones principales.
- Selección y seguimiento de áreas de evaluación.
- Desarrollo del test (quiz) con guardado automático de borrador.
- Pantalla de historial de resultados por área.
- Pantalla de detalle de intento con gráficos y consejos.
- Pantalla de resultados generales (todas las áreas).
- Menú lateral de navegación (App Drawer).
- Pantalla de información institucional (Acerca de).

---

## 4. DESCRIPCIONES Y ABREVIATURAS

| Término / Sigla | Definición |
| :--- | :--- |
| **ConoceT** | Nombre de la aplicación de Test Vocacional. También puede aparecer como "CONOCET". |
| **CEPRUNSA** | Centro Preuniversitario de la Universidad Nacional de San Agustín de Arequipa. |
| **Perfil** | Cuenta local de usuario que almacena sus datos personales y resultados de evaluación. |
| **Área de Evaluación** | Categoría temática del test. Actualmente: Preferencias Profesionales y Personalidad. |
| **Borrador (Draft)** | Guardado automático del progreso de un test en curso. Permite retomar el test donde se dejó. |
| **Intento** | Una sesión completa del test en un área específica. Cada intento queda registrado en el historial. |
| **Podio de Carreras** | Visualización de las 3 carreras específicas con mayor afinidad obtenida en el test de Preferencias. |
| **Gráfico de Radar** | Representación visual de los 5 rasgos de personalidad evaluados. |
| **Macro Pie Chart** | Gráfico circular con la distribución porcentual de los intereses vocacionales por macro-área. |
| **Perfil Indiferenciado** | Resultado donde los puntajes entre todas las áreas son muy similares (diferencia < 4 puntos). |
| **Ítem de Control** | Pregunta especial en el test de Personalidad que valida la consistencia de las respuestas. |
| **Tour Interactivo** | Tutorial guiado que aparece la primera vez que el usuario accede a ciertas pantallas. |
| **Dimensión** | Rasgo o categoría medida dentro de un área de evaluación (ej. "Curiosidad Intelectual"). |
| **Nivel** | Calificación de una dimensión: Bajo (rojo), Medio (naranja), Alto (verde), Muy Alto (verde azulado). |

---

## 5. ACCESO AL SISTEMA

### 5.1 Primer Acceso — Pantalla de Onboarding

La primera vez que se instala y abre la aplicación, el usuario verá una pantalla de bienvenida de **3 diapositivas** (onboarding). Esta pantalla **solo aparece una única vez**.

**Diapositiva 1 — Bienvenida:**
- Título: *"¡Bienvenido a ConoceT!"*
- Descripción: *"Tu brújula para descubrir tu camino profesional..."*
- Ícono: 🧭 (exploración)

**Diapositiva 2 — Preferencias Profesionales:**
- Título: *"Preferencias Profesionales"*
- Descripción: Explica que el test evalúa intereses en diferentes campos del conocimiento.
- Ícono: 📚 (libros)

**Diapositiva 3 — Perfil de Personalidad:**
- Título: *"Perfil de Personalidad"*
- Descripción: Explica que el test identifica rasgos y fortalezas personales.
- Ícono: 🧠 (psicología)

**Controles de navegación:**

| Elemento | Descripción |
| :--- | :--- |
| **Indicadores de punto** (●) | Puntos en la parte inferior que muestran la diapositiva actual. El punto activo se expande. |
| **Botón "Siguiente"** | Avanza a la siguiente diapositiva. |
| **Botón "Omitir"** | Visible en las diapositivas 1 y 2. Salta directamente a la Selección de Perfil. |
| **Botón "Empezar"** | Aparece en la diapositiva 3 (última). Finaliza el onboarding y va a Selección de Perfil. |

> **Nota:** Una vez completado o saltado el onboarding, no vuelve a aparecer. El usuario irá directamente a la pantalla de Selección de Perfil en los accesos siguientes.

---

### 5.2 Pantalla de Selección de Perfil

Después del onboarding (o en accesos posteriores), se muestra la pantalla principal de acceso:

**Elementos de la pantalla:**

| Elemento | Descripción |
| :--- | :--- |
| **Banner de cuenta regresiva** | Banner informativo en la parte superior (widget `CountdownBanner`). Puede mostrar una fecha límite o información de eventos. |
| **Logo ConoceT** | Imagen del logo de la aplicación (altura: 200px). |
| **Texto "¿Quién está usando la app?"** | Título que invita a seleccionar el perfil activo. |
| **Texto "Selecciona tu perfil o crea uno nuevo."** | Subtítulo de instrucción. |
| **Botón "+ Crear nuevo perfil"** | Navega al formulario de creación de perfil. |
| **Lista de perfiles existentes** | Cada perfil aparece como una tarjeta con: avatar con iniciales, nombre completo, estado académico y edad. |
| **Botón de eliminar (🗑️)** | En cada tarjeta de perfil, a la derecha. Elimina el perfil tras confirmación. |
| **Logo CEPRUNSA** | Logo institucional en la parte inferior de la página (altura: 50px). |

**Tarjeta de perfil — descripción de campos:**

| Campo | Descripción |
| :--- | :--- |
| **Avatar** | Círculo con las iniciales del nombre del perfil, con color primario de la app. |
| **Nombre** | Nombre completo del usuario, en negrita. |
| **Subtítulo** | Estado académico (label) seguido de un punto (·) y la edad en años calculada desde la fecha de nacimiento. |

**Acciones disponibles:**

- **Tocar una tarjeta de perfil** → Activa ese perfil y navega al **Panel Principal (Inicio)**.
- **Tocar el ícono 🗑️** → Muestra un diálogo de confirmación con opciones "Cancelar" y "Eliminar" (en rojo). Si se confirma, el perfil se borra permanentemente.
- **Estado vacío** → Si no hay perfiles, se muestra el mensaje: *"No hay perfiles aún. Crea uno para comenzar."*

---

## 6. CREACIÓN DE PERFIL

Al pulsar **"Crear nuevo perfil"**, se accede a un formulario dividido en tres secciones. Todos los campos marcados con **asterisco rojo (\*)** son obligatorios.

### Sección 1: Datos Personales

| Campo | Tipo | Obligatorio | Detalles |
| :--- | :--- | :--- | :--- |
| **Nombre completo** | Texto | Sí (\*) | Ícono de persona. Capitalización de palabras automática. Ej.: *"Juan Pérez"* |
| **Correo electrónico** | Email | Sí (\*) | Ícono de sobre. Valida que contenga "@". Ej.: *"ejemplo@correo.com"* |

### Sección 2: Posibles Carreras

Permite registrar hasta **3 carreras de interés** con autocompletado desde una base de datos de carreras cargada desde `assets/data/carreras.json`.

| Campo | Obligatorio | Detalles |
| :--- | :--- | :--- |
| **Opción 1** | Sí (\*) | Al menos una carrera es requerida. Tiene autocompletado con búsqueda por texto. |
| **Opción 2** | No | Opcional. Mismo autocompletado. |
| **Opción 3** | No | Opcional. Mismo autocompletado. |

> **Cómo usar el autocompletado:** Al escribir parte del nombre de una carrera, aparece una lista de sugerencias. Selecciona una para completar el campo automáticamente.

### Sección 3: Género

Selector de dos botones horizontales:
- **Masculino** (seleccionado por defecto)
- **Femenino**

El botón seleccionado cambia a color primario de la app con texto blanco.

### Sección 4: Fecha de Nacimiento

Al tocar el campo, se abre el **selector de fecha del sistema** en español. Restricciones:
- Edad mínima: 10 años.
- Edad máxima: 60 años.
- Fecha inicial sugerida: hace 16 años desde hoy.

Una vez seleccionada, muestra la fecha en formato `DD/MM/AAAA`.

### Sección 5: Educación de Procedencia

**Tipo de colegio de procedencia** (Obligatorio):

Desplegable con 3 opciones:
- Nacional
- Parroquial
- Particular

**Estado académico actual** (Obligatorio):

Lista de opciones de selección única (radio buttons). Las opciones disponibles corresponden al enum `AcademicStatus` de la aplicación:

| Opción (label) | Descripción |
| :--- | :--- |
| *(según valores del enum)* | Opciones que representan el estado académico del usuario, ej. estudiante de 4to, 5to, egresado, etc. |

> **Nota:** En la pantalla de inicio, si el usuario tiene el estado "Egresado", no se muestra el estado en el banner de bienvenida.

### Guardar Perfil

El botón **"Guardar y continuar"** (ancho completo, 48px de alto):
- Valida todos los campos obligatorios.
- Si falta la fecha de nacimiento, muestra: *"Por favor selecciona tu fecha de nacimiento."*
- Si falta el estado académico, muestra: *"Por favor selecciona tu estado académico actual."*
- Muestra un **spinner de carga** durante el guardado.
- Al guardar exitosamente, navega directamente al **Panel Principal (Inicio)** y establece el nuevo perfil como activo, **limpiando toda la pila de navegación**.

---

## 7. PANEL PRINCIPAL (INICIO)

Es la pantalla central de la aplicación. Muestra el saludo personalizado y acceso rápido a las funciones principales.

**Elementos de la pantalla:**

| Elemento | Descripción |
| :--- | :--- |
| **AppBar** | Título "Inicio" centrado. Ícono de cerrar sesión (🚪) a la derecha. Ícono del menú (☰) a la izquierda que abre el App Drawer. |
| **Banner de cuenta regresiva** | En la parte superior del cuerpo (widget `CountdownBanner`). |
| **Logo ConoceT** | Imagen principal (altura: 250px). |
| **Banner de bienvenida** | Tarjeta con avatar (iniciales), nombre del usuario y estado académico actual. |
| **Texto "¿Qué deseas hacer?"** | Encabezado de la sección de acciones. |
| **Tarjeta "Realizar evaluación"** | Ícono de formulario 📋. Navega a la pantalla de Selección de Área. |
| **Tarjeta "Consultar resultados"** | Ícono de historial 🕐. Navega a la pantalla de Resultados Generales. |
| **Logo CEPRUNSA** | Logo institucional al final de la página (altura: 40px). |

### Tour Interactivo (primera vez)

La **primera vez** que el usuario accede al Inicio (campo `tourHomeShown = false`), se lanza automáticamente un **tour guiado** que resalta:
1. La tarjeta "Realizar evaluación" — con el mensaje: *"Presiona aquí para comenzar tus test vocacionales."*
2. La tarjeta "Consultar resultados" — con el mensaje: *"Aquí podrás ver el progreso y resultados de tus test."*

Una vez completado o saltado el tour, no vuelve a aparecer.

### Cerrar Sesión

Al pulsar el ícono 🚪 en la AppBar:
- Se muestra un diálogo: *"¿Deseas cambiar de perfil?"*
- Opciones: **"Cancelar"** o **"Cerrar sesión"**.
- Si se confirma, limpia la sesión activa y regresa a la pantalla de **Selección de Perfil**, limpiando toda la pila de navegación.

> **Nota:** "Cerrar sesión" no elimina el perfil. Solo lo desactiva para que otro usuario del dispositivo pueda seleccionar el suyo.

---

## 8. MENÚ DE NAVEGACIÓN (APP DRAWER)

Accesible desde el ícono ☰ de la AppBar en las pantallas: Inicio, Selección de Área, Resultados Generales y Acerca de.

**Opciones del menú:**

| Opción | Ícono | Destino |
| :--- | :--- | :--- |
| **Inicio** | 🏠 | Pantalla de Inicio (HomeScreen) |
| **Evaluaciones** | 📋 | Pantalla de Selección de Área |
| **Resultados** | 📊 | Pantalla de Resultados Generales |
| **Acerca de** | ℹ️ | Pantalla de información institucional |
| **Cerrar sesión** | 🚪 | Regresa a Selección de Perfil |

---

## 9. EVALUACIONES

### 9.1 Pantalla de Selección de Área

Muestra todas las áreas de evaluación disponibles como tarjetas individuales.

**Áreas de evaluación disponibles:**

| Área | Descripción |
| :--- | :--- |
| **Preferencias Profesionales** | Evalúa los intereses del usuario en diferentes campos del conocimiento para identificar afinidades con carreras específicas. |
| **Personalidad** | Evalúa rasgos de personalidad distribuidos en 5 dimensiones: Resiliencia y Manejo del Estrés, Disciplina Académica, Curiosidad Intelectual, Liderazgo y Sociabilidad, y Aprendizaje Colaborativo. |

> **Nota:** Las áreas y su descripción exacta provienen del enum `EvaluationArea` de la aplicación.

**Tarjeta de área — elementos:**

| Elemento | Descripción |
| :--- | :--- |
| **Nombre del área** | Título en negrita. |
| **Badge de intentos** | Etiqueta de color que indica el estado de intentos disponibles. |
| **Descripción** | Texto breve en gris con la descripción del área. |
| **Barra de progreso** | Visible solo si hay un borrador en curso (naranja). Muestra el número de pregunta actual y el porcentaje avanzado. |
| **Botón "Iniciar"** | Inicia un nuevo intento (sin intentos previos ni borrador). |
| **Botón "Continuar"** | Retoma un borrador existente (el ícono cambia a ▶️). |
| **Botón "Nuevo intento"** | Inicia un intento nuevo cuando ya existen intentos completados. |
| **Botón "Ver resultados"** | Solo visible si hay intentos completados. Navega al historial del área. |

**Badge de intentos — colores:**

| Color | Significado |
| :--- | :--- |
| 🔵 Azul claro | Sin intentos previos. Muestra "N intentos disponibles". |
| 🟠 Naranja claro | Hay intentos hechos y aún quedan disponibles. Muestra "N intento(s) restantes". |
| 🔴 Rojo claro | Sin intentos disponibles. Muestra "Sin intentos". |

### Tour Interactivo (primera vez en Áreas)

La primera vez que el usuario accede a esta pantalla (`tourAreasShown = false`), se lanza un tour que resalta la primera tarjeta de área con el mensaje: *"Aquí verás los diferentes test disponibles. Comenzaremos con el de Preferencias Profesionales."*

---

### 9.2 Pantalla del Test (Quiz)

Es la pantalla donde se desarrolla el test pregunta por pregunta.

**Estructura de la pantalla:**

| Zona | Descripción |
| :--- | :--- |
| **AppBar** | Muestra el nombre del área evaluada. Sin menú lateral. |
| **Cabecera de progreso** | Muestra "Pregunta X de Y" (izquierda) y el porcentaje de avance (derecha) en el color primario de la app. Debajo, una **barra de progreso animada** (10px de alto, animación de 400ms). |
| **Tarjeta de pregunta** | Tarjeta con fondo de color primario contenedor. Muestra el enunciado de la pregunta con fuente de 17px y altura de línea 1.5. |
| **Texto "Selecciona tu respuesta:"** | Etiqueta en gris antes de las opciones. |
| **Opciones de respuesta** | Lista de tiles con animación de selección (180ms). |
| **Barra inferior** | Botones de navegación: "ATRÁS" (opcional) y "SIGUIENTE" / "FINALIZAR". |

**Opciones de respuesta — comportamiento:**

| Estado | Apariencia |
| :--- | :--- |
| **No seleccionada** | Borde gris, fondo transparente. Ícono `○` (círculo vacío) en gris. |
| **Seleccionada** | Fondo sólido color primario, texto blanco en negrita. Ícono `✔` (check) blanco. |

**Navegación dentro del test:**

| Botón | Condición | Acción |
| :--- | :--- | :--- |
| **ATRÁS** | Solo visible si no es la primera pregunta. | Retrocede a la pregunta anterior, recuperando la respuesta guardada. |
| **SIGUIENTE** | Activo solo si hay una opción seleccionada y no está procesando. | Guarda la respuesta, guarda el borrador, avanza a la siguiente pregunta. |
| **FINALIZAR** | Aparece en la última pregunta (en lugar de "SIGUIENTE"). | Completa el intento, muestra pantalla de procesamiento y navega a Resultados. |

> **Animación de pregunta:** Cada cambio de pregunta tiene una animación de desplazamiento (slide) desde la derecha y fundido (fade), con duración de 350ms.

**Guardado automático de borrador:**
- Cada vez que se avanza una pregunta, se guarda un borrador automáticamente.
- Si el usuario retrocede con el botón físico del dispositivo o cierra la app, el borrador también se guarda. Al volver al área, el botón mostrará "Continuar" en lugar de "Iniciar".

**Pantalla de procesamiento (al finalizar):**

Al responder la última pregunta, antes de mostrar los resultados, aparece una pantalla intermedia que muestra:
- Logo de ConoceT (200px de alto).
- Spinner de carga.
- Mensaje: *"Estamos analizando tus respuestas para generar tu perfil. ¡Ya casi terminamos!"*

Esta pantalla dura **3 segundos** antes de redirigir a los resultados.

**Validación del test de Personalidad:**

El área de Personalidad incluye un **ítem de control**. Si la aplicación detecta respuestas inconsistentes o al azar, el intento es invalidado. Aparece un diálogo:
- Título: *"Prueba Invalidada"*
- Mensaje: Explica que se detectaron respuestas inconsistentes y que el intento NO se guardará en el historial.
- Botón **"ENTENDIDO"** regresa a la pantalla anterior.

**Sincronización con Firebase:**

Al finalizar un test exitosamente, la aplicación intenta subir el resultado a Firebase/Firestore en segundo plano (si hay conexión a internet). Esto no bloquea al usuario.

**Tour Interactivo del Quiz (primera vez en Preferencias):**

Solo en el área de "Preferencias Profesionales" y solo en el primer intento (`tourQuizShown = false`), se lanza un tour que resalta:
1. La tarjeta de pregunta — *"Lee atentamente el enunciado de cada pregunta."*
2. El bloque de opciones — *"Elige la opción que mejor se identifique contigo."*

---

## 10. RESULTADOS

### 10.1 Historial de Resultados por Área (ResultScreen)

Accesible al pulsar "Ver resultados" en la tarjeta de un área, o automáticamente al finalizar un test.

**Elementos:**

| Elemento | Descripción |
| :--- | :--- |
| **AppBar** | Título: "Historial – [Nombre del Área]". |
| **Lista de intentos** | Ordenados del más reciente al más antiguo. Cada uno como tarjeta. |
| **Tarjeta de intento** | Muestra: "Intento N" (negrita) + fecha en formato `D/M/AAAA`. |
| **Estado inválido** | Si el intento fue invalidado, el subtítulo muestra "Prueba invalidada · [fecha]" en rojo. |
| **Flecha de detalle →** | Toque en la tarjeta → navega al Detalle del Intento. |

> **Estado vacío:** Si no hay intentos, muestra: *"No hay intentos registrados."*

> **Redirección automática:** Al terminar un test, se navega primero a esta pantalla, pero de inmediato se abre automáticamente el detalle del intento recién completado.

---

### 10.2 Detalle del Intento (AttemptDetailScreen)

La pantalla más completa de la aplicación. Muestra el análisis detallado de un intento específico.

**AppBar:** Título: *"Intento N - [Nombre del Área]"*

**Pantalla de carga inicial:**
Antes de mostrar los resultados, la app sincroniza con Firestore y carga datos locales (descripciones de carreras o consejos). Muestra:
- Logo ConoceT (150px).
- Spinner.
- Texto: *"Estamos preparando tus resultados..."*

**Contenido principal (según el área y validez del intento):**

#### Caso 1: Intento Invalidado

Muestra una **tarjeta de advertencia roja** (`WarningCard`) con:
- Título: **"PRUEBA INVALIDADA"**
- Mensaje: *"Se detectaron respuestas inconsistentes o al azar. Te recomendamos realizar el test nuevamente con sinceridad."*

#### Caso 2: Área de Preferencias Profesionales (válido)

**A) Advertencia: Perfil Indiferenciado (condicional)**

Si la diferencia entre el puntaje máximo y mínimo entre todas las dimensiones es menor a 4 puntos, se muestra:
- Título: **"Perfil Indiferenciado"**
- Mensaje: Informa que los intereses no están claramente jerarquizados y sugiere orientación vocacional personalizada.

**B) Perfil de Áreas (Macro) — Gráfico circular (`MacroPieChart`)**

Gráfico de pastel que muestra la distribución porcentual de los puntajes obtenidos en las macro-áreas de conocimiento.

**C) Top 3 Carreras Específicas (Micro) — Podio (`PodiumWidget`)**

Visualización en forma de podio con las **3 carreras con mayor puntaje** del test:
- 1° lugar (más destacado).
- 2° lugar.
- 3° lugar.

> **Interacción:** Tocar una carrera del podio abre un **diálogo** con el nombre de la carrera y su descripción (cargada desde `assets/data/carreras.json`). Si la carrera es "N/A" o no tiene descripción, no ocurre nada.

**Texto guía:** *"Toca una carrera para ver su descripción"* (en gris, centrado).

#### Caso 3: Área de Personalidad (válido)

**A) Gráfico de Radar (`PersonalityRadarChart`)**

Visualiza los 5 rasgos de personalidad en el siguiente orden fijo:
1. Resiliencia y Manejo del Estrés
2. Disciplina Académica
3. Curiosidad Intelectual
4. Liderazgo y Sociabilidad
5. Aprendizaje Colaborativo

**B) Consejos Personalizados (`AdviceBoxes`)**

Basados en los puntajes obtenidos en cada dimensión, muestra consejos personalizados cargados desde `assets/data/consejos_personalidad.json`.

#### Caso 4: Otras áreas con dimensiones

Para áreas distintas a Preferencias y Personalidad que tengan dimensiones, se muestran **barras de progreso** por dimensión, con:
- Nombre de la dimensión (izquierda) y nivel (derecha).
- Barra de progreso con color según el nivel:
  - 🔴 **Bajo** → rojo
  - 🟠 **Medio** → naranja
  - 🟢 **Alto** → verde
  - 🟩 **Muy Alto** → verde azulado

#### Caso 5: Área sin dimensiones (solo afinidades)

Muestra las 3 afinidades principales en filas con etiquetas de posición y color:
- 🟢 1° Afinidad Primaria (verde)
- 🔵 2° Afinidad Secundaria (azul)
- 🟠 3° Afinidad Terciaria (naranja)

**Barra inferior — Botón "VOLVER AL INICIO":**

Botón fijo en la parte inferior que cierra todas las pantallas y regresa directamente al Panel Principal (Inicio).

---

### 10.3 Resultados Generales (GlobalResultsScreen)

Accesible desde el menú lateral ("Resultados") o desde la tarjeta "Consultar resultados" del Inicio.

**Elementos:**

| Elemento | Descripción |
| :--- | :--- |
| **AppBar** | Título: "Resultados Generales". Con menú lateral. |
| **Resumen global** | Tarjeta con ícono de gráfico circular 🥧 y texto: *"Has completado X de Y áreas de evaluación."* |
| **Título de sección** | "Resumen por área (Último intento)" |
| **Tarjetas por área** | Una por cada área evaluada. Muestra el nombre del área y, si hay intentos, un widget de resumen. |

**Contenido de la tarjeta por área:**

| Estado | Qué muestra |
| :--- | :--- |
| **Sin intentos** | Texto: *"Aún no evaluado"* centrado en gris. |
| **Área Preferencias con intento** | Vista previa del **Podio** (PodiumWidget) con las 3 carreras top. |
| **Área Personalidad con intento** | Vista previa del **Gráfico de Radar** (PersonalityRadarChart). |

**Interacción:** Tocar cualquier tarjeta de área navega al **Historial de Resultados** de esa área (ResultScreen). Al regresar, los datos se recargan automáticamente.

---

## 11. MENÚ DE NAVEGACIÓN (APP DRAWER) — Detalle

### 11.1 Acerca de (AboutScreen)

Accesible desde el menú lateral. Muestra información institucional.

**Contenido:**

**Sección "¿Qué es el CEPRUNSA?"**

Texto descriptivo: *"El CEPRUNSA es el Centro Preuniversitario de la Universidad Nacional de San Agustín de Arequipa, encargado de brindar una preparación académica de calidad para los postulantes a las diversas carreras profesionales que ofrece la universidad."*

**Sección "Comisión:"**

Lista de miembros de la comisión con tarjetas que incluyen:
- Foto de perfil (imagen circular).
- Nombre completo.
- Cargo institucional.
- Ícono 🔗 que abre el perfil de LinkedIn de cada miembro en el navegador.

**Miembros listados:**

| Nombre | Cargo |
| :--- | :--- |
| Dra. Maria Elena Rojas Zegarra | Directora CEPRUNSA |
| Dr. Jose Miguel Rojas Hualpa | Coordinador Administrativo |
| Mg. Arnaldo Humberto Valdivia Loaiza | Coordinador Académico |

**Al final:** Logo oficial de CEPRUNSA (60px de alto).

---

## 12. FLUJO COMPLETO DE LA APLICACIÓN

El siguiente diagrama describe el flujo de navegación general:

```
Apertura de la app
      │
      ├── [Primera vez] → Onboarding (3 slides)
      │         └── [Siguiente/Omitir/Empezar] → Selección de Perfil
      │
      └── [No es primera vez] → Selección de Perfil
                │
                ├── [Sin perfiles] → Pantalla vacía → Crear Perfil → Inicio
                │
                ├── [Tocar perfil] → Inicio
                │       │
                │       ├── [Tour guiado - 1ª vez]
                │       ├── [Realizar evaluación] → Selección de Área
                │       │         │
                │       │         ├── [Tour guiado - 1ª vez]
                │       │         ├── [Iniciar/Continuar] → Quiz
                │       │         │       │
                │       │         │       ├── [Tour guiado - 1ª vez en Preferencias]
                │       │         │       ├── [Responder pregunta a pregunta]
                │       │         │       ├── [FINALIZAR] → Pantalla de procesamiento (3s)
                │       │         │       │       └── → Historial de área
                │       │         │       │               └── [Auto-abre detalle del intento]
                │       │         │       └── [Atrás del sistema] → Guarda borrador
                │       │         │
                │       │         └── [Ver resultados] → Historial del área
                │       │                   └── [Tocar intento] → Detalle del intento
                │       │                           └── [VOLVER AL INICIO] → Inicio
                │       │
                │       └── [Consultar resultados] → Resultados Generales
                │                 └── [Tocar área] → Historial del área
                │
                ├── [Menú lateral] → Inicio / Evaluaciones / Resultados / Acerca de / Cerrar sesión
                │
                └── [Cerrar sesión] → Selección de Perfil
```

---

## 13. COMPORTAMIENTOS ESPECIALES Y REGLAS DE NEGOCIO

### 13.1 Sistema de Intentos

- Cada área tiene un **número máximo de intentos** configurado en la aplicación.
- El badge de la tarjeta de área muestra cuántos intentos quedan.
- Un intento invalidado (test de Personalidad con ítem de control fallido) **no se cuenta** en el historial.
- Los intentos se ordenan de más reciente a más antiguo en el historial.

### 13.2 Borrador Automático (Draft)

- La aplicación guarda el progreso automáticamente en cada pregunta respondida.
- El borrador incluye las respuestas dadas hasta el momento y el índice de la última pregunta vista.
- Al retomar el test, las respuestas previas están pre-seleccionadas y el test continúa desde donde se dejó.
- Solo puede existir un borrador activo por área por perfil.

### 13.3 Sincronización con la Nube

- Al finalizar un test exitosamente, la aplicación intenta subir el resultado a **Firebase/Firestore**.
- La sincronización ocurre en segundo plano (no bloquea la interfaz).
- Al entrar al Inicio, también se sincronizan automáticamente resultados pendientes de subir.
- Al abrir el detalle de un intento, también se intenta sincronizar.

### 13.4 Perfil Indiferenciado (Preferencias)

Si todos los puntajes de las macro-áreas en el test de Preferencias son muy similares (diferencia máxima entre el puntaje más alto y el más bajo es menor a 4 puntos), la app muestra la advertencia de **"Perfil Indiferenciado"**, recomendando orientación vocacional personalizada.

### 13.5 Tour Interactivo

Existen tres tours en la aplicación, cada uno marcado en el perfil para no repetirse:

| Tour | Pantalla | Campo de control |
| :--- | :--- | :--- |
| Tour de Inicio | HomeScreen | `tourHomeShown` |
| Tour de Áreas | AreaSelectionScreen | `tourAreasShown` |
| Tour del Quiz | QuizScreen (solo Preferencias) | `tourQuizShown` |

---

## 14. REQUISITOS DEL SISTEMA

| Requisito | Especificación |
| :--- | :--- |
| **Sistema Operativo** | Android 9+ o iOS 13+ |
| **Memoria RAM** | Mínimo 2 GB |
| **Espacio en Disco** | Mínimo 50 MB libres |
| **Conexión a internet** | Opcional (requerida para sincronización con la nube) |
| **Framework** | Flutter (aplicación nativa multiplataforma) |

---

## 15. SOPORTE TÉCNICO

En caso de errores en la aplicación o dudas sobre los resultados:

| Contacto | Información |
| :--- | :--- |
| **Institución** | CEPRUNSA — Universidad Nacional de San Agustín de Arequipa |
| **Sitio web** | www.unsa.edu.pe |

> **Recomendación:** Si ocurre un error inesperado, adjunte una captura de pantalla al reportarlo. Describa los pasos que realizó antes de que ocurriera el error.
