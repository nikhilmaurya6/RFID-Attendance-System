<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<title>Attendance Analytics</title>

<style>
*{box-sizing:border-box}
body{
  margin:0;padding:30px;
  font-family:Segoe UI,Arial;
  background:#eef1f7;color:#1f2937;
}
.dashboard{
  max-width:1200px;margin:auto;
  background:#fff;border-radius:16px;
  box-shadow:0 20px 40px rgba(0,0,0,.08);
  overflow:hidden;
}
.header{
  padding:22px 28px;
  background:linear-gradient(90deg,#1e3a8a,#2563eb);
  color:#fff;
}
.header h2{margin:0}
.header p{margin:6px 0 0;font-size:14px;opacity:.9}

/* MODE BUTTONS */
.modes{
  padding:16px 28px;
  background:#f8fafc;
  border-bottom:1px solid #e5e7eb;
}
.modes button{
  padding:8px 16px;
  border:none;
  border-radius:8px;
  margin-right:6px;
  cursor:pointer;
  background:#e5e7eb;
  font-weight:600;
}
.modes button.active{
  background:#2563eb;
  color:#fff;
}

/* FILTERS */
.filters{
  display:flex;gap:20px;
  padding:20px 28px;
  background:#f9fafb;
  border-bottom:1px solid #e5e7eb;
}
.filter-box{display:flex;flex-direction:column}
label{font-size:13px;color:#6b7280;margin-bottom:6px}
select{
  padding:10px 14px;
  border-radius:10px;
  border:1px solid #d1d5db;
  font-size:15px;
}

/* TABLE */
.table-wrap{padding:25px 28px 30px}
table{width:100%;border-collapse:collapse}
th,td{
  padding:14px;text-align:center;
  border-bottom:1px solid #e5e7eb;
}
th{background:#f1f5f9}
tr:hover{background:#f9fafb}

.empty{padding:35px;color:#6b7280}
</style>
</head>

<body>

<div class="dashboard">

  <div class="header" style="display:flex;justify-content:space-between;align-items:center;">
  <div>
    <h2>📊 Attendance Analytics</h2>
    <p>Daily • Weekly • Monthly • Yearly performance</p>
  </div>

  <!-- SAVE BUTTON -->
  <button onclick="saveSnapshot()"
    style="
      padding:10px 18px;
      background:#22c55e;
      color:white;
      border:none;
      border-radius:8px;
      font-weight:600;
      cursor:pointer;">
    💾 Save Report
  </button>
</div>


  <!-- MODE BUTTONS -->
  <div class="modes">
    <button id="daily"  onclick="setMode('daily')">Daily</button>
    <button id="week"   onclick="setMode('week')">Weekly</button>
    <button id="month"  onclick="setMode('month')">Monthly</button>
    <button id="year"   onclick="setMode('year')">Yearly</button>
  </div>

  <!-- FILTERS (UI ONLY – views ignore them) -->
  <div class="filters">
    <div class="filter-box">
      <label>Month</label>
      <select>
       <option value="01">January</option>
<option value="02">February</option>
<option value="03" selected>March</option>
<option value="04">April</option>
<option value="05">May</option>
<option value="06">June</option>
<option value="07">July</option>
<option value="08">August</option>
<option value="09">September</option>
<option value="10">October</option>
<option value="11">November</option>
<option value="12">December</option>
        
      </select>
    </div>

    <div class="filter-box">
      <label>Year</label>
      <select>
          <option>2025</option>
        <option selected>2026</option>
        <option>2027</option>
                <option>2028</option>

      </select>
    </div>
  </div>

  <!-- TABLE -->
  <div class="table-wrap">
    <table>
      <thead>
  <tr>
    <th>Sr No</th>
    <th>Employee ID</th>
    <th>Name</th>
    <th>Total Days</th>
    <th>Present Days</th>
    <th>Attendance %</th>
  </tr>
</thead>

      <tbody id="tbody">
        <tr><td colspan="6" class="empty">Loading...</td></tr>
      </tbody>
    </table>
  </div>

</div>

<script>
let mode = "";

function setMode(m){
  mode = m;
  console.log("MODE =", mode);

  document.querySelectorAll(".modes button")
    .forEach(b=>b.classList.remove("active"));
  document.getElementById(m).classList.add("active");

  loadReport();
}

async function loadReport(){
  const res = await fetch(
  "<%= request.getContextPath() %>/studentReport"
);

  const data = await res.json();

  console.log("DATA =", data);

  const tbody = document.getElementById("tbody");
  tbody.innerHTML = "";

  if(!data || data.length === 0){
    tbody.innerHTML =
      "<tr><td colspan='4' class='empty'>No data found</td></tr>";
    return;
  }

 data.forEach(r=>{
  tbody.innerHTML +=
    "<tr>" +
      "<td>" + r.sr_no + "</td>" +
      "<td>" + r.uid + "</td>" +
      "<td>" + r.name + "</td>" +
      "<td>" + r.total_days + "</td>" +
      "<td>" + r.present_days + "</td>" +
      "<td>" + r.percentage + "%</td>" +
    "</tr>";
});

}

/* INITIAL LOAD */
window.addEventListener("DOMContentLoaded", () => {
  setMode("week"); // default view
});

//snapshot
async function saveSnapshot(){
  if(!confirm("Do you want to save this report snapshot?")) return;

  const res = await fetch(
    "<%= request.getContextPath() %>/saveSnapshot",
    { method: "POST" }
  );

  const msg = await res.text();
  alert(msg);
}
</script>

</body>
</html>
<!<!--rifidweb1 ke report 3+me save ho rha -->
