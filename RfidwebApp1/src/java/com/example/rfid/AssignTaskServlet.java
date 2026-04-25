package com.example.rfid;

import com.example.util.EmailUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/AssignTaskServlet")
public class AssignTaskServlet extends HttpServlet {

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
        if (session == null || !"ADMIN".equals(session.getAttribute("role"))) {
            resp.sendRedirect("login.jsp");
            return;
        }

        // ================= INPUT =================
        String uid = req.getParameter("uid");
        String title = req.getParameter("title");
        String desc = req.getParameter("description");

        if (uid == null || title == null || desc == null ||
                uid.trim().isEmpty() ||
                title.trim().isEmpty() ||
                desc.trim().isEmpty()) {

            resp.sendRedirect("assignTask.jsp?error=All fields are required");
            return;
        }

        uid = uid.trim().toUpperCase();

        try (Connection conn = DriverManager.getConnection(URL, USER, PASS)) {

            // ================= CHECK UID EXISTS =================
            PreparedStatement checkUser = conn.prepareStatement(
                    "SELECT name, email FROM rfid_cards WHERE uid=?");
            checkUser.setString(1, uid);
            ResultSet rsUser = checkUser.executeQuery();

            if (!rsUser.next()) {
                resp.sendRedirect("assignTask.jsp?error=Invalid UID");
                return;
            }

            String name = rsUser.getString("name");
            String email = rsUser.getString("email");

            // ================= PREVENT DUPLICATE TASK SAME DAY =================
            PreparedStatement checkTask = conn.prepareStatement(
                    "SELECT id FROM tasks WHERE uid=? AND assigned_date=CURDATE()");
            checkTask.setString(1, uid);
            ResultSet rsTask = checkTask.executeQuery();

            if (rsTask.next()) {
                resp.sendRedirect("assignTask.jsp?error=Task already assigned today");
                return;
            }

            // ================= INSERT TASK =================
            PreparedStatement insert = conn.prepareStatement(
                    "INSERT INTO tasks(uid,title,description,assigned_date,status) " +
                            "VALUES(?,?,?,CURDATE(),'PENDING')");
            insert.setString(1, uid);
            insert.setString(2, title);
            insert.setString(3, desc);

            insert.executeUpdate();

            // ================= SEND EMAIL =================
            try {
                String subject = "📌 New Task Assigned";
                String body =
                        "Dear " + name + ",\n\n" +
                        "You have been assigned a new task for today.\n\n" +
                        "Task Title: " + title + "\n" +
                        "Description: " + desc + "\n\n" +
                        "Please login to your dashboard and complete it.\n\n" +
                        "Regards,\nAdmin";

                EmailUtil.sendTaskAssignMail(
    conn,
    uid,
    email,
    name,
    title,
    desc
);               System.out.println("Task email sent to: " + email);

            } catch (Exception mailEx) {
                mailEx.printStackTrace();
                System.out.println("Email sending failed.");
            }

            resp.sendRedirect("assignTask.jsp?msg=Task Assigned Successfully");

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect("assignTask.jsp?error=Server Error Occurred");
        }
    }
}