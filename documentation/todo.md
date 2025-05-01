# Candor Teams Project Checklist

## Setup and CI (Prompt 1)
- [x] Add "Run RSpec" step to `.github/workflows/ci.yml` if missing
- [x] Create smoke spec in `spec/smoke/speedrail_spec.rb` to verify Rails version
- [x] Run and verify tests pass with `bundle exec rspec`

## Team Model (Prompt 2)
- [x] Generate Team model: `rails g model Team name:string max_members:integer admin_id:uuid`
- [x] Add team_id to Users: `rails g migration AddTeamIdToUsers team:uuid:index`
- [x] Set up associations:
  - [x] Team has_many :users
  - [x] User belongs_to :team, optional: true
- [x] Add validations to Team model:
  - [x] name (presence)
  - [x] max_members (>=1)
- [x] Create model specs for validations and associations
- [x] Run migrations and tests

## Team Seeding (Prompt 3)
- [x] Update `db/seeds.rb` to create 'Demo' team
- [x] Attach existing users to the team
- [x] Create seed spec that verifies Team.count == 1
- [x] Run and verify tests

## Team Authorization (Prompt 4)
- [x] Generate team policy: `rails g pundit:policy team`
- [x] Implement `TeamPolicy#update?` to allow only team admin
- [x] Create policy spec verifying admin allowed, member denied
- [x] Run and verify tests

## Admin Interface (Prompt 5)
- [x] Generate Admin resource: `rails g active_admin:resource Team`
- [x] Permit :name and :max_members params
- [x] Remove :destroy action
- [x] Create system spec that tests admin can edit team name
- [x] Run and verify tests

## Feedback Model (Prompt 6)
- [ ] Generate Feedback model: `rails g model Feedback author_id:uuid recipient_id:uuid score:integer comment:text week_start:date`
- [ ] Add validations:
  - [ ] score (inclusion in -5..5)
  - [ ] comment (presence, length 1-3000)
- [ ] Set up associations:
  - [ ] belongs_to :author, class_name: 'User'
  - [ ] belongs_to :recipient, class_name: 'User'
- [ ] Create spec for validations
- [ ] Run and verify tests

## Feedback Controller (Prompt 8)
- [ ] Generate controller: `rails g controller Feedbacks`
- [ ] Implement actions:
  - [ ] create (upsert for current week)
  - [ ] destroy (only for current_user authored)
- [ ] Set up strong params for :recipient_id, :score, :comment
- [ ] Add routes: `resources :feedbacks, only: %i[create destroy]`
- [ ] Create request specs for success/failure cases
- [ ] Run and verify tests

## Invite Model & Mailer (Prompt 10)
- [x] Generate Invite model: `rails g model Invite team:references{uuid} email:string token:string:index expires_at:datetime`
- [x] Add before_create callback to generate SecureRandom.uuid for token
- [x] Add email validation for presence and format
- [x] Implement `expired?` helper method
- [x] Create spec that verifies token uniqueness
- [x] Generate mailer: `rails g mailer InviteMailer new_invite`
- [x] Configure to deliver later with Delayed Job
- [x] Create spec that checks job enqueuing and mail.to
- [x] Run and verify tests

## Invite Controller (Prompt 11)
- [x] Generate Invites controller: `rails g controller Invites`
- [x] Implement create action to build invite and send mail
- [x] Implement claim action to handle token, join team, revoke invite
- [x] Add routes:
  ```ruby
  resources :invites, only: :create do
    get 'claim/:token', on: :collection, action: :claim, as: :claim
  end
  ```
- [x] Create feature spec for admin sends invite, visitor claims
- [x] Update dashboard view with invite form
- [x] Update registrations controller to handle invitation tokens
- [x] Run and verify tests

## Feedback Matrix (Prompt 12)
- [ ] Add route: `get '/matrix', to: 'feedbacks#matrix'`
- [ ] Implement matrix action in FeedbacksController
- [ ] Implement `.matrix_for(users)` SQL method in Feedback model
- [ ] Create request spec to verify endpoint and JSON response
- [ ] Run and verify tests

## Additional Tasks
- [ ] Implement Team association fix (based on team.rb seed support file)
- [ ] Address any other prompts from the remaining .cursor/docs/prompts files
- [ ] Test all functionality end-to-end
- [ ] Run full test suite and fix any failing tests

## Notes
- When implementing each feature, review existing code patterns
- Follow established conventions for models, controllers, and specs
- Keep commit messages clear and descriptive
- Document any special considerations or assumptions made 