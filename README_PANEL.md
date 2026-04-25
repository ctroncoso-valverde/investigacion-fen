# Dashboard de Investigación FEN UNAB
## Manual completo para el administrador

Este documento explica desde cero cómo funciona el sistema, qué archivos existen, cómo actualizar los datos y cómo gestionar los accesos. Está escrito para que cualquier persona que tome el rol de administrador pueda operar el sistema sin conocimiento previo.

---

## 1. Qué es este sistema

El sistema consiste en dos páginas web alojadas en GitHub Pages (el servicio gratuito de GitHub para hospedar sitios estáticos):

| URL | Descripción |
|-----|-------------|
| `https://ctroncoso-valverde.github.io/investigacion-fen/` | Dashboard de producción académica FEN UNAB 2020–2026. Solo accesible con RUT autorizado. |
| `https://ctroncoso-valverde.github.io/investigacion-fen/panel_investigacion.html` | Panel de administración. |

Ambos son archivos HTML estáticos — no hay servidor, no hay base de datos, no hay backend. Todo el procesamiento ocurre en el navegador del usuario. Los datos están **encriptados dentro del propio HTML** con AES-256-GCM.

El código fuente y los archivos viven en el repositorio privado de GitHub: `ctroncoso-valverde/investigacion-fen`. Ese repositorio está clonado localmente en:

```
~/Documents/Repositorio/Investigacion-FEN/
```

---

## 2. Archivos del repositorio

### Los que se publican en GitHub Pages (los únicos que suben a GitHub)

| Archivo | Descripción |
|---------|-------------|
| `index.html` | El dashboard. Contiene los datos de 48 académicos y 234 papers encriptados en vaults AES-256-GCM. Cada usuario autorizado tiene su propio vault. Pesa ~1 MB. |
| `panel_investigacion.html` | El panel de administración. Tiene un único vault encriptado para el administrador. |
| `update_dashboard.command` | Script bash que hace el despliegue automático (backup + reemplazo + git push). Ejecutable con doble-clic en Finder. |
| `.gitignore` | Lista de archivos que Git ignora (no sube a GitHub). |

### Los que solo existen localmente (de trabajo, no van a GitHub)

| Archivo | Descripción |
|---------|-------------|
| `AJG2024_by_discipline.xlsx` | Catálogo Academic Journal Guide 2024. 1.822 revistas con rating ABS (1–4*). Se usa para clasificar papers. |
| `ABSRanking2024_Fulllist.xlsx` | Referencia complementaria de ratings ABS. |
| `Diagnostico_Investigacion_FEN.xlsx` | Excel del diagnóstico con 6 hojas (resumen, FODA, top contributors, sub-disciplinas, coherencia, metodología). |
| `Diagnostico_Produccion_Academica_FEN_2026.docx` | Informe Word completo del diagnóstico. |
| `Faculty_FEN_papers.xlsx` | Vista de papers por académico. |
| `Incorporaciones_FEN.rtf` | Lista de nuevas incorporaciones 2026. |

Los archivos fuente que alimentan el dashboard (CSV y XLS con los datos reales) viven en otra carpeta del Repositorio, fuera de esta carpeta:

| Archivo | Ubicación |
|---------|-----------|
| `Faculty_FEN.xlsx` | `~/Documents/Repositorio/Faculty_FEN.xlsx` |
| `evidencias.csv` | `~/Documents/Repositorio/AACSB/evidencias.csv` |
| `academicos.csv` | `~/Documents/Repositorio/AACSB/academicos.csv` |
| `PredatoryJournals.xlsx` | `~/Documents/Repositorio/AACSB/PredatoryJournals.xlsx` |

---

## 3. Cómo funciona el dashboard

### El universo de 48 académicos

El dashboard analiza la producción 2020–2026 de los académicos FEN. El universo se construye así:

```
Faculty_FEN.xlsx (74 personas en nómina FEN 2026)
    +
Académicos con código WI-MM* en academicos.csv (14 nuevas incorporaciones 2026)
= 88 personas en total

→ De ellas, 48 tienen al menos 1 paper aprobado en el período 2020–2026
  (las demás quedan fuera por no tener producción registrada)
```

### Los 5 archivos fuente

El dashboard se construye a partir de cinco archivos. Si alguno cambia (nuevos papers, nuevos académicos, nueva nómina), hay que regenerar el dashboard.

