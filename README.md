# Praman – Foreign Employment Agency Verification

Praman is a web-based prototype developed for a hackathon to help job seekers verify foreign employment (manpower) agencies before paying recruitment fees and report suspicious agencies through a community reporting system.

The application provides a searchable agency registry, displays verification status, allows users to submit complaints, and stores data using Supabase.

> **Note:** This project is a hackathon prototype. The agency data is for demonstration purposes only and is **not** an official Department of Foreign Employment (DoFE) database.


## Features

### Agency Verification
- Search foreign employment agencies by name.
- View agency verification status.
- Display license number and location.
- View agency complaint history.
- Add new complaints for an agency.
- Support for:
  - ✅ Verified
  - ⚠️ Flagged
  - 🔍 Under Review

### Community Reporting
- Report suspicious agencies.
- Upload optional evidence files.
- View public community reports.
- Reports are stored in Supabase.

### User Interface
- Responsive design
- Dark modern UI
- Animated verification stamps
- Search functionality
- Toast notifications
- Mobile-friendly layout

---

## 🛠 Technologies Used

- HTML5
- CSS3
- JavaScript (Vanilla)
- Supabase Database
- Supabase Storage
- Google Fonts

---

## 📂 Project Structure

```
Praman/
│
├── index.html
└── README.md
```

---

## 🗄 Database Structure

### agencies

Stores manpower agency information.

| Column |
|---------|
| id |
| name |
| license |
| location |
| status |
| created_at |

---

### complaints

Stores complaints related to agencies.

| Column |
|---------|
| id |
| agency_id |
| text |
| date |
| created_at |

---

### reports

Stores community-submitted suspicious agency reports.

| Column |
|---------|
| id |
| name |
| description |
| has_file |
| evidence_url |
| date |
| created_at |

---

### Storage Bucket

```
evidence
```

Stores uploaded evidence files.

---

## ⚙️ Installation

### Clone the repository

```bash
git clone https://github.com/yourusername/praman.git
```

### Open the project

Open **index.html** in any modern web browser.

or

Use **VS Code Live Server**.

---

## 🔗 Supabase Setup

Create a Supabase project and configure:

- Database Tables
  - agencies
  - complaints
  - reports

- Storage Bucket
  - evidence

Update these values inside the JavaScript file:

```javascript
const SUPABASE_URL = "YOUR_SUPABASE_URL";
const SUPABASE_ANON = "YOUR_SUPABASE_ANON_KEY";
```

---

## 📖 How It Works

1. Search for a manpower agency.
2. Open agency details.
3. View license information and complaints.
4. Submit additional complaints if needed.
5. Report suspicious agencies from the Report page.
6. Upload supporting evidence (optional).
7. Community reports become visible in the public report feed.
8. When an agency receives multiple reports, its status can be updated to **Under Review**.

---

## 🎯 Project Objective

The objective of Praman is to help reduce foreign employment fraud by allowing users to:

- Verify manpower agencies
- Read previous complaints
- Report suspicious activities
- Increase awareness before making recruitment payments

---

## 📌 Future Improvements

- Official DoFE database integration
- Advanced filtering
- Admin dashboard
- User authentication
- Email notifications
- Multi-language support
- Mobile application

---

## ⚠️ Disclaimer

This project was developed as part of a college hackathon.

The information displayed in this application is for demonstration purposes only and should not be considered official government data.

Always verify manpower agencies through the **Department of Foreign Employment (DoFE), Nepal** before making any payment.

---

## 👨‍💻 Developed For

**College Internal Hackathon**

Theme: **Open Innovation**

---

## 📄 License

This project is intended for educational and demonstration purposes.
