package com.example.rfid;

import com.rfid.util.DBUtil;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@WebServlet("/saveSnapshot")
public class SaveSnapshotServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        // 📁 Folder where file will be saved
        String folderPath = getServletContext().getRealPath("/") + "reports";
        File folder = new File(folderPath);
        if (!folder.exists()) folder.mkdirs();

        // 🕒 File name with timestamp
        String fileName = "attendance_snapshot_" +
                LocalDateTime.now()
                .format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"))
                + ".csv";

        File file = new File(folder, fileName);

        String sql = "SELECT * FROM v_student_attendance_report";

        try (
            Connection con = DBUtil.getConnection();
            Statement st = con.createStatement();
            ResultSet rs = st.executeQuery(sql);
            PrintWriter pw = new PrintWriter(new FileWriter(file))
        ) {
            // CSV HEADER
            pw.println("Sr No,Student ID,Name,Total Days,Present Days,Attendance %");

            int sr = 1;
            while (rs.next()) {
                pw.println(
                    sr++ + "," +
                    rs.getString("uid") + "," +
                    rs.getString("name") + "," +
                    rs.getInt("total_days") + "," +
                    rs.getInt("present_days") + "," +
                    rs.getDouble("attendance_percentage")
                );
            }

            resp.getWriter().print(
                "Snapshot saved successfully: /reports/" + fileName
            );

        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().print("Error saving snapshot");
        }
    }
}
