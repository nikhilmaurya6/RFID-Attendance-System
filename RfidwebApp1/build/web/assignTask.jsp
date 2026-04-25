<%@ page contentType="text/html;charset=UTF-8" language="java" session="true" %>
<%
    String role = (String) session.getAttribute("role");
    if(role == null || !role.equals("ADMIN")){
        response.sendRedirect("login.jsp");
        return;
    }

    String msg = request.getParameter("msg");
    String error = request.getParameter("error");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Assign Daily Task</title>

<style>
body{
    font-family: 'Segoe UI', Arial, sans-serif;
    background: linear-gradient(135deg,#74ebd5,#ACB6E5);
    margin:0;
    padding:40px;
}

.container{
    max-width:600px;
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

label{
    font-weight:600;
    display:block;
    margin-top:15px;
}

input[type="text"], textarea{
    width:100%;
    padding:10px;
    border-radius:8px;
    border:1px solid #ccc;
    margin-top:5px;
    font-size:14px;
}

textarea{
    resize:vertical;
    min-height:100px;
}

button{
    margin-top:20px;
    padding:12px;
    width:100%;
    border:none;
    border-radius:8px;
    background:linear-gradient(90deg,#2f7dff,#5fa8ff);
    color:white;
    font-weight:700;
    cursor:pointer;
    font-size:15px;
    transition:0.2s;
}

button:hover{
    transform:translateY(-2px);
    opacity:0.95;
}

.msg{
    padding:10px;
    border-radius:8px;
    margin-bottom:15px;
    font-weight:600;
}

.success{
    background:#ecfdf5;
    color:#15803d;
}

.error{
    background:#fff1f2;
    color:#b91c1c;
}

.back-btn{
    display:inline-block;
    margin-top:15px;
    text-decoration:none;
    color:#2f7dff;
    font-weight:600;
}
</style>

</head>
<body>

<div class="container">

<h2>📝 Assign Daily Task</h2>

<% if(msg != null){ %>
    <div class="msg success"><%= msg %></div>
<% } %>

<% if(error != null){ %>
    <div class="msg error"><%= error %></div>
<% } %>

<form action="AssignTaskServlet" method="post">

    <label>Employee UID</label>
    <input type="text" name="uid" required placeholder="Enter Employee UID">

    <label>Task Title</label>
    <input type="text" name="title" required placeholder="Enter Task Title">

    <label>Task Description</label>
    <textarea name="description" required placeholder="Enter Task Description"></textarea>

    <button type="submit">Assign Task</button>

</form>

<a href="dashboard.jsp" class="back-btn">⬅ Back to Dashboard</a>

</div>

</body>
</html>