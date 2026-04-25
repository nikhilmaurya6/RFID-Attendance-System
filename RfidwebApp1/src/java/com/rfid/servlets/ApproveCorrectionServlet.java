package com.rfid.servlets;

import com.rfid.util.DBUtil;
import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.util.logging.Logger;
import java.util.logging.Level;
import org.json.JSONObject;

@WebServlet("/ApproveCorrectionServlet")
public class ApproveCorrectionServlet extends HttpServlet {
    private static final Logger logger = Logger.getLogger(ApproveCorrectionServlet.class.getName());

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        JSONObject jsonResponse = new JSONObject();

        String idParam = req.getParameter("id");
        String action = req.getParameter("action");

        // Validate input parameters
        if (idParam == null || action == null || idParam.isEmpty() || action.isEmpty()) {
            jsonResponse.put("status", "error");
            jsonResponse.put("message", "Missing required parameters.");
            resp.getWriter().write(jsonResponse.toString());
            return;
        }

        int correctionId;
        try {
            correctionId = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            jsonResponse.put("status", "error");
            jsonResponse.put("message", "Invalid id parameter.");
            resp.getWriter().write(jsonResponse.toString());
            return;
        }

        // Get logged-in admin email from session
        HttpSession session = req.getSession(false);
        String approvedBy = (session != null && session.getAttribute("adminEmail") != null)
                ? session.getAttribute("adminEmail").toString()
                : "admin@yourdomain.com"; // fallback email or handle unauthorized case

        String dbApprovedValue;
        if ("APPROVE".equalsIgnoreCase(action)) {
            dbApprovedValue = "APPROVED";
        } else if ("REJECT".equalsIgnoreCase(action)) {
            dbApprovedValue = "REJECTED";
        } else {
            dbApprovedValue = "PENDING";
        }

        Connection con = null;
        PreparedStatement psUpdateCorrection = null;
        PreparedStatement psInsertLog = null;
        PreparedStatement psSelectCorrection = null;
        PreparedStatement psUpdateAttendance = null;
        ResultSet rs = null;

        try {
            con = DBUtil.getConnection();
            con.setAutoCommit(false);

            // Update correction status
            String updateCorrectionSQL = "UPDATE attendance_corrections SET approved=?, approved_by=?, approved_at=NOW() WHERE id=?";
            psUpdateCorrection = con.prepareStatement(updateCorrectionSQL);
            psUpdateCorrection.setString(1, dbApprovedValue);
            psUpdateCorrection.setString(2, approvedBy);
            psUpdateCorrection.setInt(3, correctionId);
            int rowsUpdated = psUpdateCorrection.executeUpdate();

            if (rowsUpdated == 0) {
                jsonResponse.put("status", "error");
                jsonResponse.put("message", "No correction found with id: " + correctionId);
                resp.getWriter().write(jsonResponse.toString());
                return;
            }

            // Insert log
            String insertLogSQL = "INSERT INTO attendance_correction_log (correction_id, action, action_by, comment) VALUES (?, ?, ?, ?)";
            psInsertLog = con.prepareStatement(insertLogSQL);
            psInsertLog.setInt(1, correctionId);
            psInsertLog.setString(2, dbApprovedValue);
            psInsertLog.setString(3, approvedBy);
            psInsertLog.setString(4, "Action processed by ApproveCorrectionServlet");
            psInsertLog.executeUpdate();

            // If approved, update attendance status
            if ("APPROVE".equalsIgnoreCase(action)) {
                String selectSql = "SELECT new_status, attendance_id FROM attendance_corrections WHERE id = ?";
                psSelectCorrection = con.prepareStatement(selectSql);
                psSelectCorrection.setInt(1, correctionId);
                rs = psSelectCorrection.executeQuery();

                if (rs.next()) {
                    String newStatus = rs.getString("new_status");
                    int attendanceId = rs.getInt("attendance_id");

                    String updateAttendance = "UPDATE attendance SET status = ? WHERE id = ?";
                    psUpdateAttendance = con.prepareStatement(updateAttendance);
                    psUpdateAttendance.setString(1, newStatus);
                    psUpdateAttendance.setInt(2, attendanceId);
                    psUpdateAttendance.executeUpdate();
                }
            }

            con.commit();

            jsonResponse.put("status", "success");
            jsonResponse.put("message", "Request #" + correctionId + " " + action + " successfully processed.");
            resp.getWriter().write(jsonResponse.toString());

        } catch (Exception e) {
            try {
                if (con != null) con.rollback();
            } catch (SQLException se) {
                logger.log(Level.SEVERE, "Rollback failed", se);
            }

            logger.log(Level.SEVERE, "Error processing approval", e);

            jsonResponse.put("status", "error");
            jsonResponse.put("message", "Error processing approval: " + e.getMessage());
            resp.getWriter().write(jsonResponse.toString());

        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException ignored) {}
            try { if (psUpdateCorrection != null) psUpdateCorrection.close(); } catch (SQLException ignored) {}
            try { if (psInsertLog != null) psInsertLog.close(); } catch (SQLException ignored) {}
            try { if (psSelectCorrection != null) psSelectCorrection.close(); } catch (SQLException ignored) {}
            try { if (psUpdateAttendance != null) psUpdateAttendance.close(); } catch (SQLException ignored) {}
            try { if (con != null) con.setAutoCommit(true); con.close(); } catch (SQLException ignored) {}
        }
    }
}
