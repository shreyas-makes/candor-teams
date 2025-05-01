
Search files...
# 🔄 Blueprint & Prompt Plan (Rails 8 + Speedrail Edition)

Speedrail already ships with **Rails 8**, Hotwire, Tailwind, Devise, Active Admin, Delayed Job, RuboCop, RSpec, SimpleCov, Chartkick, etc.  
Therefore all “bootstrap” work is done; we only need to **extend** the template to deliver the Candor Teams feature-set.

Below is the updated, Speedrail-aware roadmap:

• Level 1 – Milestones  
• Level 2 – Iterations (≈ PR-sized)  
• Level 3 – Atomic TDD prompts (ready for a code-gen LLM)

All prompts reference Rails 8 conventions, Speedrail folder layout, and avoid re-installing gems that already exist.

---

## Level 1 – Milestones

| # | Milestone | New Work (Speedrail already handles the rest) |
|---|-----------|----------------------------------------------|
| M0 | Baseline Review | Verify Speedrail CI green, update README badges. |
| M1 | Teams & Roles | Team model, memberships, Pundit policy. |
| M2 | Feedback Core | Feedback model, weekly uniqueness, CRUD. |
| M3 | Invites | Token model, mailer, claim flow. |
| M4 | Matrix API | JSON aggregation for heat-map. |
| M5 | Heat-Map UI | D3 canvas, Stimulus shuffle, Turbo updates. |
| M6 | Notifications | Feedback mailer + Delayed Job retries. |
| M7 | Admin Enhancements | Active Admin pages for Team, Feedback. |
| M8 | Realtime | ActionCable broadcast & JS subscription. |
| M9 | Ops & Rate-Limit | Rack::Attack, Cloudflare proxy, Procfile tweaks. |

---

## Level 2 – Iterations

### M0 – Baseline Review
I0.1 Run `bin/dev && bundle exec rspec` in CI; ensure 100 % pass.  
I0.2 Add coverage badge upload; README tweak.

### M1 – Teams & Roles
I1.1 Generate `Team` model (uuid PK); add `team_id` to `User`.  
I1.2 Seed first Team; migrate all existing users into it.  
I1.3 Add Pundit `TeamPolicy`; wire into controllers.  
I1.4 ActiveAdmin `Team` resource (index + edit only).

### M2 – Feedback Core
I2.1 Generate `Feedback` model (author_id, recipient_id, score, comment, week_start).  
I2.2 DB uniqueness index + model validation.  
I2.3 `FeedbacksController#create/destroy`; routes + specs.

### M3 – Invites
I3.1 Model `Invite` (team_id, email, token, expires_at).  
I3.2 Mailer + Delayed job.  
I3.3 `InvitesController#create/claim`; feature spec.

### M4 – Matrix API
I4.1 SQL aggregation query returning `author_id`, `recipient_id`, `avg_score`.  
I4.2 JSON endpoint `/matrix.json`; request spec.

### M5 – Heat-Map UI
I5.1 Page `/heat-map`; Turbo-frame wrapper.  
I5.2 Stimulus `heatmap_controller` loads JSON & renders D3 grid.  
I5.3 Shuffle rows/cols; accessibility labels.

### M6 – Notifications
I6.1 `FeedbackMailer#new_feedback` (truncate 250 chars).  
I6.2 after_create_commit job; Delayed Job retries = 3.  
I6.3 RSpec mailer & job specs.

### M7 – Admin Enhancements
I7.1 ActiveAdmin `Feedback` resource (read-only).  
I7.2 Team resize/purge actions.  
I7.3 Custom filter examples (reference speedrail docs).

### M8 – Realtime
I8.1 `FeedbackChannel` broadcast Turbo replace.  
I8.2 Stimulus subscribes & re-draws grid.  
I8.3 System spec with ActionCable test adapter.

### M9 – Ops & Rate-Limit
I9.1 Rack::Attack 30 req/min; request spec.  
I9.2 Cloudflare middleware already exists – add tests.  
I9.3 Procfile adds `worker: bundle exec rake jobs:work`.  
I9.4 Review-app GitHub Action.

---

## Level 3 – Atomic Prompts

Below are **TDD prompts** for *new* work only.  
Paste each prompt sequentially into your LLM assistant.  
(Anything Speedrail already includes is **omitted**.)

> Each prompt is wrapped in ```text; ends by running `bundle exec rspec`; return only diffs + green output.

