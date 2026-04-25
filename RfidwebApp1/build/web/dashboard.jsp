<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" isELIgnored="true" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>RFID Attendance Dashboard</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="color-scheme" content="dark light">
  <style>
    /* --- keep your existing CSS, below only small additions --- */
    :root{
      --bg-grad: linear-gradient(135deg,#74ebd5,#ACB6E5);
      --blue-1:#2f7dff; --blue-2:#5fa8ff;
      --green-1:#24b26b; --green-2:#35d07f;
      --gray-1:#555; --shadow:0 8px 20px rgba(0,0,0,0.15);
      --card-bg:rgba(255,255,255,0.95);
      --text:#2c3e50; --muted:#7f8c8d; --table-even:#f8f9fa; --table-hover:#eafaf1;
      --thead-grad: linear-gradient(90deg,#4CAF50,#2ecc71);
      --btn-danger-grad: linear-gradient(90deg,#e74c3c,#c0392b);
    }
    @media (prefers-color-scheme: dark) {
      :root {
        --bg-grad: linear-gradient(135deg,#1f2937,#111827);
        --card-bg: rgba(31,41,55,0.9);
        --text:#e5e7eb; --muted:#9ca3af;
        --table-even:#111827; --table-hover:#0f172a;
        --thead-grad: linear-gradient(90deg,#059669,#0ea5e9);
        --shadow: 0 8px 20px rgba(0,0,0,0.6);
      }
    }
    .dark {
      --bg-grad: linear-gradient(135deg,#1f2937,#111827);
      --card-bg: rgba(31,41,55,0.9);
      --text:#e5e7eb; --muted:#9ca3af;
      --table-even:#111827; --table-hover:#0f172a;
      --thead-grad: linear-gradient(90deg,#059669,#0ea5e9);
      --shadow: 0 8px 20px rgba(0,0,0,0.6);
    }
    body { font-family:'Segoe UI',Arial,sans-serif; background:var(--bg-grad); margin:0; padding:20px; color:var(--text); }
    .layout { display:grid; grid-template-columns:240px 1fr; gap:18px; align-items:start; }
    .sidebar { position:sticky; top:12px; z-index:5; display:flex; flex-direction:column; gap:12px; }
    .sidebar a { text-decoration:none; }
.btn { 
  width: 100%;          /* 👈 sab same width */
  height: 50px;         /* 👈 sab same height */
  padding: 0;           /* padding remove */
  border:none; 
  border-radius:10px; 
  color:#fff; 
  font-weight:700; 
  font-size:16px;       /* 👈 same text size */
  cursor:pointer; 
  display:flex; 
  align-items:center; 
  justify-content:center; 
  gap:8px; 
  box-shadow:0 6px 14px rgba(0,0,0,.12); 
  transition:.12s ease; 
}    .btn:hover { transform:translateY(-1px); filter:brightness(1.03); }
    .btn:active { transform:translateY(0); box-shadow:0 4px 10px rgba(0,0,0,.16) inset; }
    .register-btn { background:linear-gradient(90deg,var(--blue-2),var(--blue-1)); }
    .export-btn   { background:linear-gradient(90deg,var(--green-2),var(--green-1)); }
    .logout       { background:linear-gradient(90deg,#7a7f86,#4e545b); }
    .refresh      { background:linear-gradient(90deg,#9b59b6,#8e44ad); }
    .today-only   { background:linear-gradient(90deg,#f59e0b,#d97706); }
    .today-on     { box-shadow:0 0 0 3px rgba(245,158,11,.35); }
    .dark-toggle  { background:linear-gradient(90deg,#374151,#111827); }
    .card { background:var(--card-bg); border-radius:12px; box-shadow: var(--shadow); padding:22px; }
    h2 { color:var(--text); margin:0 0 10px; text-align:center; }
    .note { font-size:0.9em; color:var(--muted); margin-bottom:18px; text-align:center; }
    .stats { display:flex; gap:10px; flex-wrap:wrap; margin-bottom:10px; align-items:center; }
    .stat-card { background:#ffffff20; backdrop-filter: blur(2px); border-radius:10px; padding:10px 12px; box-shadow:0 3px 8px rgba(0,0,0,.08); font-weight:600; color:var(--text); }
    .muted { color:var(--muted); font-weight:500; }
    .toolbar-row { display:flex; justify-content:space-between; align-items:center; gap:12px; margin-bottom:12px; flex-wrap:wrap; }
    .left-tools { display:flex; align-items:center; gap:12px; flex-wrap:wrap; }
    .search-box { display:flex; align-items:center; gap:8px; background:#fff; color:#111; padding:8px 12px; border-radius:8px; box-shadow:0 4px 10px rgba(0,0,0,.08); }
    .dark .search-box { background:#111827; color:#e5e7eb; }
    .search-box input { border:none; outline:none; min-width:220px; font-size:14px; color:inherit; background:transparent; }
    .pill { background:#eef6ff; color:#1f4b99; padding:8px 12px; border-radius:999px; font-weight:600; }
    .dark .pill { background:#0f172a; color:#93c5fd; }
    .pager { display:flex; align-items:center; gap:10px; }
    .pager button, .pager select { padding:8px 12px; border-radius:8px; border:1px solid #d6e0ff; background:#fff; cursor:pointer; box-shadow:0 2px 6px rgba(0,0,0,.06); }
    .dark .pager button, .dark .pager select { background:#0b1220; color:#e5e7eb; border-color:#334155; }
    table { border-collapse:collapse; width:100%; background:#fff; border-radius:10px; overflow:hidden; }
    .dark table { background:#0b1220; }
    th,td { padding:14px 18px; text-align:center; }
    th { background:var(--thead-grad); color:#fff; font-size:15px; }
    td { font-size:14px; color:var(--text); }
    tr:nth-child(even){ background-color:var(--table-even); }
    tr:hover { background-color:var(--table-hover); transition:0.3s; }
    .action-btn { padding:6px 12px; background:var(--btn-danger-grad); color:#fff; border:none; border-radius:4px; cursor:pointer; }
    .timer { font-weight:700; }
    .status-badge { font-weight:700; padding:6px 10px; border-radius:8px; display:inline-block; }
    .status-pending { background: #fff6ea; color: #b45309; }
    .status-present { background: #ecfdf5; color: #15803d; }
    .status-absent  { background: #fff1f2; color: #b91c1c; }
  </style>
</head>
<body>
<div class="layout">
  <div class="sidebar">
    <a href="registerCard.jsp"><button class="btn register-btn">➕ Register New Card</button></a>
    <a href="exportCsv"><button class="btn export-btn">📂 Export All CSV</button></a>
    <a href="reports.jsp"><button class="btn">📈 Reports</button></a>
    <button class="btn export-btn" id="dlFiltered">⬇️ Download Filtered CSV</button>
    <c:if test="${sessionScope.role == 'ADMIN'}">
    <a href="assignTask.jsp">
        <button class="btn">📝 Assign Daily Task</button>
    </a>
</c:if>

<!--<c:if test="${sessionScope.role == 'EMPLOYEE'}">
    <a href="employeeTasks.jsp">
        <button class="btn">📌 My Tasks</button>
    </a>
</c:if>--->
    <button class="btn refresh" id="refreshNow">🔄 Refresh Now</button>
    <button class="btn today-only" id="toggleToday">📅 Today Only: OFF</button>
    <button class="btn dark-toggle" id="toggleDark">🌓 Theme</button>
    <a href="logout"><button class="btn logout">Logout</button></a>
    
  </div>

  <div class="card">
    <h2>📊 RFID BASED ATTENDANCE</h2>
    <div class="note">Attendance records update automatically every 3 seconds. Scan a card to start its 6-hour timer; after 6 hours it will be marked PRESENT.</div>

    <div class="stats" aria-live="polite">
      <div class="stat-card">Total <span id="statTotal">0</span> <span class="muted">records</span></div>
      <div class="stat-card">Today <span id="statToday">0</span></div>
      <div class="stat-card">Total employee Present:<span id="statUnique">0</span></div>
      <div class="pill">Now <span id="nowDate">--</span> <span id="nowTime">--</span> IST</div>
      <div class="pill">Baseline <span id="baseDate">--</span></div>
    </div>

    <div class="toolbar-row">
      <div class="left-tools">
        <div class="search-box">
          <span>🔎</span>
          <input id="q" type="text" placeholder="Search by UID, name, or time...">
          <button class="pill" onclick="clearSearch()">Clear</button>
        </div>
      </div>
      <div class="pager">
        <label class="muted">Rows:</label>
        <select id="pageSize"><option>5</option><option selected>10</option><option>20</option><option>50</option></select>
        <button onclick="prevPage()">Prev</button>
        <span class="muted" id="pageInfo">1/1</span>
        <button onclick="nextPage()">Next</button>
      </div>
    </div>

    <table>
      <thead>
        <tr>
          <th>Serial No</th>
          <th>Employee ID</th>
          <th>Name</th>
          <th>Session Start</th>
          <th>Time In</th>
          <th>Status</th>
          <th>Timer</th>
          <th>Action</th>
        </tr>
      </thead>
      <tbody id="attendanceBody"></tbody>
    </table>

    <%@ page import="java.sql.*" %>
<%
String role = (String) session.getAttribute("role");

int pendingCorrectionCount = 0;
try (
    Connection con = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/rfid_system?useSSL=false&serverTimezone=Asia/Kolkata",
        "nikhil",
        "Nikhil@2004"
    );
    PreparedStatement ps = con.prepareStatement(
        "SELECT COUNT(*) FROM attendance_corrections WHERE approved='PENDING'"
    );
    ResultSet rs = ps.executeQuery()
) {
    if (rs.next()) {
        pendingCorrectionCount = rs.getInt(1);
    }
} catch (Exception e) {
    pendingCorrectionCount = -1;
}
%>

<div style="text-align:center; margin-top: 18px;">
  <div style="display:inline-block; width:100%; max-width:760px; text-align:left; margin:auto;">

    <% if("ADMIN".equalsIgnoreCase(role)) { %>

    <div style="padding:14px; border-radius:10px; background:#dbeeff; border:2px solid var(--blue-1); margin-top:18px;">
      
      <h3 style="margin:0 0 8px;">🛠️ Attendance Correction Requests</h3>

      <p style="margin:0 0 12px; font-weight:600; color:<%= (pendingCorrectionCount > 0) ? "#d93838" : "#24b26b" %>;">
        <%
          if (pendingCorrectionCount == -1) {
              out.print("Error loading data");
          } else {
              out.print(pendingCorrectionCount + " Pending Approval");
          }
        %>
      </p>

      <div>
        <% if (pendingCorrectionCount > 0) { %>
          <a href="approvalPanel.jsp"
             style="font-weight: 600; color: var(--blue-1); text-decoration: underline;">
             View Approval Panel ➔
          </a>
        <% } else { %>
          <span style="color: var(--muted); font-style: italic;">
            No pending attendance corrections.
          </span>
        <% } %>
      </div>

    </div>

    <% } %>   <!-- ✅ IMPORTANT CLOSE -->

  </div>
</div>

<script>
/* ================= IST CLOCK ================= */
const IST_ZONE = 'Asia/Kolkata';
const LOPT = { timeZone: IST_ZONE, hour12:false, year:'numeric', month:'2-digit', day:'2-digit',
               hour:'2-digit', minute:'2-digit', second:'2-digit' };

function getISTDateObj(){
  try{
    const s = new Date().toLocaleString('en-IN', LOPT);
    const [dmy,hms]=s.split(', ');
    const [dd,mm,yyyy]=dmy.split('/');
    return new Date(`${yyyy}-${mm}-${dd}T${hms}`);
  }catch{
    return new Date(Date.now()+19800000);
  }
}
const p2=n=>String(n).padStart(2,'0');

function tickISTNow(){
  const d=getISTDateObj();
  nowDate.textContent=`${d.getFullYear()}-${p2(d.getMonth()+1)}-${p2(d.getDate())}`;
  nowTime.textContent=`${p2(d.getHours())}:${p2(d.getMinutes())}:${p2(d.getSeconds())}`;
}
tickISTNow(); setInterval(tickISTNow,1000);

/* ================= STATE ================= */
let ALL_ROWS=[];
let FILTERED=[];
let todayOnly = false;
localStorage.setItem("todayOnly","false");

/* ================= DATE FILTER ================= */
function baselineDate(){
  // Always use TODAY for "Today Only" filter
  const d = getISTDateObj();
  return `${d.getFullYear()}-${p2(d.getMonth()+1)}-${p2(d.getDate())}`;
}
function dayRange(base){
  const [y,m,d]=base.split('-').map(Number);
  const n=new Date(y,m-1,d+1);
  return {start:`${base} 00:00:00`,
          end:`${n.getFullYear()}-${p2(n.getMonth()+1)}-${p2(n.getDate())} 00:00:00`};
}
function applyTodayOnly(rows){
  if(!todayOnly) return rows;
  const {start,end}=dayRange(baselineDate());
  return rows.filter(r=>{
    const t=r.time_in||r.session_start||"";
    if(!t) return true;
    return t>=start && t<end;
  });
}

/* ================= RENDER TABLE ================= */
function renderPage() {
  const tbody = document.getElementById("attendanceBody");
  tbody.innerHTML = "";

  FILTERED.forEach((r, i) => {

    // ✅ STATUS TEXT & COLOR
    let statusText = "⏳ PENDING";
    let statusColor = "#b45309";

    if (r.status === "PRESENT") {
      statusText = "✔ PRESENT";
      statusColor = "#16a34a";
    } else if (r.status === "ABSENT") {
      statusText = "✖ ABSENT";
      statusColor = "#dc2626";
    }

    tbody.innerHTML += `
      <tr>
        <td>${i + 1}</td>
        <td>${r.uid || ""}</td>
        <td>${r.name || ""}</td>
        <td>${r.session_start || ""}</td>
        <td>${r.time_in || ""}</td>

        <!-- STATUS -->
        <td>
          <span class="status"
                style="font-weight:700;color:${statusColor}"
                data-start="${r.session_start || ""}"
                data-stop="${r.time_in || ""}">
            ${statusText}
          </span>
        </td>

        <!-- TIMER -->
        <td>
          <span class="timer"
                data-start="${r.session_start || ""}"
                data-stop="${r.time_in || ""}">
          </span>
        </td>

        <!-- ACTIONS -->
        <td>

          <!-- DELETE -->
          <form method="post" action="deleteCard"
                onsubmit="return confirm('Delete this record?')">
            <input type="hidden" name="id" value="${r.id}">
            <input type="submit" class="action-btn" value="Delete">
          </form>

          <!-- REQUEST CORRECTION -->
          <form method="get" action="correctionRequest.jsp" style="margin-top:6px;">
            <input type="hidden" name="attendance_id" value="${r.id}">
            <input type="hidden" name="old_status" value="${r.status}">
            <input type="submit"
                   value="Request Correction"
                   style="background:#2563eb;color:white;border:none;
                          padding:6px 10px;border-radius:4px;cursor:pointer;">
          </form>

        </td>
      </tr>
    `;
  });
}

/* ================= TIMER ================= */
function updateTimers() {

  const nowMs = getISTDateObj().getTime();
  const requiredMs = 6 * 60 * 60 * 1000;

  document.querySelectorAll(".timer").forEach(el => {

    const startStr = el.dataset.start;
    const stopStr  = el.dataset.stop;

    const statusEl = el.closest("tr").querySelector(".status");

    if (!startStr) {
      el.textContent = "--";
      return;
    }

    const startMs = new Date(startStr.replace(" ", "T")).getTime();

    /* ========= SECOND SCAN (STOP) ========= */
    if (stopStr) {
      const stopMs = new Date(stopStr.replace(" ", "T")).getTime();

      if (stopMs > startMs) {
        const diff = stopMs - startMs;

        const hrs  = Math.floor(diff / 3600000);
        const mins = Math.floor((diff % 3600000) / 60000);
        const secs = Math.floor((diff % 60000) / 1000);

        el.textContent = `✔ Stopped (${hrs}h ${mins}m ${secs}s)`;
        el.style.color = "#16a34a";

        if (diff >= requiredMs) {
          statusEl.textContent = "✔ PRESENT";
          statusEl.style.color = "#16a34a";
        } else {
          statusEl.textContent = "✖ ABSENT";
          statusEl.style.color = "#dc2626";
        }
        return;
      }
    }

    /* ========= RUNNING TIMER ========= */
    const remainingMs = requiredMs - (nowMs - startMs);

    if (remainingMs <= 0) {
      el.textContent = "✔ Completed (6h)";
      el.style.color = "#16a34a";

      statusEl.textContent = "✔ PRESENT";
      statusEl.style.color = "#16a34a";
    } else {
      const hrs  = Math.floor(remainingMs / 3600000);
      const mins = Math.floor((remainingMs % 3600000) / 60000);
      const secs = Math.floor((remainingMs % 60000) / 1000);

      el.textContent = `${hrs}h ${mins}m ${secs}s`;
      el.style.color = "#b45309";

      statusEl.textContent = "⏳ PENDING";
      statusEl.style.color = "#b45309";
    }
  });
}

setInterval(updateTimers, 1000);
/* ================= STATS ================= */
function updateStats(rows) {

  // Total records
  document.getElementById("statTotal").textContent = rows.length;

  // Today date (IST)
  const now = getISTDateObj();
  const today =
    now.getFullYear() + "-" +
    String(now.getMonth()+1).padStart(2,'0') + "-" +
    String(now.getDate()).padStart(2,'0');

  let todayCount = 0;
  let presentSet = new Set();

  rows.forEach(r => {

    const time = r.session_start || "";

    // Today count
    if (time.startsWith(today)) {
      todayCount++;
    }

    // Unique present
    if (r.status === "PRESENT") {
      presentSet.add(r.uid);
    }

  });

  document.getElementById("statToday").textContent = todayCount;
  document.getElementById("statUnique").textContent = presentSet.size;
}
function applySearch() {

  const q = document.getElementById("q").value.toLowerCase();

  FILTERED = ALL_ROWS.filter(r => {

    const uid  = (r.uid || "").toLowerCase();
    const name = (r.name || "").toLowerCase();
    const time = (r.session_start || "").toLowerCase();

    return uid.includes(q) || name.includes(q) || time.includes(q);
  });

  renderPage();
  updateTimers();
}
document.getElementById("q").addEventListener("input", applySearch);
function clearSearch(){
  document.getElementById("q").value = "";
  FILTERED = ALL_ROWS;
  renderPage();
  updateTimers();
  updateStats(FILTERED);
}
/* ================= FETCH ================= */
async function fetchAttendance(){
  const res=await fetch("attendance",{cache:"no-store"});
  ALL_ROWS=await res.json();
  FILTERED=todayOnly?applyTodayOnly(ALL_ROWS):ALL_ROWS;
  renderPage(); updateTimers();updateStats(FILTERED);
}
fetchAttendance(); setInterval(fetchAttendance,3000);

/* ================= THEME ================= */
if(localStorage.getItem("theme")==="dark")
  document.documentElement.classList.add("dark");

toggleDark.addEventListener("click",()=>{
  document.documentElement.classList.toggle("dark");
  localStorage.setItem("theme",
    document.documentElement.classList.contains("dark")?"dark":"light");
});

/* ================= TODAY BUTTON ================= */
function syncTodayButton(){
  toggleToday.textContent=`📅 Today Only: ${todayOnly?"ON":"OFF"}`;
  toggleToday.classList.toggle("today-on",todayOnly);
}
syncTodayButton();

toggleToday.addEventListener("click",()=>{
  todayOnly=!todayOnly;
  localStorage.setItem("todayOnly",JSON.stringify(todayOnly));
  syncTodayButton();
  FILTERED=todayOnly?applyTodayOnly(ALL_ROWS):ALL_ROWS;
  renderPage();
});

/* ================= REFRESH ================= */
refreshNow.addEventListener("click",fetchAttendance);

/* ================= DOWNLOAD CSV ================= */
dlFiltered.addEventListener("click",()=>{
  if(!FILTERED.length) return alert("No data");
  const csv=[["UID","Name","Start","TimeIn"],
    ...FILTERED.map(r=>[r.uid,r.name,r.session_start,r.time_in])]
    .map(r=>r.join(",")).join("\n");
  const a=document.createElement("a");
  a.href=URL.createObjectURL(new Blob([csv],{type:"text/csv"}));
  a.download="attendance.csv";
  a.click();
});
</script>

</body>
</html>
