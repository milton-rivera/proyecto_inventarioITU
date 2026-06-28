<%@ page import="java.sql.*, com.mongodb.MongoClient, org.bson.Document" %>
<%@ page contentType="application/json;charset=UTF-8" %>
<%
    String id = request.getParameter("id");
    String aula = request.getParameter("aula");
    String banco = request.getParameter("banco");
    String maint = request.getParameter("maint");
    String resp = request.getParameter("resp");
    
    String equipo = request.getParameter("equipo");
    String cpu = request.getParameter("cpu");
    String ram = request.getParameter("ram");
    String disco = request.getParameter("disco");
    String so = request.getParameter("so");

    boolean sqlOk = false, mongoOk = false;
    String errorLog = "";

    try {
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        Connection con = DriverManager.getConnection("jdbc:sqlserver://192.168.10.20:1433;databaseName=ubicacion_db;user=sa;password=TuClaveSeguraSQL123;encrypt=false;");
        PreparedStatement ps = con.prepareStatement("INSERT INTO dbo.computadoras_ubicacion (id_maquina, aula_laboratorio, numero_banco, fecha_mantenimiento, responsable_tipo, nombre_responsable) VALUES (?, ?, ?, ?, 'Docente', ?)");
        ps.setInt(1, Integer.parseInt(id)); 
        ps.setString(2, aula);
        ps.setInt(3, Integer.parseInt(banco != null && !banco.isEmpty() ? banco : "0"));
        ps.setString(4, maint != null && !maint.isEmpty() ? maint : "2026-01-01");
        ps.setString(5, resp != null && !resp.isEmpty() ? resp : "N/A");
        ps.executeUpdate(); 
        con.close(); 
        sqlOk = true;
    } catch (Exception e) { errorLog += "SQL: " + e.getMessage().replace("\"", "'") + " "; }

    try {
        MongoClient mc = new MongoClient("mongodb", 27017);
        Document doc = new Document("id_maquina", Integer.parseInt(id))
                        .append("equipo", equipo != null && !equipo.isEmpty() ? equipo : "N/A")
                        .append("cpu", cpu != null && !cpu.isEmpty() ? cpu : "N/A")
                        .append("ram", ram != null && !ram.isEmpty() ? ram : "N/A")
                        .append("disco", disco != null && !disco.isEmpty() ? disco : "N/A")
                        .append("so", so != null && !so.isEmpty() ? so : "N/A");
        mc.getDatabase("hardware_db").getCollection("equipos").insertOne(doc); 
        mc.close(); 
        mongoOk = true;
    } catch (Exception e) { errorLog += "Mongo: " + e.getMessage().replace("\"", "'"); }

    if (sqlOk && mongoOk) out.print("{\"success\":true}"); else out.print("{\"success\":false,\"message\":\"" + errorLog + "\"}");
%>
