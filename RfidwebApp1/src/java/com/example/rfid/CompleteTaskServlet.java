package com.example.rfid;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/CompleteTaskServlet")
public class CompleteTaskServlet extends HttpServlet {

    private static final String URL =
            "jdbc:mysql://localhost:3306/rfid_system?useSSL=false&serverTimezone=Asia/Kolkata";
    private static final String USER = "nikhil";
    private static final String PASS = "Nikhil@2004";

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("text/html;charset=UTF-8");

        // ================= SESSION SECURITY =================
        HttpSession session = req.getSession(false);
        if (session == null ||
                session.getAttribute("uid") == null ||
                !"EMPLOYEE".equals(session.getAttribute("role"))) {

            resp.sendRedirect("login.jsp");
            return;
        }

        String uid = session.getAttribute("uid").toString();

        String idParam = req.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            resp.sendRedirect("employeeTasks.jsp?error=Invalid Task ID");
            return;
        }

        int id;

        try {
            id = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            resp.sendRedirect("employeeTasks.jsp?error=Invalid Task Format");
            return;
        }

        try (Connection conn = DriverManager.getConnection(URL, USER, PASS)) {

            // ================= VERIFY TASK BELONGS TO USER =================
            PreparedStatement check = conn.prepareStatement(
                    "SELECT status FROM tasks WHERE id=? AND uid=?");
            check.setInt(1, id);
            check.setString(2, uid);

            ResultSet rs = check.executeQuery();

            if (!rs.next()) {
                resp.sendRedirect("employeeTasks.jsp?error=Task Not Found");
                return;
            }

            String currentStatus = rs.getString("status");

            if ("COMPLETED".equals(currentStatus)) {
                resp.sendRedirect("employeeTasks.jsp?msg=Task Already Completed");
                return;
            }

            // ================= UPDATE TASK STATUS =================
            PreparedStatement update = conn.prepareStatement(
                    "UPDATE tasks SET status='COMPLETED' WHERE id=? AND uid=?");
            update.setInt(1, id);
            update.setString(2, uid);

            int rows = update.executeUpdate();

            if (rows > 0) {
                resp.sendRedirect("employeeTasks.jsp?msg=Task Completed Successfully");
            } else {
                resp.sendRedirect("employeeTasks.jsp?error=Unable to Update Task");
            }

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect("employeeTasks.jsp?error=Server Error");
        }
    }
}