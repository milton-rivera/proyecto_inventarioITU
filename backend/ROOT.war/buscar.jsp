<%@ page import="java.sql.*, com.mongodb.MongoClient, com.mongodb.client.*, org.bson.Document, com.mongodb.client.model.Filters" %><%@ page contentType="application/json;charset=UTF-8" %><%
    String idMaquina = request.getParameter("id");
    if (idMaquina == null || idMaquina.isEmpty()) { out.print("{\"success\":false}"); return; }
    
    String aula = "N/A", banco = "N/A", maint = "N/A", resp = "N/A", equipo = "N/A", cpu = "N/A", ram = "N/A", disco = "N/A", so = "N/A";
    boolean success = false;

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
        PreparedStatement ps = con.prepareStatement("SELECT aula_laboratorio, numero_banco, fecha_mantenimiento, nombre_responsable FROM dbo.computadoras_ubicacion WHERE id_maquina = ?"); 
        ps.setInt(1, Integer.parseInt(idMaquina)); 
        ResultSet rs = ps.executeQuery();
        if (rs.next()) { 
            aula = rs.getString("aula_laboratorio"); 
            banco = rs.getString("numero_banco"); 
            maint = rs.getString("fecha_mantenimiento"); 
            resp = rs.getString("nombre_responsable"); 
            success = true; 
        } 
        con.close();
    } catch (Exception e) {}
    
    try { 
        MongoClient mc = new MongoClient(mongoHost, 27017);
        Document doc = mc.getDatabase("hardware_db").getCollection("equipos").find(Filters.eq("id_maquina", Integer.parseInt(idMaquina))).first(); 
        if (doc != null) { 
            equipo = doc.getString("equipo"); 
            cpu = doc.getString("cpu"); 
            ram = doc.getString("ram");
            disco = doc.getString("disco"); 
            so = doc.getString("so"); 
            success = true; 
        } 
        mc.close();
    } catch (Exception e) {}
    
    out.print("{\"success\":" + success + ",\"aula\":\"" + aula + "\",\"banco\":\"" + banco + "\",\"maint\":\"" + maint + "\",\"resp\":\"" + resp + "\",\"equipo\":\"" + equipo + "\",\"cpu\":\"" + cpu + "\",\"ram\":\"" + ram + "\",\"disco\":\"" + disco + "\",\"so\":\"" + so + "\"}");
%>