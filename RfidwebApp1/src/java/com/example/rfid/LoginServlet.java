package com.example.rfid;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import javax.servlet.*;
import java.io.IOException;
import java.util.Map;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

  // Hardcoded ADMIN users: username -> password
  private static final Map<String,String> ADMIN = Map.of(
      "admin", "admin123"
  );

  // Hardcoded STUDENT users: username -> password
  private static final Map<String,String> STUDENT = Map.of(
      "student", "student123",
      "stu1", "111111"
  );

  // Student username -> RFID UID map (for filtering)
  private static final Map<String,String> STUDENT_UID = Map.of(
      "student", "ABCD1234",
      "stu1", "EFGH5678"
  );

  @Override
  protected void doPost(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {

    String role = req.getParameter("role");
    String user = req.getParameter("username");
    String pass = req.getParameter("password");

    boolean ok = false;
    String uidForStudent = null;

    if ("ADMIN".equalsIgnoreCase(role)) {
      ok = ADMIN.containsKey(user) && ADMIN.get(user).equals(pass);
    } else if ("STUDENT".equalsIgnoreCase(role)) {
      ok = STUDENT.containsKey(user) && STUDENT.get(user).equals(pass);
      if (ok) uidForStudent = "626C1001";
    }

    if (ok) {
      HttpSession session = req.getSession(true);
      session.setAttribute("username", user);
      session.setAttribute("role", role.toUpperCase());
      if (uidForStudent != null) session.setAttribute("uid", uidForStudent);
      session.setMaxInactiveInterval(30 * 60);
      resp.sendRedirect(req.getContextPath() + "/dashboard.jsp");
      return;
    }

    resp.sendRedirect(req.getContextPath() + "/login.jsp?err=Invalid+credentials");
  }
}