| Archivo | Qué aporta |
|---------|------------|
| `Faculty_FEN.xlsx` | Define QUIÉN pertenece al universo (nómina completa FEN) |
| `evidencias.csv` | Define QUÉ se publicó (todos los papers por RUT) |
| `academicos.csv` | Asigna la disciplina interna a cada académico (ECON_GP, ADM_NI_INN, CON_FIN_TRI, AD_MKT_TUR) |
| `PredatoryJournals.xlsx` | Lista de 1.734 revistas predatorias para clasificar papers |
| `AJG2024_by_discipline.xlsx` | Ratings ABS de 1.822 revistas para clasificar papers |

### Cómo se filtran los papers

De `evidencias.csv` solo se cuentan las filas que cumplan **todas** estas condiciones:
- `codigo = pub_paper`
- `estado = aprobada`
- `anio_publicacion` entre 2020 y 2026 (inclusive)
- El RUT pertenece al universo de 88 personas

### Criterios de clasificación

| Métrica | Criterio |
|---------|----------|
| **Paper de alto impacto ★** | ABS 2024 ≥ 3 (AJG) **Y** Q1 o Q2 JCR. Ambas condiciones simultáneas. |
| **En ABS Business** | Cualquier rating ABS ≥ 1 en el AJG 2024 |
| **Predatoria** | Match exacto en `PredatoryJournals.xlsx` + Sustainability (MDPI) que se trata como predatoria aunque no aparece en la lista |

### Sub-disciplinas

Cada académico tiene asignada una sub-disciplina (Labour Economics, Tourism & Hospitality, Accounting & Auditing, etc.) que representa su línea investigadora principal.

Esta clasificación se hizo usando dos fuentes externas:
- **Para ADM_NI_INN, CON_FIN_TRI, AD_MKT_TUR:** catálogo VHB Rating 2024 (asociación alemana de profesores de administración). Asigna códigos de comisión a cada revista (TIE, BA-FI, RECH, MARK, DLM, etc.) que determinan la sub-disciplina.
- **Para ECON_GP:** taxonomía JEL de la American Economic Association. La letra del código JEL determina el área (J→Labour Economics, L/D→Industrial Organization, H→Public Economics & Policy, etc.).

Las sub-disciplinas están **almacenadas** en el vault encriptado del dashboard. No se recomputan automáticamente — se preservan para los académicos existentes. Si se agrega un académico nuevo, hay que asignarle la sub-disciplina manualmente.

### Métricas actuales (versión desplegada, abril 2026)

| Métrica | Valor |
|---------|-------|
| Académicos | 48 |
| Papers 2020–2026 | 234 |
| Alto impacto (ABS ≥ 3 AND Q1/Q2) | 36 (15,4%) |
| En ABS Business | 96 (41,0%) |
| Predatorias | 27 (11,5%) |

---

## 4. Cómo funciona la seguridad

### Encriptación

Los datos del dashboard (los 48 académicos con sus papers) están encriptados con **AES-256-GCM**. La clave de encriptación se deriva del RUT del usuario usando **PBKDF2** con 100.000 iteraciones y SHA-256. Sin el RUT correcto, es matemáticamente imposible leer los datos.

### Vaults

Cada usuario autorizado tiene su propio **vault** (bloque encriptado) dentro del `index.html`. Los vaults se identifican por el hash SHA-256 del RUT — así el código sabe qué vault corresponde al usuario sin revelar los RUTs en el código.

```
Flujo de acceso:
Usuario escribe su RUT
→ JavaScript hashea el RUT con SHA-256
→ Busca ese hash en la lista de vaults
→ Si existe: deriva la clave con PBKDF2 y desencripta
→ Si no existe: "RUT no autorizado"
```

### Usuarios autorizados (16 en total, abril 2026)

| Nombre | RUT |
|--------|-----|
| Juan Pablo Torres (Decano) | 15637190-4 |
| Cristián Troncoso | 12963640-8 |
| Mauricio Donoso | 7813721-5 |
| Andrés Tolosa | 12251408-0 |
| María Elena Arzola | 13434206-4 |
| Roberto Carvajal | 10602973-3 |
| Mary-Ann Cooper | 15098716-4 |
| Luciana Mitjavila | 23146826-9 |
| Nicolás Garrido | 21821504-1 |
| Freddy Coronado | 12484626-9 |
| Luis Felipe Vergara | 10797459-8 |
| María Pía Monreal | 9572813-8 |
| Florencia Flen | 18638522-5 |
| Patricio Aroca | 8144337-8 |
| Jesús Juyumaya | 16105835-1 |
| Carlos Alsúa | 24036773-4 |

