<%@ page import="java.sql.*, com.mongodb.MongoClient, com.mongodb.client.*, org.bson.Document, com.mongodb.client.model.Filters" %>
<%@ page contentType="application/json;charset=UTF-8" %>
<%
    String idMaquina = request.getParameter("id");
    if (idMaquina == null || idMaquina.isEmpty()) { out.print("{\"success\":false,\"message\":\"ID vacío\"}"); return; }

    String aula = "Desconocido", banco = "0", maint = "N/A", resp = "N/A";
    String equipo = "Genérico NoSQL", cpu = "N/A", ram = "N/A", disco = "N/A", so = "N/A";
    boolean success = false;

    try {
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        Connection con = DriverManager.getConnection("jdbc:sqlserver://192.168.10.20:1433;databaseName=ubicacion_db;user=sa;password=TuClaveSeguraSQL123;encrypt=false;");
        PreparedStatement ps = con.prepareStatement("SELECT aula_laboratorio, numero_banco, fecha_mantenimiento, nombre_responsable FROM dbo.computadoras_ubicacion WHERE id_maquina = ?");
        ps.setInt(1, Integer.parseInt(idMaquina));
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            aula = rs.getString("aula_laboratorio"); banco = rs.getString("numero_banco"); maint = rs.getString("fecha_mantenimiento"); resp = rs.getString("nombre_responsable"); success = true;
        }
        con.close();
    } catch (Exception e) { aula = "Error SQL: " + e.getMessage().replace("\"", "'"); }

    try {
        MongoClient mc = new MongoClient("mongodb", 27017);
        Document doc = mc.getDatabase("hardware_db").getCollection("equipos").find(Filters.eq("id_maquina", Integer.parseInt(idMaquina))).first();
        if (doc != null) {
            equipo = doc.getString("equipo"); cpu = doc.getString("cpu"); ram = doc.getString("ram"); disco = doc.getString("disco"); so = doc.getString("so"); success = true;
        }
        mc.close();
    } catch (Exception e) { equipo = "Error Mongo: " + e.getMessage().replace("\"", "'"); }

    out.print("{");
    out.print("\"success\":" + success + ",");
    out.print("\"aula\":\"" + aula + "\",");
    out.print("\"banco\":\"" + banco + "\",");
    out.print("\"maint\":\"" + maint + "\",");
    out.print("\"resp\":\"" + resp + "\",");
    out.print("\"equipo\":\"" + equipo + "\",");
    out.print("\"cpu\":\"" + cpu + "\",");
    out.print("\"ram\":\"" + ram + "\",");
    out.print("\"disco\":\"" + disco + "\",");
    out.print("\"so\":\"" + so + "\"");
    out.print("}");
%>
