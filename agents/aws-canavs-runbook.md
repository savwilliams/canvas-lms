# AWS + Canvas Runbook

## Goal

Use AI assistance in Cursor to prepare a working Canvas LMS development environment on AWS EC2 for future implementation work.

---

# AI Prompt Used

Example prompts used in Cursor:

```text
Help me verify that Canvas LMS is correctly running on my EC2 instance.
```

Cursor response excerpt:

```text
Canvas LMS on your EC2 instance is running correctly for development: Docker is active, and postgres, redis, web (port 3000), and jobs are up; http://YOUR_IP_ADDRESS:3000/login/canvas returns 200, the database (canvas_development) has tables and your demo user, and brandable CSS is built with domain set to YOUR_ADDRESS.
```

---

# Learner Lab + EC2 Checklist

- AWS Learner Lab started
- EC2 instance created
- SSH connection working
- Repository cloned on EC2 instance
- Canvas LMS dependencies installed
- Canvas development environment connected and running

---

## Browser verification

Canvas LMS responded through the expected development URL / port after startup.