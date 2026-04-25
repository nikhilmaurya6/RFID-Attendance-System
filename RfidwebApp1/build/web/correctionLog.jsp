<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<title>Attendance Correction Log</title>
<style>
  body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background: #f7fafc;
    margin: 30px;
    color: #2d3748;
  }
  h1 {
    color: #2c5282;
    text-align: center;
    margin-bottom: 20px;
  }
  table {
    width: 95%;
    margin: auto;
    border-collapse: collapse;
    background-color: white;
    box-shadow: 0 0 15px rgb(0 0 0 / 0.1);
  }
  th, td {
    border-bottom: 1px solid #e2e8f0;
    padding: 10px 15px;
    text-align: center;
  }
  th {
    background-color: #3182ce;
    color: white;
    font-weight: 700;
  }
  tbody tr:hover {
    background-color: #bee3f8;
  }
  caption {
    padding: 10px;
    font-style: italic;
    color: #4a5568;
  }
</style>
</head>
<body>
  <h1>Attendance Correction Log</h1>

  <table>
    <thead>
      <tr>
        <th>ID</th>
        <th>Correction ID</th>
        <th>Action</th>
        <th>Action By</th>
        <th>Action Time</th>
        <th>Comment</th>
      </tr>
    </thead>
    <tbody>
      <%
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
          Class.forName("com.mysql.cj.jdbc.Driver");
          con = DriverManager.getConnection("jdbc:mysql://localhost:3306/rfid_system?useSSL=false&serverTimezone=Asia/Kolkata","nikhil","Nikhil@2004");
          ps = con.prepareStatement("SELECT * FROM attendance_correction_log ORDER BY action_time DESC");
          rs = ps.executeQuery();
          boolean hasData = false;
          while(rs.next()){
            hasData = true;
      %>
      <tr>
        <td><%= rs.getLong("id") %></td>
        <td><%= rs.getInt("correction_id") %></td>
        <td><%= rs.getString("action") %></td>
        <td><%= rs.getString("action_by") %></td>
        <td><%= rs.getTimestamp("action_time") %></td>
        <td><%= rs.getString("comment") %></td>
      </tr>
      <%
          }
          if(!hasData){
      %>
      <tr><td colspan="6" style="font-style: italic; color: #718096;">No correction history found.</td></tr>
      <%
          }
        } catch(Exception e){
          out.println("<tr><td colspan='6' style='color:red;'>Error: " + e.getMessage() + "</td></tr>");
        } finally {
          if(rs!=null) rs.close();
          if(ps!=null) ps.close();
          if(con!=null) con.close();
        }
      %>
    </tbody>
    <caption>All past attendance correction activities and admin actions recorded here.</caption>
  </table>
</body>
</html>
