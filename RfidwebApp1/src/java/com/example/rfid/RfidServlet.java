package com.example.rfid;

import com.example.util.EmailUtil;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/rfid")
public class RfidServlet extends HttpServlet {

    private static final String URL =
        "jdbc:mysql://localhost:3306/rfid_system?useSSL=false&serverTimezone=Asia/Kolkata";
    private static final String USER = "nikhil";
    private static final String PASS = "Nikhil@2004";
    private static final String API_SECRET = "RFID_SECRET_123";

    private static final int REQUIRED_HOURS = 6;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/plain;charset=UTF-8");

        // ✅ API KEY CHECK
        if (!API_SECRET.equals(request.getHeader("X-API-Key"))) {
            response.sendError(401, "Invalid key");
            return;
        }

        String uid = request.getParameter("uid");
        if (uid == null || uid.isEmpty()) {
            response.sendError(400, "UID missing");
            return;
        }
        uid = uid.trim().toUpperCase();

        try {
            // ✅ Load MySQL Driver
            Class.forName("com.mysql.cj.jdbc.Driver");

            try (Connection conn = DriverManager.getConnection(URL, USER, PASS)) {

                // ✅ Force IST
                try (Statement st = conn.createStatement()) {
                    st.execute("SET time_zone = '+05:30'");
                }

                Timestamp now = getNowIST(conn);

                // ===============================
                // 1️⃣ CHECK REGISTERED CARD
                // ===============================
             String name = null;
String email = null;

//  Clean UID properly
uid = uid.trim().toUpperCase();

//  Debug print
System.out.println("SCANNED UID => [" + uid + "]");

try (PreparedStatement ps = conn.prepareStatement(
        "SELECT name, email FROM rfid_cards WHERE TRIM(UPPER(uid))=?")) {

    ps.setString(1, uid);

    try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {

            name = rs.getString("name");
            email = rs.getString("email");

            //  Debug found
            System.out.println("✅ FOUND IN DB => " + name + " | " + email);
        }
    }
}

//  If not found
if (name == null) {

    System.out.println("❌ UID NOT FOUND IN DB");

    response.setStatus(404);
    response.getWriter().write("Card not registered!");
    return;
}

                // ===============================
                // 2️⃣ CHECK TODAY'S RECORD
                // ===============================
                String sel =
                    "SELECT id, session_start, session_end, status " +
                    "FROM attendance " +
                    "WHERE uid=? AND DATE(session_start)=CURDATE() " +
                    "ORDER BY id DESC LIMIT 1";

                Long id = null;
                Timestamp start = null, end = null;
                String status = null;

                try (PreparedStatement ps = conn.prepareStatement(sel)) {
                    ps.setString(1, uid);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            id = rs.getLong("id");
                            start = rs.getTimestamp("session_start");
                            end = rs.getTimestamp("session_end");
                            status = rs.getString("status");
                        }
                    }
                }

                // ===============================
                // 3️⃣ FIRST SCAN → START TIMER
                // ===============================
                if (id == null) {
                    try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO attendance(uid,name,session_start,status,time_in) " +
                        "VALUES(?,?,?,?,NULL)")) {
                        ps.setString(1, uid);
                        ps.setString(2, name);
                        ps.setTimestamp(3, now);
                        ps.setString(4, "PENDING");
                        ps.executeUpdate();
                    }
                    response.getWriter().write("Timer started for " + name);
                    return;
                }

                // ===============================
                // 4️⃣ SECOND SCAN → STOP TIMER + EMAIL
                // ===============================
                if (start != null && end == null) {

                    long seconds = (now.getTime() - start.getTime()) / 1000;
                    double hours = seconds / 3600.0;

                    String finalStatus =
                        hours >= REQUIRED_HOURS ? "PRESENT" : "ABSENT";

                    try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE attendance SET session_end=?, status=?, confirmed_at=?, time_in=? WHERE id=?")) {
                        ps.setTimestamp(1, now);
                        ps.setString(2, finalStatus);
                        ps.setTimestamp(3, now);
                        ps.setTimestamp(4, now);
                        ps.setLong(5, id);
                        ps.executeUpdate();
                    }

                    // ================= EMAIL NOTIFICATION =================
try {

    // ================= ATTENDANCE EMAIL =================
    String subject = "Attendance Notification";

    String body =
        "Dear " + name + ",\n\n" +
        "Your attendance has been recorded.\n\n" +
        "UID: " + uid + "\n" +
        "Status: " + finalStatus + "\n" +
        "Working Hours: " + String.format("%.2f", hours) + "\n\n" +
        "Check In: " + start.toString() + "\n" +
        "Check Out: " + now.toString() + "\n\n" +
        "RFID Attendance System";

EmailUtil.sendAttendanceMail(
    conn,
    uid,
    email,
    name,
    finalStatus,
    String.format("%.2f", hours),
    start.toString(),
    now.toString()
);

    System.out.println("✅ Attendance Email sent to " + email);


    // ================= TASK REMINDER EMAIL =================
    PreparedStatement psTask = conn.prepareStatement(
        "SELECT title FROM tasks WHERE uid=? AND assigned_date=CURDATE() AND status='PENDING'"
    );

    psTask.setString(1, uid);

    ResultSet rsTask = psTask.executeQuery();

    if (rsTask.next()) {

        String taskTitle = rsTask.getString("title");

        String subject2 = "Today's Task Reminder";

        String body2 =
            "Dear " + name + ",\n\n" +
            "Your attendance status: " + finalStatus + "\n\n" +
            "Today's Assigned Task:\n" +
            taskTitle + "\n\n" +
            "Please complete it from your dashboard.\n\n" +
            "Regards,\nAdmin";

        EmailUtil.sendTaskReminderMail(
    conn,
    uid,
    email,
    name,
    taskTitle,
    finalStatus
);

        System.out.println("✅ Task Reminder Email sent to " + email);
    }

} catch (Exception mailEx) {

    mailEx.printStackTrace();
    System.out.println("❌ Email sending failed");

}// ======================================================

response.getWriter().write(
    "Timer stopped. Duration: " +
    String.format("%.2f", hours) +
    " hrs → " + finalStatus
);
return;
}
                // ===============================
                // 5️⃣ ALREADY FINALIZED
                // ===============================
                response.getWriter().write(
                    "Attendance already finalized (" + status + ")"
                );
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(500, "Server error: " + e.getMessage());
        }
    }

    // ===============================
    // IST TIME FROM DB
    // ===============================
    private Timestamp getNowIST(Connection conn) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
            "SELECT CONVERT_TZ(UTC_TIMESTAMP(),'+00:00','+05:30')")) {
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getTimestamp(1);
            }
        }
        return new Timestamp(System.currentTimeMillis());
    }
}
