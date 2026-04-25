package com.example.rfid;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/registerCard")
public class RegisterCardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private String url = "jdbc:mysql://localhost:3306/rfid_system?useSSL=false&serverTimezone=UTC";
    private String user = "nikhil";
    private String pass = "Nikhil@2004";

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String uid = request.getParameter("uid").toUpperCase().trim();
        String name = request.getParameter("name").trim();
        String email = request.getParameter("email").trim();   // ✅ ADD THIS

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(url, user, pass);

            // Check duplicate UID
            PreparedStatement check = conn.prepareStatement(
                "SELECT * FROM rfid_cards WHERE uid=?"
            );
            check.setString(1, uid);
            ResultSet rs = check.executeQuery();

            if (rs.next()) {
                response.getWriter().println("⚠️ Card already registered!");
            } else {

                // ✅ FIX HERE (email add)
                PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO rfid_cards (uid, name, email) VALUES (?, ?, ?)"
                );

                ps.setString(1, uid);
                ps.setString(2, name);
                ps.setString(3, email);   // ✅ IMPORTANT

                ps.executeUpdate();

                response.getWriter().println("✅ Card registered successfully!");
            }

            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("❌ Error: " + e.getMessage());
        }
    }
}