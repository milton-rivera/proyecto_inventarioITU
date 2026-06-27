# Informe del Backend: Lógica de Aplicación

El backend actúa como un **orquestador de servicios** desplegado sobre el servidor **JBoss WildFly**. Su función principal es unificar la gestión de activos informáticos mediante tres pilares:

## 1. Integración Políglota (Data Access Layer)
El backend implementa una capa de acceso a datos capaz de consultar dos fuentes simultáneas:
* **Conector JDBC (SQL Server):** Utiliza el driver `mssql-jdbc-9.4.1.jre8.jar` para realizar operaciones transaccionales (CRUD) sobre `ubicacion_db`[cite: 1].
* **Driver NoSQL (MongoDB):** Utiliza `mongo-java-driver-3.12.14.jar` para operaciones sobre colecciones de hardware dinámico en `hardware_db`[cite: 1].
* **Coordinación:** El backend abre ambos canales de comunicación bajo demanda en los JSPs de consulta (`buscar.jsp`), consolidando los resultados en un objeto JSON unificado antes de enviarlo al cliente[cite: 1].

## 2. Autenticación y Seguridad
La lógica de seguridad sigue un flujo de **"Confianza Cero"**:
* **LDAP Bind:** En `login.jsp`, el backend realiza un `InitialDirContext` hacia el Active Directory (`192.168.10.10:389`) para verificar las credenciales[cite: 1].
* **RBAC Dinámico:** Tras el logueo, el servidor analiza el atributo `memberOf` del usuario. Si el usuario pertenece al grupo `CN=Admins`, el backend habilita en la sesión los privilegios para ejecutar sentencias de escritura (INSERT/DELETE)[cite: 1].

## 3. Despliegue Inmutable
El backend se empaqueta mediante un `Dockerfile` que:
1. Toma una imagen base de **WildFly**[cite: 1].
2. Inyecta el artefacto `ROOT.war` (tu aplicación web)[cite: 1].
3. Configura los permisos del sistema de archivos `jboss:jboss` para garantizar la ejecución segura en entornos Linux/Kubernetes[cite: 1].
