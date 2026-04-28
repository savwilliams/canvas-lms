## AI Rubric Feedback (MVP)

This feature adds a small, student-facing **“Get AI Feedback”** action on the assignment submission page so students can request pre-submission guidance against the assignment rubric. The goal is to provide fast, formative feedback before final submission: a short summary of strengths, likely gaps by rubric criterion, and a few concrete improvement suggestions. For initial scope control, this should be treated as advisory only (not grading), available only when a rubric exists, and limited to a simple response format that students can quickly act on.

The main reason for this feature is to help students self-correct earlier, reduce uncertainty about rubric expectations, and improve submission quality without changing instructor grading authority. To keep the MVP small and safe, the first version should support only one submission type (text entry), run behind a feature flag, enforce basic usage limits, and avoid broad platform changes such as file parsing, analytics dashboards, or auto-scoring workflows. Success for this phase is straightforward: students can request rubric-aligned feedback in one click and use it to revise before submitting.

Generated with Ai











# Implementation Research: AI Rubric Feedback (MVP)

## Feature overview
This feature adds a student-facing **Get AI Feedback** button on the assignment submission page so students can get rubric-aligned improvement guidance **before** final submission. The feedback is formative only (not a grade), and is intended to help students identify missing criteria, weak areas, and concrete next edits.

The MVP is intentionally narrow: text-entry submissions only, assignments with an attached rubric only, student role only, feature-flagged rollout, and bounded usage. This keeps risk and complexity low while validating whether rubric-aligned AI feedback improves submission quality and student confidence.

## 1) Design considerations

### Product and user flow
- Student opens assignment submission page.
- If assignment has a rubric and feature is enabled, student sees **Get AI Feedback**.
- Student clicks button and receives short structured guidance:
  - rubric criteria status (met / partial / unclear),
  - top improvement opportunities,
  - actionable revision suggestions.
- Student can revise work and then submit through normal Canvas flow.

### Key design choices and tradeoffs
- **Advisory-only output**: no grade prediction or auto-scoring in MVP.
  - Tradeoff: less “wow factor,” but safer and clearer student expectations.
- **Text entry only**: no file parsing in MVP.
  - Tradeoff: excludes some courses initially, but avoids major scope growth.
- **Synchronous request path** with timeout and friendly fallback.
  - Tradeoff: simpler architecture now; background jobs can be phase 2.
- **Feature flag + rate limits** from day one.
  - Tradeoff: slightly more setup, but safer rollout and cost control.

### Data boundaries, permissions, and Canvas concept alignment
- Data crossing boundaries:
  - Student draft text,
  - assignment context (course/assignment IDs),
  - rubric criteria text.
- Permission model:
  - Only authenticated students in courses where they are enrolled can request feedback.
  - Teacher/admin views are unchanged in MVP.
- Canvas concept interactions:
  - Course and assignment context determine visibility and access.
  - Rubric is the source of alignment criteria.
  - Existing submission flow remains authoritative; AI does not alter grades.

### UX and policy risks
- Students may over-trust AI feedback; UI must clearly state that instructor grading is final.
- Feedback quality may vary by prompt/model behavior; output should be structured and concise.
- Latency may interrupt writing flow; include loading state, timeout messaging, and retry guidance.

### Plan-tracking metadata for future Lab 4 automation
- Milestones to track:
  1. Requirements freeze (MVP boundary signed off),
  2. API contract finalized,
  3. Feature flag + permission checks complete,
  4. UI interaction complete,
  5. Observability and safeguards complete,
  6. Pilot rollout and evaluation complete.
- Task categories:
  - UI, backend endpoint, prompt/output schema, authz, rate limiting, logging/metrics, accessibility, docs.
- Dependencies:
  - Rubric availability checks before AI request flow,
  - feature flag before user exposure,
  - policy/disclaimer copy before rollout.
- Definition of done:
  - Functional requirements pass,
  - non-functional expectations met,
  - acceptance criteria validated in pilot environment.

## 2) Functional requirements

### In scope (MVP)
1. The system shall display **Get AI Feedback** to student users on assignment submission pages when:
   - the assignment has an attached rubric, and
   - the feature flag is enabled for the relevant scope.
2. The system shall allow a student to request AI feedback on their current text-entry draft.
3. The system shall return rubric-aligned feedback in a consistent structure:
   - per-criterion status,
   - top improvement areas,
   - concrete revision suggestions.
