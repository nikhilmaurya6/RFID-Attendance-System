package com.rfid.servlets;

import com.rfid.util.DBUtil;
import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/SubmitCorrectionServlet")
public class SubmitCorrectionServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("text/plain");

        String idStr = req.getParameter("attendance_id");

        if (idStr == null || idStr.trim().isEmpty()) {
            resp.getWriter().write("Attendance ID missing.");
            return;
        }

        int attendanceId = Integer.parseInt(idStr);

        String oldStatus = req.getParameter("old_status");
        String newStatus = req.getParameter("new_status");
        String reason = req.getParameter("reason");
        String requestedBy = req.getParameter("requested_by");

        try (Connection con = DBUtil.getConnection()) {

            // 🔥 CHECK PARENT EXISTS
            PreparedStatement chk = con.prepareStatement(
                "SELECT id FROM attendance WHERE id=?");
            chk.setInt(1, attendanceId);
            ResultSet rs = chk.executeQuery();

            if (!rs.next()) {
                resp.getWriter().write(
                  "Invalid Attendance ID. Record does not exist.");
                return;
            }

            String sql =
              "INSERT INTO attendance_corrections " +
              "(attendance_id, old_status, new_status, requested_by, reason) " +
              "VALUES (?,?,?,?,?)";

            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, attendanceId);
            ps.setString(2, oldStatus);
            ps.setString(3, newStatus);
            ps.setString(4, requestedBy);
            ps.setString(5, reason);
            ps.executeUpdate();

            resp.getWriter().write(
              "Correction request submitted successfully.");

        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().write("Error: " + e.getMessage());
        }
    }
}
