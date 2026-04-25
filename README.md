# RFID Based Attendance System

## 📌 Project Description
This project is an RFID-based attendance system using ESP32, Java Servlet, and MySQL database. It automates attendance marking using RFID cards.

## 🛠️ Technologies Used
- ESP32 (Microcontroller)
- RFID Module (MFRC522)
- Java (Servlet & JSP)
- MySQL Database
- HTML, CSS, JavaScript

## ⚙️ How It Works
1. RFID card is scanned using ESP32
2. UID is sent to server via HTTP request
3. Server (Servlet) checks UID in database
4. Attendance is recorded
5. Dashboard updates automatically

## ✨ Features
- Automatic attendance marking
- Real-time dashboard
- Present/Absent detection (6-hour logic)
- Email notification
- Attendance correction request system
- Admin & Student login system

## 🔐 Security
- API key used between ESP32 and server
- Duplicate entries prevented

## 📁 Project Structure
RFID-Attendance-System/
│
├── RfidwebApp1/
├── esp32_code/
├── database/
└── README.md

## 👨‍💻 Author
Nikhil Maurya  
BSc IT Student  
RFID Attendance System Project
