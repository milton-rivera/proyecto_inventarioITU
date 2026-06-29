
# Sistema INVENTARIO ITU 🚀

Este proyecto implementa una arquitectura empresarial híbrida y distribuida de tres capas (Multi-tier) para la gestión unificada de inventario de hardware y ubicación de activos informáticos. Combina el paradigma de microservicios contenerizados y orquestados nativos de la nube con servicios de infraestructura tradicionales alojados en servidores perimetrales locales (On-Premises).

El ecosistema destaca por la integración nativa de un backend Java Enterprise con persistencia políglota simultánea (Relacional y NoSQL) y seguridad de red interna bajo el principio de confianza cero (*Zero Trust*).

---

## 🗺️ Arquitectura del Sistema

La solución está diseñada para operar de forma segura interconectando múltiples entornos tecnológicos aislados a través de un firewall perimetral:

1.  **Capa de Presentación y Orquestación (Cloud Native / Kubernetes):** Alojada en un clúster de Kubernetes (`Minikube`), ejecuta el servidor de aplicaciones web y la base de datos documental con volúmenes persistentes.
2.  **Capa perimetral de Red (Firewall):** Un enrutador `pfSense` segmenta y protege el tráfico de red cruzado mediante políticas estrictas de filtrado de paquetes.
3.  **Capa de Servicios Core Institucionales (On-Premises / Virtual Machines):** Servidores Windows dedicados encargados del gobierno de datos relacionales y la gestión de identidades corporativas.

```text
       [ CLIENTE / NAVEGADOR WEB ]
                   │
                   ▼ (Puerto 8080/80)
┌────────────────────────────────────────────────────────┐
│               CLÚSTER DE KUBERNETES                    │
│                                                        │
│  ┌──────────────────────┐    NetworkPolicy (Bloqueo)   │
│  │   inventario-web     ├───────────────X──────────┐   │
│  │  (WildFly - Java EE) │                          │   │
│  └──────────┬───────────┘                          │   │
│             │                                      │   │
│             │ NetworkPolicy (Permitido: 27017)     │   │
│             ▼                                      ▼   │
│  ┌──────────────────────┐                     ┌────────┴────────┐
│  │    inventario-db     │                     │   POD ATACANTE  │
│  │     (MongoDB + PVC)  │                     │   (Malicioso)   │
│  └──────────┬───────────┘                     └─────────────────┘
│             │                                          │
└─────────────┼──────────────────────────────────────────┼───────
              │                                          │
              ▼ [ Tráfico Cruzado a Red Privada ]        │ (Bloqueado por
      ┌───────────────┐                                  │  NetworkPolicy)
      │   pfSense     │                                  │
      └───┬───────┬───┘                                  │
          │       │                                      │
 ┌────────┘       └────────┐                             │
 │                         │                             │
 ▼ (LDAP - Puerto 389)     ▼ (MSSQL - Puerto 1433)       X
┌──────────────────┐      ┌──────────────────┐
│     VM 1 - AD    │      │    VM 2 - SQL    │
│   (itu.local)    │      │   (ubicacion_db) │
└──────────────────┘      └──────────────────┘

```

🛠️ Tecnologías y Herramientas Utilizadas

    Runtime Backend: Java Server Pages (JSP) ejecutado sobre un servidor de aplicaciones corporativo JBoss WildFly.

    Base de Datos Relacional: Microsoft SQL Server Express encargado del almacenamiento estructurado y transaccional de ubicaciones.

    Base de Datos NoSQL: MongoDB 4.4 encargado de almacenar los esquemas dinámicos y detalles técnicos de hardware.

    Orquestador: Kubernetes / Minikube encargado de la resiliencia, escalabilidad y aislamiento de los microservicios.

    Seguridad y Autenticación: Active Directory (AD) mediante el protocolo LDAP para la gobernanza de usuarios y asignación de roles jerárquicos basados en grupos de seguridad.

    Seguridad de Red: pfSense como Firewall Perimetral físico/virtual y Kubernetes NetworkPolicies para el filtrado a nivel de Pod.

    Contenerización: Docker para la creación de imágenes inmutables de la capa lógica.

