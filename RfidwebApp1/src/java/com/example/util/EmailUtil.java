package com.example.util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.Properties;
import javax.mail.*;
import javax.mail.internet.*;

public class EmailUtil {

    private static final String FROM_EMAIL = "rfidattendance32@gmail.com";
    private static final String APP_PASSWORD = "dbomczxyklnytfmr";

    // ================= GENERIC MAIL SENDER =================
    public static void sendMail(
            Connection conn,
            String uid,
            String toEmail,
            String subject,
            String body
    ) {

        String status = "SENT";
        String errorText = null;

        try {
            Properties props = new Properties();

props.put("mail.smtp.auth", "true");
props.put("mail.smtp.starttls.enable", "true");
props.put("mail.smtp.starttls.required", "true");
props.put("mail.smtp.host", "smtp.gmail.com");
props.put("mail.smtp.port", "587");

props.put("mail.smtp.ssl.trust", "smtp.gmail.com");
props.put("mail.smtp.ssl.protocols", "TLSv1.2");

            Session session = Session.getInstance(props,
                new Authenticator() {
                    protected PasswordAuthentication getPasswordAuthentication() {
                        return new PasswordAuthentication(FROM_EMAIL, APP_PASSWORD);
                    }
                });

            Message msg = new MimeMessage(session);
            msg.setFrom(new InternetAddress(FROM_EMAIL, "RFID Attendance System"));
            msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            msg.setSubject(subject);
            msg.setText(body);

            Transport.send(msg);
            System.out.println("✅ Email SENT to " + toEmail);

        } catch (Exception e) {
            status = "FAILED";
            errorText = e.toString();
            System.out.println("❌ Email FAILED: " + e);
        }

        // ================= LOG TO DATABASE =================
        try (PreparedStatement ps = conn.prepareStatement(
            "INSERT INTO email_events(uid,email_to,subject,body,status,error_text) VALUES(?,?,?,?,?,?)"
        )) {
            ps.setString(1, uid);
            ps.setString(2, toEmail);
            ps.setString(3, subject);
            ps.setString(4, body);
            ps.setString(5, status);
            ps.setString(6, errorText);
            ps.executeUpdate();
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }


    // ================= ATTENDANCE MAIL =================
    public static void sendAttendanceMail(
            Connection conn,
            String uid,
            String toEmail,
            String name,
            String status,
            String hours,
            String checkIn,
            String checkOut
    ) {

        String subject = "Attendance Report";

        String body =
                "Dear " + name + ",\n\n" +
                "Attendance Details:\n\n" +
                "UID: " + uid + "\n" +
                "Status: " + status + "\n" +
                "Total Hours: " + hours + "\n" +
                "Check-In: " + checkIn + "\n" +
                "Check-Out: " + checkOut + "\n\n" +
                "Regards,\nAdmin";

        sendMail(conn, uid, toEmail, subject, body);
    }


    // ================= TASK ASSIGN MAIL =================
    public static void sendTaskAssignMail(
            Connection conn,
            String uid,
            String toEmail,
            String name,
            String taskTitle,
            String taskDesc
    ) {

        String subject = "New Task Assigned";

        String body =
                "Dear " + name + ",\n\n" +
                "You have been assigned a new task.\n\n" +
                "Title: " + taskTitle + "\n" +
                "Description: " + taskDesc + "\n\n" +
                "Please complete it from dashboard.\n\nAdmin";

        sendMail(conn, uid, toEmail, subject, body);
    }


    // ================= TASK REMINDER MAIL =================
    public static void sendTaskReminderMail(
            Connection conn,
            String uid,
            String toEmail,
            String name,
            String taskTitle,
            String attendanceStatus
    ) {

        String subject = "Attendance + Task Reminder";

        String body =
                "Dear " + name + ",\n\n" +
                "Your attendance is marked as: " + attendanceStatus + "\n\n" +
                "Today's Task:\n" +
                taskTitle +
                "\n\nPlease complete it from dashboard.\n\nAdmin";

        sendMail(conn, uid, toEmail, subject, body);
    }
}