---

## 5. Panel de administración

### Cómo acceder

Abre en el navegador:
```
https://ctroncoso-valverde.github.io/investigacion-fen/panel_investigacion.html
```

La pantalla de login es **idéntica** a la del dashboard — no hay ninguna pista visible de que existe un modo admin. Ingresa el RUT del administrador seguido de `_adm`:

```
12963640-8_adm
```

Cualquier otro RUT con `_adm` es rechazado. El sufijo `_adm` no tiene efecto para nadie más.

### Qué puedes hacer desde el panel

**Sección 1 — Gestión de accesos:** ver, agregar y eliminar usuarios autorizados. Los cambios se aplican cuando generas los nuevos archivos.

**Sección 2 — Actualizar datos:** subir los 5 archivos fuente actualizados. En cuanto están todos cargados, el panel calcula los nuevos KPIs y los compara con los actuales.

**Sección 3 — Generar y desplegar:** un botón que hace todo el trabajo:
1. Descarga el `index.html` actual desde GitHub Pages
2. Re-encripta los vaults para todos los usuarios del roster actualizado
3. Genera un nuevo `index.html` con los datos y/o accesos actualizados
4. Descarga el `panel_investigacion.html` actual y actualiza su propio vault (roster + fecha)
5. Los dos archivos llegan a `~/Downloads`

---

## 6. Cómo desplegar una actualización

Después de que el panel haya descargado los archivos nuevos a `~/Downloads`, tienes dos opciones para subirlos a GitHub:

### Opción A — doble-clic en Finder (recomendado)

Abre Finder → navega a `Documentos / Repositorio / Investigacion-FEN` → doble-clic en `update_dashboard.command`.

Se abre una ventana de Terminal y el script hace todo solo:

1. Detecta si hay `index.html` y/o `panel_investigacion.html` en `~/Downloads`
2. Guarda backup de los actuales en la carpeta `_backups/` con timestamp
3. Reemplaza los archivos
4. Muestra el resumen de cambios
5. Pregunta `¿Confirmas el push? [y/N]` — escribe `y` y Enter
6. Hace el commit y el push a GitHub

### Opción B — desde Terminal

```bash
cd ~/Documents/Repositorio/Investigacion-FEN
./update_dashboard.command
```

### Después del push

GitHub Pages tarda 1–2 minutos en publicar los cambios. Para verificar que funcionó, abre el dashboard en una ventana de incógnito e intenta entrar con un RUT autorizado.

Si algo salió mal, los archivos anteriores están en `_backups/` con timestamp y puedes restaurarlos manualmente.

---

## 7. Operaciones comunes paso a paso

### Agregar un nuevo usuario autorizado

1. Abre el panel en el navegador e ingresa con `12963640-8_adm`
2. En la sección "Gestión de accesos", escribe el nombre y RUT de la persona nueva
3. Clic en "＋ Agregar"
4. Verifica que aparece en la tabla
5. Ve a la sección "Generar y desplegar" → clic en "Generar nuevos archivos"
6. Espera a que lleguen los archivos a `~/Downloads`
7. Ejecuta `update_dashboard.command`
8. La persona ya puede acceder al dashboard con su RUT

### Eliminar un usuario autorizado

1. Abre el panel e ingresa con `_adm`
2. En la tabla de accesos, clic en "Eliminar" en la fila de esa persona
3. Confirma cuando pregunte
4. Genera y despliega (igual que arriba)
5. El próximo `index.html` ya no tendrá el vault de esa persona — no podrá entrar

### Actualizar datos (nuevos papers, nuevos académicos)

1. Asegúrate de tener actualizados los 5 archivos fuente en sus ubicaciones habituales:
   - `~/Documents/Repositorio/Faculty_FEN.xlsx`
   - `~/Documents/Repositorio/AACSB/evidencias.csv`
   - `~/Documents/Repositorio/AACSB/academicos.csv`
   - `~/Documents/Repositorio/AACSB/PredatoryJournals.xlsx`
   - `~/Documents/Repositorio/Investigacion-FEN/AJG2024_by_discipline.xlsx`
