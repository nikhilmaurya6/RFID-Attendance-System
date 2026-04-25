<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Login | RFID System</title>
  <style>
    body { font-family: 'Segoe UI', Arial, sans-serif; background: linear-gradient(135deg,#74ebd5,#ACB6E5); margin:0; padding:30px; }
    .card { max-width: 420px; margin: auto; background: #fff; border-radius: 12px; box-shadow: 0 10px 25px rgba(0,0,0,.15); overflow: hidden; }
    .header { padding: 18px; text-align: center; color:#2c3e50; font-weight: 600; font-size: 20px; }
    .tabs { display:flex; }
    .tabs button { flex:1; padding:12px; border:none; cursor:pointer; background:#ecf0f1; font-weight:600; }
    .tabs button.active { background:#3498db; color:#fff; }
    form { padding: 20px; }
    label { display:block; margin:10px 0 6px; font-weight:600; color:#34495e; }
    input { width:100%; padding:10px; border:1px solid #dcdde1; border-radius:6px; }
    .submit { margin-top:14px; background:#27ae60; color:#fff; border:none; padding:12px; width:100%; border-radius:8px; cursor:pointer; }
    .submit:hover { background:#1e8449; }
    .error { color:#e74c3c; margin: 8px 0; text-align:center; min-height: 18px; }
  </style>
</head>
<body>
<div class="card">
  <div class="header">RFID Attendance Login</div>
  <div class="tabs">
    <button type="button" id="tabAdmin" class="active" onclick="selectRole('ADMIN')">Admin</button>
    <button type="button" id="tabStudent" onclick="selectRole('STUDENT')">Employee</button>
  </div>
  <form action="login" method="post">
    <input type="hidden" name="role" id="role" value="ADMIN">
    <label>Username</label>
    <input type="text" name="username" required>
    <label>Password</label>
    <input type="password" name="password" required>
    <button class="submit" type="submit">Sign In</button>
    <div class="error"><%= request.getParameter("err") != null ? request.getParameter("err") : "" %></div>
  </form>
</div>
<script>
  function selectRole(r){
    document.getElementById('role').value = r;
    document.getElementById('tabAdmin').classList.toggle('active', r==='ADMIN');
    document.getElementById('tabStudent').classList.toggle('active', r!=='ADMIN');
  }
</script>
</body>
</html>
