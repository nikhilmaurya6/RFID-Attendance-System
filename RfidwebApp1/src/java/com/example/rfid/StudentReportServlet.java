package com.example.rfid;

import com.rfid.util.DBUtil;
import org.json.JSONArray;
import org.json.JSONObject;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

@WebServlet("/studentReport")
public class StudentReportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        JSONArray jsonArray = new JSONArray();

        // 🔥 STUDENT-WISE VIEW
        String sql = "SELECT * FROM v_student_attendance_report";

        try (
            Connection con = DBUtil.getConnection();
            Statement st = con.createStatement();
            ResultSet rs = st.executeQuery(sql)
        ) {
            int srNo = 1;

            while (rs.next()) {
                JSONObject obj = new JSONObject();

                obj.put("sr_no", srNo++);
                obj.put("uid", rs.getString("uid"));
                obj.put("name", rs.getString("name"));
                obj.put("total_days", rs.getInt("total_days"));
                obj.put("present_days", rs.getInt("present_days"));
                obj.put("percentage", rs.getDouble("attendance_percentage"));

                jsonArray.put(obj);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        resp.getWriter().print(jsonArray.toString());
    }
}
