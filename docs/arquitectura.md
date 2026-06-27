# Informe Técnico: Arquitectura de Datos y Seguridad

## 1. Persistencia de Datos
El proyecto implementa una arquitectura de persistencia políglota para optimizar el almacenamiento según la naturaleza de la información:

### 1.1 Persistencia Relacional (SQL Server)
* **Objetivo:** Gestión transaccional de ubicaciones físicas y activos.
* **Implementación:** Alojada en una máquina virtual externa (VM 2). Se estableció una tabla `computadoras_ubicacion` con restricciones de integridad referencial para asegurar la trazabilidad de los equipos.
* **Seguridad:** El motor SQL Server fue configurado en modo de autenticación mixto, permitiendo conexiones JDBC seguras mediante el driver `mssql-jdbc` desde el contenedor Java EE.

### 1.2 Persistencia NoSQL (MongoDB)
* **Objetivo:** Almacenamiento de esquemas técnicos flexibles y dinámicos (Hardware).
* **Contenerización y Persistencia:** El motor de MongoDB corre dentro de un pod de Kubernetes. Para evitar la pérdida de datos ante la naturaleza efímera de los contenedores, se implementó un **PersistentVolumeClaim (PVC)**. Esto vincula el almacenamiento del pod a un volumen persistente en el host, garantizando la durabilidad de la información técnica del hardware.

---

## 2. Estrategia de Seguridad y Menor Privilegio

La seguridad se aborda mediante una estrategia de defensa en profundidad distribuida en tres niveles:

### 2.1 Aislamiento de red (Network Policies)
Se aplicó el principio de *Zero Trust* dentro del clúster de Kubernetes:
* **Default Deny:** Todo el tráfico intraclúster está bloqueado por defecto.
* **Permisos Granulares:** Se habilitó una política específica que permite al pod de la aplicación (`inventario-web`) comunicarse con `inventario-db` exclusivamente por el puerto `27017`. Cualquier otro intento de conexión es rechazado por el firewall interno del clúster.

### 2.2 Autenticación y RBAC (Active Directory)
La gestión de identidades centralizada utiliza el protocolo LDAP:
* El sistema solicita validación contra el AD institucional (`192.168.10.10:389`).
* La aplicación procesa dinámicamente el grupo de seguridad `memberOf` del usuario. Si el usuario pertenece a `Admins`, la interfaz web se desbloquea para operaciones de escritura (ABM); de lo contrario, el usuario queda confinado a un modo de solo consulta.

### 2.3 Segmentación Perimetral (pfSense)
El tráfico entre el clúster (LAN 1) y los servidores de base de datos (LAN 2) es filtrado por pfSense. Solo el tráfico origen verificado tiene permitida la comunicación hacia los puertos de escucha de SQL Server (`1433`) y AD (`389`), minimizando la superficie de ataque.
