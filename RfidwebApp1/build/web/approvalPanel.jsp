<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<title>Admin Approval Panel - Attendance Corrections</title>
<style>
  body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background-color: #f9fafc;
    margin: 20px;
    color: #2d3748;
  }
  h1 {
    color: #2a4365;
    margin-bottom: 20px;
    text-align: center;
  }
  table {
    border-collapse: collapse;
    width: 100%;
    max-width: 1200px;
    margin: auto;
    background: #fff;
    box-shadow: 0 0 15px rgba(0,0,0,0.1);
  }
  th, td {
    text-align: center;
    padding: 12px 15px;
    border-bottom: 1px solid #e2e8f0;
  }
  th {
    background-color: #2b6cb0;
    color: white;
    font-weight: 700;
  }
  tr:hover {
    background-color: #bee3f8;
  }
  form {
    margin: 0;
  }
  input[type="submit"] {
    background: #48bb78;
    border: none;
    color: white;
    padding: 8px 15px;
    margin: 2px;
    border-radius: 6px;
    font-weight: 600;
    cursor: pointer;
    transition: background 0.3s ease;
  }
  input[type="submit"].reject {
    background: #f56565;
  }
  input[type="submit"]:hover {
    filter: brightness(0.9);
  }
  caption {
    padding: 10px;
    font-size: 14px;
    color: #4a5568;
  }
</style>
</head>
<body>
  <h1>Pending Attendance Correction Requests</h1>

  <table>
    <thead>
      <tr>
        <th>ID</th><th>Attendance ID</th><th>Old Status</th><th>New Status</th><th>Requested By</th><th>Reason</th><th>Approve</th><th>Reject</th>
      </tr>
    </thead>
    <tbody>
      <%
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
          Class.forName("com.mysql.cj.jdbc.Driver");
          con = DriverManager.getConnection("jdbc:mysql://localhost:3306/rfid_system?useSSL=false&serverTimezone=Asia/Kolkata", "nikhil", "Nikhil@2004");
          ps = con.prepareStatement("SELECT * FROM attendance_corrections WHERE approved='PENDING' ORDER BY requested_at ASC");
          rs = ps.executeQuery();
          boolean hasRecords = false;
          while(rs.next()) {
            hasRecords = true;
      %>
      <tr>
        <td><%= rs.getInt("id") %></td>
        <td><%= rs.getInt("attendance_id") %></td>
        <td><%= rs.getString("old_status") %></td>
        <td><%= rs.getString("new_status") %></td>
        <td><%= rs.getString("requested_by") %></td>
        <td><%= rs.getString("reason") %></td>
        <td>
          <form method="post" action="ApproveCorrectionServlet">
            <input type="hidden" name="id" value="<%= rs.getInt("id") %>"/>
            <input type="submit" name="action" value="APPROVE" />
          </form>
        </td>
        <td>
          <form method="post" action="ApproveCorrectionServlet">
            <input type="hidden" name="id" value="<%= rs.getInt("id") %>"/>
            <input type="submit" name="action" value="REJECT" class="reject"/>
          </form>
        </td>
      </tr>
      <%
          }
          if(!hasRecords){
      %>
      <tr><td colspan="8" style="color:#718096; font-style:italic;">No pending correction requests.</td></tr>
      <%
          }
        } catch(Exception e) {
            out.println("<tr><td colspan=8 style='color:red;'>Error: " + e.getMessage() + "</td></tr>");
        } finally {
          if(rs!=null) rs.close();
          if(ps!=null) ps.close();
          if(con!=null) con.close();
        }
      %>
    </tbody>
    <caption>Approve or reject correction requests made by teachers.</caption>
  </table>
</body>
</html>