4. The system shall not write or alter official grades, rubric scores, or submission state.
5. The system shall enforce per-student/per-assignment request limits.
6. The system shall show user-visible error states for timeout/failure and allow retry.

### Out of scope (MVP)
- File upload analysis (PDF/DOC/image/media).
- Automatic grading, score prediction, or gradebook writeback.
- Instructor dashboards or analytics reporting UI.
- Multi-model/provider orchestration.
- Cross-assignment recommendation systems.

## 3) Non-functional requirements

### Performance
- P95 AI feedback response target: under 10 seconds for typical text-entry payloads.
- UI must provide immediate loading state and non-blocking interaction.

### Security and privacy (FERPA-adjacent)
- Student content sent to AI service must be minimized to necessary context only.
- Secrets and credentials must never appear in client-side code or logs.
- Raw submission text should not be stored in long-term logs by default.
- Data handling must align with institutional policy for student work and third-party processing.

### Accessibility
- Button and feedback UI must be keyboard accessible and screen-reader compatible.
- Status updates (loading/success/error) must be announced accessibly.
- Color is not the only signal for criterion status.

### Observability
- Capture request count, success/failure rate, latency, and rate-limit events.
- Add structured logs with request IDs for troubleshooting (without sensitive payload content).

### Reliability
- Fail closed and gracefully: on provider failure, show actionable retry message.
- Do not block normal submission workflow if AI feature is unavailable.

### Compatibility and deployment assumptions
- Must work behind existing Canvas feature-flag and role/permission patterns.
- Must preserve current assignment submission behavior for all users when disabled.
- Must support incremental rollout by account/course.

## 4) Codebase analysis using Lab 2 agent

### Hypotheses about where changes land
- Assignment submission UI surface (student-facing frontend components).
- Backend API/controller layer for a new feedback request endpoint.
- Service object boundary for external AI call and prompt/response shaping.
- Authorization/feature flag checks in existing Canvas permission patterns.
- Optional background/job path deferred unless synchronous path fails MVP targets.

### Agent-assisted findings to guide implementation patterns
- Canvas is organized with Rails app layers plus frontend UI packages; feature should follow existing split (UI trigger + backend service).
- Existing project guidance emphasizes plugin/feature-flag style rollout and role-aware behavior; this aligns with MVP gating.
- Repository scanning approach (index + targeted read/search) supports traceability without broad, risky edits.

### Representative paths/subsystems to inspect during implementation spike
- Student assignment submission page components.
- Rubric retrieval/display logic used in assignment context.
- API endpoint patterns for authenticated student actions.
- Service patterns for external integrations and timeout/error handling.
- Feature flag and permission enforcement utilities.

### Open questions (requires spike or stakeholder decision)
- Which institutional policy constraints apply to third-party AI processing of student drafts?
- Should prompt include only rubric criteria text or additional assignment instructions by default?
- What exact rate limit balances usefulness and cost for pilot cohorts?
- Is synchronous response acceptable for target courses, or is async job + polling required?

## 5) Testing and verification plan

### Unit-level expectations
- Feedback request eligibility logic (feature flag, role, rubric present, submission type).
- Payload shaping logic (rubric + draft + constraints).
- Response parser/validator for structured feedback format.
- Rate-limit decision logic and user-facing error mapping.

### Integration points
- Authenticated endpoint behavior for student role and assignment context.
- Rubric data retrieval integration for targeted assignments.
- External AI service client integration: timeout, retry, and provider error handling.

### Manual / exploratory checks
- Student role can request feedback only in eligible assignments.
- Teacher/admin experience remains unchanged.
- Edge cases: empty draft, very long draft, no rubric, feature disabled, provider outage.
- Regression check: normal submit flow still works whether AI succeeds or fails.

### Acceptance criteria mapped to functional requirements
- FR1/FR2: Eligible students can trigger feedback from submission UI.
- FR3: Returned feedback includes criterion status + prioritized suggestions.
- FR4: No grading/submission state mutation occurs from AI feedback call.
- FR5: Rate limits enforced with clear messaging.
- FR6: Failure states are recoverable and non-blocking.

### If automated testing is impractical
- Use a gated pilot rollout with checklist-based verification in staging.
- Enable detailed metrics and error monitoring before wider exposure.
- Keep kill switch (feature flag) ready for immediate rollback.