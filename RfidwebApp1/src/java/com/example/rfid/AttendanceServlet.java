package com.example.rfid;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import javax.servlet.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/attendance")
public class AttendanceServlet extends HttpServlet {

  private static final String URL =
    "jdbc:mysql://localhost:3306/rfid_system?useSSL=false&serverTimezone=Asia/Kolkata";
  private static final String USER = "nikhil";
  private static final String PASS = "Nikhil@2004";

  private static final int REQUIRED_HOURS = 6;

  private static final String SQL_ADMIN =
    "SELECT id, uid, name, session_start, session_end, time_in, status " +
    "FROM attendance ORDER BY id DESC";

  private static final String SQL_STUDENT =
    "SELECT id, uid, name, session_start, session_end, time_in, status " +
    "FROM attendance WHERE uid=? ORDER BY id DESC";

  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {

    response.setContentType("application/json;charset=UTF-8");
    response.setHeader("Cache-Control","no-store, no-cache, must-revalidate, private");
    response.setHeader("Pragma","no-cache");
    response.setDateHeader("Expires", 0);

    HttpSession session = request.getSession(false);
    String role = session != null ? (String) session.getAttribute("role") : null;
    String sessionUid = session != null ? (String) session.getAttribute("uid") : null;

    JsonArray out = new JsonArray();

    try (Connection conn = DriverManager.getConnection(URL, USER, PASS)) {

      // Force IST
      try (Statement tz = conn.createStatement()) {
        tz.execute("SET time_zone = '+05:30'");
      }

      PreparedStatement ps =
        ("STUDENT".equals(role) && sessionUid != null)
          ? conn.prepareStatement(SQL_STUDENT)
          : conn.prepareStatement(SQL_ADMIN);

      if ("STUDENT".equals(role) && sessionUid != null) {
        ps.setString(1, sessionUid);
      }

      try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {

          JsonObject obj = new JsonObject();

          Timestamp start = rs.getTimestamp("session_start");
          Timestamp end   = rs.getTimestamp("session_end");
          String status   = rs.getString("status");

          double hours = 0;
          if (start != null && end != null) {
            long sec = (end.getTime() - start.getTime()) / 1000;
            hours = sec / 3600.0;
          }

          // 🔥🔥 MOST IMPORTANT (FIX FOR FK ERROR)
          obj.addProperty("id", rs.getInt("id"));

          obj.addProperty("uid", rs.getString("uid"));
          obj.addProperty("name", rs.getString("name"));

          obj.addProperty(
            "session_start",
            start == null ? "" : formatTS(start)
          );

          obj.addProperty(
            "time_in",
            rs.getTimestamp("time_in") == null ? "" : formatTS(rs.getTimestamp("time_in"))
          );

          obj.addProperty("status", status == null ? "PENDING" : status);
          obj.addProperty("duration_hours", String.format("%.2f", hours));

          // Remaining seconds for running timer
          if ("PENDING".equals(status) && start != null) {
            long now = System.currentTimeMillis();
            long secRun = (now - start.getTime()) / 1000;
            long secLeft = REQUIRED_HOURS * 3600 - secRun;
            obj.addProperty("remaining_seconds", Math.max(secLeft, 0));
          } else {
            obj.addProperty("remaining_seconds", 0);
          }

          out.add(obj);
        }
      }

    } catch (Exception e) {
      JsonObject err = new JsonObject();
      err.addProperty("error", e.getMessage());
      response.getWriter().print(err.toString());
      return;
    }

    response.getWriter().print(out.toString());
  }

  private String formatTS(Timestamp ts) {
    return ts.toString().replace(".0", "");
  }
}
