<%@ page import="java.sql.*, com.mongodb.MongoClient, com.mongodb.client.model.Filters" %><%@ page contentType="application/json;charset=UTF-8" %><%
    String id = request.getParameter("id");
    try { Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver"); Connection con = DriverManager.getConnection("jdbc:sqlserver://192.168.10.20:1433;databaseName=ubicacion_db;user=sa;password=TuClaveSeguraSQL123;encrypt=false;"); PreparedStatement ps = con.prepareStatement("DELETE FROM dbo.computadoras_ubicacion WHERE id_maquina=?"); ps.setInt(1, Integer.parseInt(id)); ps.executeUpdate(); con.close();
    MongoClient mc = new MongoClient("MONGO_IP_PLACEHOLDER", 27017); mc.getDatabase("hardware_db").getCollection("equipos").deleteOne(Filters.eq("id_maquina", Integer.parseInt(id))); mc.close(); out.print("{\"success\":true}"); } catch (Exception e) { out.print("{\"success\":false}"); }
%>