```text
📁 Estructura del Repositorio

proyecto_inventarioITU/
├── ROOT.war/                     # Directorio de la aplicación web (Exploded War)
│   ├── WEB-INF/
│   │   └── lib/
│   │       ├── mongo-java-driver-3.12.14.jar  # Driver NoSQL
│   │       └── mssql-jdbc-9.4.1.jre8.jar      # Driver Relacional JDBC
│   ├── index.html                # Frontend interactivo (HTML5/CSS3/JS)
│   ├── buscar.jsp                # API de consulta políglota combinada
│   ├── agregar.jsp               # API de inserción transaccional simultánea
│   ├── eliminar.jsp              # API de remoción lógica de activos
│   └── login.jsp                 # Módulo de autenticación real LDAP con AD
├── Dockerfile                    # Receta de empaquetado inmutable para WildFly
├── mongo-db.yaml                 # Manifiesto de MongoDB (Deployment, Service y PVC)
├── inventario-web-permanente.yaml # Manifiesto de la aplicación web Java EE
├── politicas-red.yaml            # Manifiestos de seguridad de red (Network Policies)
└── README.md                     # Documentación principal del sistema

```

```
🚀 Guía de Despliegue en Kubernetes

Siga este orden estricto para garantizar que los microservicios se enlacen correctamente:
1. Iniciar el Clúster Local

minikube start --cni=calico

2. Desplegar MongoDB con Almacenamiento Persistente

kubectl apply -f mongo-db.yaml

3. Construir la Imagen Inmutable de la Aplicación Web

# Apuntar la terminal al Docker de Minikube
eval $(minikube docker-env)

# Compilar la imagen inmutable v1
docker build -t fuanis-inventario:v1 .

4. Desplegar el Backend Java EE y Políticas de Red

kubectl apply -f inventario-web-permanente.yaml
kubectl apply -f politicas-red.yaml

```
🔒 Detalles de Seguridad Implementados
1. Principio de Menor Privilegio en Microservicios

Por defecto, las redes de Kubernetes permiten que todos los pods se comuniquen entre sí. Este proyecto mitiga vectores de ataque internos aplicando políticas de red (NetworkPolicy):

    Bloqueo por Defecto (Default Deny): Se deniega todo tráfico entrante no explícito en el espacio de nombres.

    Aislamiento de la Base de Datos: El pod inventario-db (MongoDB) rechaza cualquier paquete de red que no provenga explícitamente de la aplicación web. Un pod comprometido no puede extraer datos de la base documental.

2. Control de Acceso Basado en Roles (RBAC) dinámico por LDAP

La aplicación web delega la validación de identidad al Active Directory institucional. El backend procesa dinámicamente el atributo de objeto memberOf. Si la cadena contiene la firma del grupo privilegiado, la interfaz habilita operaciones de escritura; en caso contrario, restringe el acceso a modo de Solo Lectura.

---


## 🖥️ Topología y Configuración de Máquinas Virtuales (VMs)

La red está segmentada mediante **pfSense 2.8.1-RELEASE**, garantizando el aislamiento de servicios.

### 🌐 Segmentación de Redes (Interfaces pfSense)
*   **WAN (wan):** `192.168.1.11/24`
*   **SERVER (lan):** `192.168.10.1/24`
*   **CLIENT (opt1):** `192.168.2.254/24`

### ⚙️ Detalle de Nodos
| Servidor / Máquina Virtual | Rol | Dirección IP |
| :--- | :--- | :--- |
| **pfSense (Router)** | Puerta de Enlace | `192.168.1.11` (WAN) / `192.168.10.1` (LAN) |
| **VM 1: Windows Server (AD)** | Controlador de Dominio | `192.168.10.10` |
| **VM 2: Windows Server (SQL)** | Motor Relacional | `192.168.10.20` |
| **Nodo Ubuntu (Minikube)** | Orquestador | `192.168.1.x` (Segmento WAN) |

### 🛠️ Verificación de Conectividad
El proyecto garantiza el flujo de datos mediante peticiones cruzadas:
1. **Handshake LDAP:** El pod en `192.168.1.x` autentica contra `192.168.10.10` vía puerto `389`.
2. **Transacciones SQL:** El microservicio en Kubernetes realiza consultas JDBC hacia `192.168.10.20:1433`.

----
👥 Equipo de Desarrollo

    Milton Rivera 

    Luciano Papagni 

    Angelo Navarro

