<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Register RFID Card</title>
    <style>
        body { font-family: Arial, sans-serif; background: #f4f6f9; padding: 20px; }
        .form-box { max-width: 400px; margin: auto; padding: 20px; background: #fff; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.1); }
        h2 { text-align: center; color: #2c3e50; }
        label { display: block; margin-top: 10px; font-weight: bold; }
        input { width: 100%; padding: 8px; margin-top: 5px; border: 1px solid #ccc; border-radius: 5px; }
        button { margin-top: 15px; padding: 10px; width: 100%; background: #27ae60; color: white; border: none; border-radius: 5px; cursor: pointer; }
        button:hover { background: #219150; }
    </style>
</head>
<body>
  <div class="form-box">
    <h2>Register RFID Card</h2>

    <form action="registerCard" method="post">

        <!-- UID -->
        <label>Card UID</label>
        <input type="text" name="uid"
       value="<%= request.getParameter("uid") != null ? request.getParameter("uid") : "" %>"
       placeholder="Enter Card UID"
       required>
        <!-- Name -->
        <label>Employee Name</label>
        <input type="text" name="name" placeholder="Enter Employee Name" required>

        <!-- Email -->
        <label>Email Address</label>
        <input type="email" name="email" placeholder="Enter Email" required>

        <!-- Button -->
        <button type="submit">Register</button>

    </form>
</div>
</body>
</html>