2. Abre el panel e ingresa con `_adm`
3. En la sección "Actualizar datos", sube los 5 archivos
4. Revisa la vista previa de KPIs — verifica que los números tienen sentido
5. Genera y despliega

**Nota importante:** si hay académicos nuevos (personas que no estaban en la versión anterior del dashboard), aparecerán sin sub-disciplina asignada. Antes de generar, contacta a quien tenga conocimiento del área para asignarles la sub-disciplina correcta. La sub-disciplina refleja la línea investigadora de la persona, no solo las revistas donde publica.

---

## 8. Estructura técnica del repositorio

```
Investigacion-FEN/               ← Repositorio git (GitHub Pages)
├── index.html                   ← Dashboard (se publica en GitHub Pages)
├── panel_investigacion.html     ← Panel admin (se publica en GitHub Pages)
├── update_dashboard.command     ← Script de despliegue
├── .gitignore                   ← Archivos excluidos del repo
├── README_PANEL.md              ← Este archivo
│
├── AJG2024_by_discipline.xlsx   ← [solo local] Ratings ABS
├── ABSRanking2024_Fulllist.xlsx ← [solo local] Referencia ABS
├── Diagnostico_Investigacion_FEN.xlsx  ← [solo local]
├── Diagnostico_Produccion_Academica_FEN_2026.docx  ← [solo local]
├── Faculty_FEN_papers.xlsx      ← [solo local]
├── Incorporaciones_FEN.rtf      ← [solo local]
│
└── _backups/                    ← Versiones anteriores (creada automáticamente)
    ├── index_YYYYMMDD_HHMMSS.html
    └── panel_YYYYMMDD_HHMMSS.html
```

Los archivos marcados como `[solo local]` están en `.gitignore` y nunca se suben a GitHub. Solo los primeros cuatro archivos son visibles públicamente en GitHub Pages (aunque los datos del dashboard están encriptados).

---

## 9. Qué hacer si algo sale mal

### "RUT no autorizado" al intentar entrar al panel

Verifica que estás escribiendo exactamente `12963640-8_adm` — con guión antes del dígito verificador, sin puntos, y con el sufijo `_adm` al final. El campo es sensible a mayúsculas: el dígito verificador `K` debe ir en minúscula (`k`).

### El panel no genera los archivos

El panel descarga el `index.html` actual desde GitHub Pages mediante `fetch`. Si GitHub Pages está caído o el archivo tardó en actualizarse, el fetch puede fallar. Espera 2–3 minutos y vuelve a intentar.

### El script `update_dashboard.command` no encuentra los archivos

El script busca los archivos en `~/Downloads/`. Si el navegador los descargó en otra carpeta, muévelos manualmente a `~/Downloads/` antes de ejecutar el script.

### Quiero volver a una versión anterior del dashboard

Los backups se guardan automáticamente en `_backups/` con timestamp. Para restaurar:

```bash
cd ~/Documents/Repositorio/Investigacion-FEN
cp _backups/index_YYYYMMDD_HHMMSS.html index.html
git add index.html
git commit -m "Restaurar versión anterior"
git push origin main
```

### Perdí acceso al panel (no recuerdo el RUT admin)

El RUT del administrador es `12963640-8`. El acceso al panel usa ese RUT seguido de `_adm`. Si se necesita cambiar el administrador, hay que regenerar el panel desde un chat con Claude en el proyecto `iSER AACSB`, decrifrando uno de los vaults actuales y creando uno nuevo para el nuevo RUT admin.

---

## 10. Contexto del proyecto

El dashboard fue construido en marzo 2026 como parte del proceso de diagnóstico de producción académica FEN UNAB para el proceso iSER AACSB. El diagnóstico cubre el período AY2020–AY2026 y analiza a los 48 académicos con producción registrada en evidencias.csv durante ese período.

Los documentos completos del diagnóstico (informe Word, Excel, metodología) están en esta misma carpeta localmente y no se publican en GitHub.

Para cualquier modificación técnica más allá de lo descrito en este manual (cambiar la lógica de clasificación, agregar nuevas métricas, rediseñar el dashboard), abrir un chat en el proyecto `iSER AACSB` en Claude. El historial completo del proceso de construcción está disponible ahí.
