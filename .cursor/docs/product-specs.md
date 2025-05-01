Candor Teams is a one-workspace SaaS that lets members give one scored (–5…+5) free-text comment per colleague per UTC calendar week and visualises rolling averages in a colour-gradient heat-map. A Google-OAuth “magic-link” flow onboards users; emails (invite + instant notifications) are delivered through SendGrid via Action Mailer jobs queued with Delayed Job. Front-end interactivity relies on Stimulus/Hotwire, Tailwind utility CSS, and a D3-based canvas heat-map. All critical rules (rate-limit, purge-on-removal, numeric rounding, invite expiry) are enforced server-side.


Teams Heat-Map (Ruby on Rails + Postgres + Tailwind) — **Developer-Ready Specification**

## Functional Requirements

### Core use-cases
| Topic | Decision |
|-------|----------|
| **Auth** | Devise with Google OAuth integration; session stored in HTTP-only cookie. |
| **Feedback cadence** | One integer score (–5…+5) and mandatory text (≤ 3 000 chars) per sender → receiver per **UTC calendar week** (Mon 00:00 → Sun 23:59). |
| **Heat-map UI** | Turbo/Hotwire powered route; rows/cols shuffled on every load; colour via d3.interpolateRdYlGn mapping –5→#FF4D4D, 0→#FFFF66, +5→#33CC33; numeric average (rounded UP) printed in each cell for accessibility. |
| **Detail modal** | Hover/click reveals rolling average + comment list with author, timestamp, delete buttons for viewer-authored comments. |
| **Filters** | Preset "Last 3 months" + calendar range picker. |
| **Admin powers** | Active Admin interface to rename team, change `max_members`, regenerate/revoke 48h invite, purge members (deletes user & feedback). |
| **Emails** | Postmark for transactional emails with letter_opener for local preview. All invites + instant feedback notifications (first 250 chars) use mailers. |

---

## Non-Functional Requirements & Tech Stack
| Layer | Choice | Rationale / Source |
|-------|--------|--------------------|
| **Framework** | Ruby on Rails with Turbo/Hotwire for SPA-like experience. |
| **Data store** | PostgreSQL for production-ready database (region ≈ closest to majority users). |
| **Authentication** | Devise for user management (sessions, registration, etc.) |
| **Team security** | Application-level policies to enforce user access controls. |
| **Realtime** | ActionCable for live grid updates. |
| **Styling** | Tailwind CSS with Flowbite components. |
| **Form handling** | Rails form helpers with server-side validation. |
| **Testing** | RSpec for unit and integration tests with SimpleCov for coverage metrics. |
| **Background jobs** | Delayed Job for handling email notifications. |
| **Hosting** | Heroku with Cloudflare HTTPS (via lib/cloudflare_proxy.rb). |
| **Dev IDE** | Cursor: enable "/explain" to clarify Ruby/SQL, "/refactor" to improve code. |

---

## Architecture Overview
### Component view
```
Browser <—> Ruby on Rails Server (Heroku)
              ├─ Controllers                ←→ PostgreSQL
              ├─ Active Admin               ←→ PostgreSQL
              ├─ ActionCable                ←→ PostgreSQL (Realtime)
              └─ Background Jobs (Delayed)  → Postmark Email Service
```
Controller actions handle data mutations and trigger background jobs for email notifications. Turbo/Hotwire keeps the matrix render fast and responsive.

### Data flow
1. **Google OAuth** handled by Devise; session in cookie.  
2. **Client → Server** `feedback#create` validates input, writes row, commits.  
3. Post-create callback queues email notification job to recipient.  
4. ActionCable broadcasts change to subscribed clients for instant grid update.

---

