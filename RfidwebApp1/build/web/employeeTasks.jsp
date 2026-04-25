<%@ page contentType="text/html;charset=UTF-8" language="java" session="true" %>
<%@ page import="java.sql.*" %>

<%
    String role = (String) session.getAttribute("role");
    String uid = (String) session.getAttribute("uid");

    if(role == null || !"EMPLOYEE".equals(role)){
        response.sendRedirect("login.jsp");
        return;
    }

    if(uid == null){
        response.sendRedirect("login.jsp");
        return;
    }

    Class.forName("com.mysql.cj.jdbc.Driver");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>My Tasks</title>

<style>
body{
    font-family: 'Segoe UI', Arial, sans-serif;
    background: linear-gradient(135deg,#74ebd5,#ACB6E5);
    margin:0;
    padding:40px;
}

.container{
    max-width:900px;
    margin:auto;
    background:white;
    padding:30px;
    border-radius:12px;
    box-shadow:0 8px 20px rgba(0,0,0,0.2);
}

h2{
    text-align:center;
    margin-bottom:25px;
    color:#2c3e50;
}

table{
    width:100%;
    border-collapse:collapse;
}

th, td{
    padding:12px;
    text-align:center;
}

th{
    background:#2f7dff;
    color:white;
}

tr:nth-child(even){
    background:#f8f9fa;
}

.status{
    padding:6px 12px;
    border-radius:8px;
    font-weight:600;
}

.pending{
    background:#fff6ea;
    color:#b45309;
}

.completed{
    background:#ecfdf5;
    color:#15803d;
}

button{
    padding:8px 12px;
    border:none;
    border-radius:6px;
    cursor:pointer;
    background:#16a34a;
    color:white;
    font-weight:600;
}

button:hover{
    opacity:0.9;
}

.no-data{
    text-align:center;
    padding:20px;
    font-style:italic;
    color:#555;
}

.back{
    display:inline-block;
    margin-top:20px;
    text-decoration:none;
    font-weight:600;
    color:#2f7dff;
}
</style>

</head>
<body>

<div class="container">

<h2>📌 My Assigned Tasks</h2>

<table>
<tr>
<th>Title</th>
<th>Description</th>
<th>Assigned Date</th>
<th>Status</th>
<th>Action</th>
</tr>

<%
boolean hasData = false;

try(Connection conn = DriverManager.getConnection(
"jdbc:mysql://localhost:3306/rfid_system?useSSL=false&serverTimezone=Asia/Kolkata",
"nikhil","Nikhil@2004")){

PreparedStatement ps = conn.prepareStatement(
"SELECT * FROM tasks WHERE uid=? ORDER BY assigned_date DESC");
ps.setString(1, uid);
ResultSet rs = ps.executeQuery();

while(rs.next()){
hasData = true;
String status = rs.getString("status");
%>

<tr>
<td><%= rs.getString("title") %></td>
<td><%= rs.getString("description") %></td>
<td><%= rs.getDate("assigned_date") %></td>
<td>
    <% if("PENDING".equals(status)){ %>
        <span class="status pending">PENDING</span>
    <% } else { %>
        <span class="status completed">COMPLETED</span>
    <% } %>
</td>
<td>
<% if("PENDING".equals(status)){ %>
    <form action="CompleteTaskServlet" method="post">
        <input type="hidden" name="id" value="<%= rs.getInt("id") %>">
        <button type="submit">Mark Complete</button>
    </form>
<% } else { %>
    ✔
<% } %>
</td>
</tr>

<%
}

if(!hasData){
%>
<tr>
<td colspan="5" class="no-data">No tasks assigned yet.</td>
</tr>
<%
}
}
%>

</table>

<a href="dashboard.jsp" class="back">⬅ Back to Dashboard</a>

</div>

</body>
</html>