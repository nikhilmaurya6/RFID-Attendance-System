package com.example.rfid;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import javax.servlet.*;
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.sql.*;

@WebServlet("/exportCsv")
public class ExportCsvServlet extends HttpServlet {

    private static final String URL  =
        "jdbc:mysql://localhost:3306/rfid_system?useSSL=false&serverTimezone=Asia/Kolkata";
    private static final String USER = "nikhil";
    private static final String PASS = "Nikhil@2004";

    // Must match AttendanceServlet & RfidServlet
    private static final int REQUIRED_HOURS = 6;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.reset();
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/csv; charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"attendance.csv\"");

        // CSV Header Row
        StringBuilder csv = new StringBuilder(
            "id,uid,name,session_start,time_in,status,confirmed_at\n"
        );

        try (Connection conn = DriverManager.getConnection(URL, USER, PASS)) {

            // Ensure IST timestamps
            try (Statement st = conn.createStatement()) {
                st.execute("SET time_zone = '+05:30'");
            }

            // 1) Finalize old PENDING rows (>= 6 hours)
            String cleanupSql =
                "UPDATE attendance SET status='PRESENT', " +
                "confirmed_at = CONVERT_TZ(UTC_TIMESTAMP(), '+00:00', '+05:30'), " +
                "time_in = CONVERT_TZ(UTC_TIMESTAMP(), '+00:00', '+05:30') " +
                "WHERE status='PENDING' AND session_start IS NOT NULL " +
                "AND TIMESTAMPDIFF(HOUR, session_start, CONVERT_TZ(UTC_TIMESTAMP(), '+00:00', '+05:30')) >= ?";
            try (PreparedStatement p = conn.prepareStatement(cleanupSql)) {
                p.setInt(1, REQUIRED_HOURS);
                p.executeUpdate();
            }

            // 2) Export final attendance
            String sql =
                "SELECT id, uid, name, " +
                "DATE_FORMAT(session_start, '%Y-%m-%d %H:%i:%s') AS session_start, " +
                "DATE_FORMAT(time_in, '%Y-%m-%d %H:%i:%s') AS time_in, " +
                "status, " +
                "DATE_FORMAT(confirmed_at, '%Y-%m-%d %H:%i:%s') AS confirmed_at " +
                "FROM attendance ORDER BY id DESC";

            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {

                boolean hasData = false;

                while (rs.next()) {
                    hasData = true;

                    csv.append(
                        csvEscape(String.valueOf(rs.getInt("id"))) + "," +
                        csvEscape(rs.getString("uid")) + "," +
                        csvEscape(rs.getString("name")) + "," +
                        csvEscape(rs.getString("session_start")) + "," +
                        csvEscape(rs.getString("time_in")) + "," +
                        csvEscape(rs.getString("status")) + "," +
                        csvEscape(rs.getString("confirmed_at")) + "\n"
                    );
                }

                if (!hasData) {
                    csv.append("No Records,No Records,No Records,No Records,No Records,No Records,No Records\n");
                }
            }

            byte[] data = csv.toString().getBytes(StandardCharsets.UTF_8);
            response.setContentLength(data.length);

            try (ServletOutputStream os = response.getOutputStream()) {
                os.write(data);
                os.flush();
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.reset();
            response.sendError(
                HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                "CSV export failed: " + e.getMessage()
            );
        }
    }

    // Helpers
    private static String csvEscape(String s) {
        if (s == null) return "";
        if (s.contains(",") || s.contains("\"") || s.contains("\n")) {
            return "\"" + s.replace("\"", "\"\"") + "\"";
        }
        return s;
    }
}
