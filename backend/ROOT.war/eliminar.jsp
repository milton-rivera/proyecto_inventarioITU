<%@ page import="java.sql.*, com.mongodb.MongoClient, com.mongodb.client.model.Filters" %><%@ page contentType="application/json;charset=UTF-8" %><%
    String id = request.getParameter("id");

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
        PreparedStatement ps = con.prepareStatement("DELETE FROM dbo.computadoras_ubicacion WHERE id_maquina=?"); 
        ps.setInt(1, Integer.parseInt(id)); 
        ps.executeUpdate(); 
        con.close();
        
        MongoClient mc = new MongoClient(mongoHost, 27017); 
        mc.getDatabase("hardware_db").getCollection("equipos").deleteOne(Filters.eq("id_maquina", Integer.parseInt(id))); 
        mc.close(); 
        
        out.print("{\"success\":true}"); 
    } catch (Exception e) { 
        out.print("{\"success\":false}"); 
    }
%>