<%@ page import="java.sql.*, com.mongodb.MongoClient, org.bson.Document" %><%@ page contentType="application/json;charset=UTF-8" %><%
    String id = request.getParameter("id"), aula = request.getParameter("aula"), banco = request.getParameter("banco"), maint = request.getParameter("maint"), resp = request.getParameter("resp"), equipo = request.getParameter("equipo"), cpu = request.getParameter("cpu"), ram = request.getParameter("ram"), disco = request.getParameter("disco"), so = request.getParameter("so");
    boolean sqlOk = false, mongoOk = false;

    // Inyección de variables de entorno para SQL Server
    String sqlHost = System.getenv("SQL_HOST") != null ? System.getenv("SQL_HOST") : "192.168.10.20";
    String sqlUser = System.getenv("SQL_USER") != null ? System.getenv("SQL_USER") : "sa";
    String sqlPass = System.getenv("SQL_PASS") != null ? System.getenv("SQL_PASS") : "TuClaveSeguraSQL123";
    String dbUrl = "jdbc:sqlserver://" + sqlHost + ":1433;databaseName=ubicacion_db;user=" + sqlUser + ";password=" + sqlPass + ";encrypt=false;";

    // Inyección de variables de entorno para MongoDB
    String mongoHost = System.getenv("MONGO_HOST") != null ? System.getenv("MONGO_HOST") : "127.0.0.1";

    try { 
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver"); 
        Connection con = DriverManager.getConnection(dbUrl);
        PreparedStatement ps = con.prepareStatement("INSERT INTO dbo.computadoras_ubicacion (id_maquina, aula_laboratorio, numero_banco, fecha_mantenimiento, responsable_tipo, nombre_responsable) VALUES (?, ?, ?, ?, 'Docente', ?)");
        ps.setInt(1, Integer.parseInt(id)); 
        ps.setString(2, aula); 
        ps.setInt(3, Integer.parseInt(banco != null && !banco.isEmpty() ? banco : "0"));
        ps.setString(4, maint != null && !maint.isEmpty() ? maint : "2026-01-01"); 
        ps.setString(5, resp != null && !resp.isEmpty() ? resp : "N/A");
        ps.executeUpdate(); 
        con.close(); 
        sqlOk = true; 
    } catch (Exception e) { }
    
    try { 
        MongoClient mc = new MongoClient(mongoHost, 27017);
        Document doc = new Document("id_maquina", Integer.parseInt(id)).append("equipo", equipo).append("cpu", cpu).append("ram", ram).append("disco", disco).append("so", so); 
        mc.getDatabase("hardware_db").getCollection("equipos").insertOne(doc); 
        mc.close(); 
        mongoOk = true;
    } catch (Exception e) { }
    
    if (sqlOk && mongoOk) out.print("{\"success\":true}"); else out.print("{\"success\":false}");
%>