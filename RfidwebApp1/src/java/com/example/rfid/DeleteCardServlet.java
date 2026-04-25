package com.example.rfid;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/deleteCard")
public class DeleteCardServlet extends HttpServlet {
    private static final String URL  = "jdbc:mysql://localhost:3306/rfid_system?useSSL=false&serverTimezone=UTC";
    private static final String USER = "nikhil";
    private static final String PASS = "Nikhil@2004";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");

        if (idStr == null || idStr.isBlank()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("ID missing");
            return;
        }

        Connection conn = null;

        try {
            conn = DriverManager.getConnection(URL, USER, PASS);
            conn.setAutoCommit(false); // 🔥 IMPORTANT (transaction start)

            int id = Integer.parseInt(idStr);

            // ===============================
            // 1️⃣ DELETE FROM LOG TABLE
            // ===============================
            PreparedStatement ps1 = conn.prepareStatement(
                "DELETE FROM attendance_correction_log WHERE correction_id IN " +
                "(SELECT id FROM attendance_corrections WHERE attendance_id=?)"
            );
            ps1.setInt(1, id);
            ps1.executeUpdate();

            // ===============================
            // 2️⃣ DELETE FROM CORRECTIONS
            // ===============================
            PreparedStatement ps2 = conn.prepareStatement(
                "DELETE FROM attendance_corrections WHERE attendance_id=?"
            );
            ps2.setInt(1, id);
            ps2.executeUpdate();

            // ===============================
            // 3️⃣ DELETE MAIN RECORD
            // ===============================
            PreparedStatement ps3 = conn.prepareStatement(
                "DELETE FROM attendance WHERE id=?"
            );
            ps3.setInt(1, id);

            int affected = ps3.executeUpdate(); // 1 when deleted

            conn.commit(); // ✅ SUCCESS

            response.sendRedirect("dashboard.jsp");

        } catch (Exception e) {

            try {
                if (conn != null) conn.rollback(); // ❌ ERROR → rollback
            } catch (Exception ex) {
                ex.printStackTrace();
            }

            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Database error: " + e.getMessage());

        } finally {
            try {
                if (conn != null) conn.close();
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }
}