# 🧾 Proyecto PL/SQL: Gestión Integral de Empleados  

**Autor:** Miguel Alonso Solís Cunza (23200338)  
**Curso:** Base de Datos II  
**Universidad Nacional Mayor de San Marcos**  
**Facultad:** Ingeniería de Sistemas e Informática  

---

## 📘 Descripción General  

Este proyecto implementa un **sistema de gestión integral de empleados** utilizando **Oracle PL/SQL**, que permite administrar la información del personal, sus cargos, salarios, horarios y asistencias.  

Incluye un **paquete principal (`PKG_EMPLOYEE`)** con operaciones CRUD, y varios **disparadores (triggers)** que garantizan el cumplimiento de las reglas de negocio relacionadas con los empleados, su salario y su asistencia.  

---

## 🧩 Estructura del Proyecto  

### 🗂️ 1. Paquete `PKG_EMPLOYEE`

Este paquete contiene procedimientos y funciones para la **administración completa de empleados**.  

| Tipo | Nombre | Descripción |
|------|---------|-------------|
| **Procedimiento** | `crear_empleado` | Inserta un nuevo empleado en la base de datos. |
| **Procedimiento** | `read_employee` | Muestra la información básica de un empleado. |
| **Procedimiento** | `update_employee` | Actualiza datos principales o salario de un empleado. |
| **Procedimiento** | `delete_employee` | Elimina un empleado del sistema. |
| **Función** | `resumen_contrataciones` | Calcula el promedio de contrataciones mensuales. |
| **Procedimiento** | `mostrar_empleados_mas_rotados` | Muestra los empleados con más cambios de puesto. |
| **Procedimiento** | `gastos_salarios_regionales` | Calcula el gasto salarial total por región. |
| **Función** | `calcular_vacaciones` | Determina los días de vacaciones según el tiempo de servicio. |

---

## ⚙️ 2. Triggers Implementados  

### 🔹 **3.2 – Verificación de Asistencia**

Este trigger se ejecuta **antes de registrar la asistencia** de un empleado.  
Verifica que:  
- El **día de la asistencia** coincida con el día de su horario laboral.  
- La **hora de inicio y fin** correspondan exactamente con las horas asignadas al empleado.  

Si alguna condición no se cumple, **se impide la inserción** de la asistencia.  

---

### 🔹 **3.3 – Validación de Sueldo por Puesto**

Este trigger se activa **al insertar o actualizar un salario** en la tabla de empleados.  
Su función es **garantizar que el sueldo esté dentro del rango permitido** para el puesto (`JOB_ID`) definido en la tabla `JOBS`.  

Si el salario está fuera del rango (menor que el mínimo o mayor que el máximo), **la operación se cancela automáticamente** y se muestra un mensaje de error.  

---

### 🔹 **3.4 – Control de Ingreso (±30 Minutos)**

Este trigger restringe el **registro de ingreso** de los empleados.  
Permite marcar asistencia **solo dentro de los 30 minutos antes o después** de la hora exacta de ingreso establecida en su horario.  

Si el registro se realiza fuera de ese rango, el sistema **marca automáticamente “INASISTENCIA”**, sin notificar al empleado, asegurando un control interno discreto y automatizado.  