## Database Schema
```ruby
create_table "teams", force: :cascade do |t|
  t.string "name", null: false
  t.uuid "admin_id", null: false
  t.integer "max_members", default: 1
  t.datetime "created_at", precision: 6, null: false
  t.datetime "updated_at", precision: 6, null: false
  t.index ["admin_id"], name: "index_teams_on_admin_id"
end

create_table "users", force: :cascade do |t|
  t.uuid "team_id"
  t.string "role", default: "member"
  t.string "email", null: false
  t.string "name"
  t.string "avatar_url"
  t.string "encrypted_password", null: false
  t.string "reset_password_token"
  t.datetime "reset_password_sent_at"
  t.datetime "remember_created_at"
  t.datetime "created_at", precision: 6, null: false
  t.datetime "updated_at", precision: 6, null: false
  t.index ["email"], name: "index_users_on_email", unique: true
  t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  t.index ["team_id"], name: "index_users_on_team_id"
end

create_table "feedbacks", force: :cascade do |t|
  t.uuid "author_id"
  t.uuid "recipient_id"
  t.integer "score", null: false
  t.text "comment"
  t.date "week_start", null: false
  t.datetime "created_at", precision: 6, null: false
  t.index ["author_id", "recipient_id", "week_start"], name: "index_feedbacks_on_author_recipient_week", unique: true
  t.index ["author_id"], name: "index_feedbacks_on_author_id"
  t.index ["recipient_id"], name: "index_feedbacks_on_recipient_id"
end

create_table "invites", force: :cascade do |t|
  t.uuid "team_id"
  t.string "email", null: false
  t.string "token"
  t.datetime "expires_at"
  t.datetime "created_at", precision: 6, null: false
  t.index ["team_id"], name: "index_invites_on_team_id"
  t.index ["token"], name: "index_invites_on_token", unique: true
end
```

**Access Control Example**
```ruby
# In FeedbacksController
before_action :authenticate_user!
before_action :validate_feedback_ownership, only: [:destroy]

def validate_feedback_ownership
  @feedback = Feedback.find(params[:id])
  redirect_to root_path, alert: "Not authorized" unless @feedback.author_id == current_user.id
end
```

---

## Routes and Controllers
| Method | Path | Purpose |
|--------|------|---------|
| **GET** `/` | Landing page (public). |
| **POST** `/teams` | Create team, set current user as admin. |
| **POST** `/invites` | Generate 48h token, send mail via Postmark. |
| **GET** `/invites/:token/claim` | Validate token, add user. |
| **POST** `/feedbacks` | Create/update sender→receiver for current week. |
| **DELETE** `/feedbacks/:id` | Delete own feedback. |
| **DELETE** `/admin/users/:id` | Admin purge member. |
| **PATCH** `/admin/teams/:id` | Rename or resize team. |
| **GET** `/matrix.json` | Returns JSON aggregated heat-map values. |

Controllers follow RESTful Rails conventions with strong parameter filtering.

---

## Error-Handling Strategy
| Layer | Failure | Mitigation |
|-------|---------|------------|
| **Form submission** | ActiveRecord validation fails → render form with errors. |
| **Auth** | No user session → Devise redirects to `/users/sign_in`. |
| **Database constraint** | Rescued with specific error message (e.g., "Already rated this week"). |
| **Email delivery** | Delayed Job retries 3× with exponential backoff; failures logged to Rollbar. |
| **Global** | Rails `rescue_from` handlers with friendly error views. |

---

## Security Considerations
* **Access control** through application-level checks.  
* **Sensitive data** encrypted at rest and in transit.  
* **Invite whitelist**: claim route checks email matches `invites.email` AND not expired.  
* Session cookie `SameSite=Lax`, `Secure`, max-age = 30 d.  
* **Rate-limit** via Rack::Attack middleware (IP 30 req/min).  

---

## Testing Plan
### Unit (RSpec)
* Model validations and constraints.
* Helper that converts scores to RGB.
* Authorization rules for various user roles.

### Feature/Integration (RSpec + Capybara)
* Authentication workflow protects sensitive routes.
* Weekly uniqueness constraint for feedback.

### End-to-End (RSpec + Capybara)
* User login → submits feedback → sees email preview (in development).
* Row/column randomisation verified across reloads.

### Performance
* Load testing with 30×30 peers; matrix JSON ≤ 150 ms cold start; DOM render ≤ 60 ms.

### Accessibility
* Lighthouse score ≥ 90; colour-contrast verified.

CI runs in **GitHub Actions**: `bundle exec rspec`, `bundle exec rubocop`, and SimpleCov reports.

---

## Development Workflow in Cursor IDE
1. **Clone repo**; set up database with `bin/rails db:setup`.
2. Use "/schema" to explore the database structure.
3. AI chat query: "explain this controller action" for deeper understanding.
4. "Automate refactor" on controllers to improve validation and error handling.

---

## Deployment Steps
1. Create Heroku app `heroku create`.
2. Set environment variables (`POSTMARK_API_TOKEN`, etc.).
3. Deploy with `git push heroku main`; background jobs auto-scale.

---

Ready for implementation — clone, run `bin/dev`, and build away!