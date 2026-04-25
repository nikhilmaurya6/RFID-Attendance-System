<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<title>Attendance Correction Request</title>

<style>
  body {
    font-family: Arial, sans-serif;
    background: #f2f7ff;
    margin:0;
    padding:0;
    display:flex;
    justify-content:center;
    align-items:center;
    min-height:100vh;
  }
  .container {
    background: white;
    padding: 25px 40px;
    border-radius: 12px;
    box-shadow: 0 0 20px rgba(0,0,0,0.15);
    max-width: 500px;
    width: 100%;
  }
  h1 {
    margin-bottom: 20px;
    color: #2a3f7d;
    text-align:center;
  }
  label {
    display: block;
    margin-bottom: 6px;
    font-weight: bold;
    color: #3b4a86;
  }
  input, select, textarea {
    width: 100%;
    padding: 10px 12px;
    margin-bottom: 18px;
    border-radius: 6px;
    border: 1px solid #d1d9e6;
    font-size: 14px;
    box-sizing: border-box;
  }
  textarea { resize: vertical; }

  .submit-btn {
    background: #4a6fff;
    color: white;
    border:none;
    padding: 12px;
    font-size: 16px;
    border-radius: 6px;
    cursor: pointer;
    width:100%;
  }
  .submit-btn:hover { background: #3b57e0; }

  .readonly {
    background:#f1f5f9;
    color:#475569;
  }
</style>

<script>
function validateForm(){
  if(document.getElementById("new_status").value === ""){
    alert("Please select new status");
    return false;
  }
  if(document.getElementById("reason").value.trim() === ""){
    alert("Please enter reason");
    return false;
  }
  if(document.getElementById("requested_by").value.trim() === ""){
    alert("Please enter your email");
    return false;
  }
  return true;
}
</script>
</head>

<body>
<div class="container">
  <h1>Attendance Correction Request</h1>

  <!-- 🔥 IMPORTANT FORM -->
  <form method="post"
        action="SubmitCorrectionServlet"
        onsubmit="return validateForm();">

    <!-- 🔥 AUTO FILLED FROM DASHBOARD -->
    <input type="hidden" name="attendance_id"
           value="<%= request.getParameter("attendance_id") %>">

    <input type="hidden" name="old_status"
           value="<%= request.getParameter("old_status") %>">

    <!-- SHOW ONLY (READ-ONLY) -->
    <label>Attendance Record ID</label>
    <input type="text"
           class="readonly"
           value="<%= request.getParameter("attendance_id") %>"
           readonly>

    <label>Current Status</label>
    <input type="text"
           class="readonly"
           value="<%= request.getParameter("old_status") %>"
           readonly>

    <!-- USER INPUT -->
    <label>New Status</label>
    <select name="new_status" id="new_status" required>
      <option value="">Select status</option>
      <option value="PRESENT">PRESENT</option>
      <option value="ABSENT">ABSENT</option>
      <option value="LEAVE">LEAVE</option>
    </select>

    <label>Reason for Correction</label>
    <textarea name="reason" id="reason" rows="4"
              placeholder="Explain reason for correction"></textarea>

    <label>Your Email</label>
    <input type="email"
           name="requested_by"
           id="requested_by"
           placeholder="your@email.com"
           required>

    <input type="submit"
           class="submit-btn"
           value="Submit Correction Request">
  </form>
</div>
</body>
</html>
