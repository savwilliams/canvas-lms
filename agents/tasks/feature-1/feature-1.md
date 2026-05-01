## AI Rubric Feedback (MVP)

This feature adds a small, student-facing **“Get AI Feedback”** button on the assignment submission page. Students can paste their draft text and receive quick, rubric-aligned feedback before submitting. The output focuses on identifying missing or weak areas and providing a few clear suggestions for improvement. The feature is advisory only and does not generate grades or affect submissions.

The purpose of this feature is to help students better understand rubric expectations and improve their work before submitting. The MVP is intentionally limited to text-only input, simple structured feedback, and minimal system impact. Success means a student can click one button, receive useful feedback, and revise their work without disrupting the normal Canvas workflow.

---

# Implementation Research: AI Rubric Feedback (MVP)

## Feature Overview

This feature introduces a **Get AI Feedback** button on the assignment submission page. Students paste their draft text, and the system returns short, rubric-aligned feedback focused on improvement.

Scope is intentionally narrow:
- text input only (no file uploads),
- assignments must have a rubric,
- student-facing only,
- advisory feedback only (no grading or score prediction),
- feature-flag controlled.

---

## 1) Design Considerations

### User Flow
- Student opens assignment page.
- If rubric exists and feature is enabled, **Get AI Feedback** is visible.
- Student pastes text and submits request.
- System returns:
  - which rubric areas are weak or missing,
  - key improvement suggestions.
- Student revises work and submits normally.

---

### Key Decisions

- **Advisory-only output**
  - No grades or scoring.
  - Keeps expectations clear and avoids academic risk.

- **Text-only input**
  - No file parsing.
  - Reduces complexity significantly.

- **Simple synchronous request**
  - One request → one response.
  - No background jobs in MVP.

- **Feature flag**
  - Allows safe testing and rollout.

---

### Data and Permissions

- Inputs:
  - student text,
  - rubric criteria,
  - assignment context.

- Access:
  - only enrolled students can use the feature,
  - no instructor workflow changes.

- The feature does not modify:
  - grades,
  - submissions,
  - rubric scores.

---

### Risks

- Students may rely too heavily on AI → include disclaimer.
- Feedback quality may vary → keep output simple and structured.
- Slow responses → include loading state and retry option.

---

## 2) Functional Requirements

### In Scope

1. Show **Get AI Feedback** when:
   - assignment has a rubric,
   - feature flag is enabled.

2. Allow student to submit text for feedback.

3. Return structured feedback:
   - weak or missing rubric areas,
   - clear suggestions for improvement.

4. Do not modify:
   - grades,
   - submission state.

5. Provide basic error handling (retry on failure).

---

### Out of Scope

- File uploads (PDF, DOCX, etc.)
- Grade prediction or scoring
- Instructor tools or dashboards
- Analytics or tracking systems
- Deep Canvas workflow changes

---

## 3) Non-Functional Requirements

### Performance
- Target response time: under 10 seconds.
- UI must show loading state.

---

### Security and Privacy
- Only necessary data sent to AI service.
- No sensitive data stored long-term.
- API keys kept server-side.

---

### Accessibility
- Button and results accessible via keyboard.
- Screen-reader compatible output.

---

### Reliability
- If AI fails:
  - show clear message,
  - allow retry,
  - do not block submission process.

---

## 4) Codebase Integration (High-Level)

### Likely Areas of Change

- Assignment submission UI (add button + input field)
- Backend endpoint for AI request
- Service layer for AI call
- Feature flag + permission checks

---

### Implementation Approach

- Add UI trigger to assignment page.
- Create API endpoint to handle request.
- Send:
  - student text,
  - rubric criteria.
- Return structured feedback.

No deep changes to:
- grading system,
- submission system,
- database structure.

---

## 5) Testing and Verification

### Basic Tests

- Button appears only when conditions are met.
- Student can submit text and receive feedback.
- Feedback format is consistent and readable.
- No impact on submission workflow.

---

### Edge Cases

- empty text input
- no rubric present
- AI service failure
- very long input

---

### Acceptance Criteria

- Student can request feedback from assignment page.
- Feedback highlights weak or missing areas.
- Suggestions are clear and actionable.
- No grading or submission data is modified.
- Feature can be disabled safely with feature flag.