# TCDD App

A Rails 8 application for organizing and managing community clean-up events, with a focus on tracking cigarette litter collection. The app enables participants to register for clean-up events, track their contributions in real-time, and view collective impact statistics.

## Features

- **Clean-Up Event Management**: Create, schedule, and manage community clean-up events with status workflows (created → registration_enabled → started → ended)
- **Participant Registration**: Participants can register for events via a simple `/go` URL, supporting group registrations with people count
- **Real-Time Updates**: Live updates using Turbo Streams/ActionCable for participant counts, cigarette tallies, and status changes
- **Cigarette Counter**: Participants can track their collected cigarettes during an event
- **Scoreboard**: Live leaderboard showing top contributors
- **Admin Dashboard**: Manage events, view participants, manually add cigarette counts, and control event status
- **QR Code Generation**: Generate QR codes for easy event registration sharing
- **Calendar Integration**: Export clean-up events to calendar applications
- **Auto-Scheduling**: Events automatically start at scheduled time and end after 24 hours

## Tech Stack

- **Ruby**: 3.4.7
- **Rails**: 8.0.1
- **Database**: SQLite3
- **Frontend**: 
  - Hotwire (Turbo + Stimulus)
  - Tailwind CSS
  - Importmap for JavaScript modules
- **Background Jobs**: Solid Queue
- **Caching**: Solid Cache
- **WebSockets**: Solid Cable
- **Deployment**: Docker with Kamal

## Getting Started

### Prerequisites

- Ruby 3.4.7 (see `.ruby-version`)
- Bundler
- SQLite3

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd tcdd

# Install dependencies
bundle install

# Set up the database
bin/rails db:setup

# Start the development server
bin/dev
```

This starts both the Rails server and Tailwind CSS watcher (via `Procfile.dev`).

### Running Tests

```bash
# Run all tests (unit + system)
bin/rails test test:system

# Run only unit tests
bin/rails test

# Run only system tests
bin/rails test:system
```

### Code Quality

```bash
# Run RuboCop linter
bin/rubocop

# Run Brakeman security scan
bin/brakeman
```

## Project Structure

### Models

- **CleanUp**: Represents a clean-up event with name, description, status, location, and scheduled start time
- **Participant**: A person or group who participates in clean-ups (with `people_count` for groups)
- **Participation**: Join model linking participants to clean-ups, tracks status (registered → started → returned) and cigarettes collected
- **PageVisit**: Tracks daily page visits for analytics

### Key Routes

| Route | Description |
|-------|-------------|
| `/go` | Public registration page for active clean-up |
| `/go/:id` | Participant's view during an active clean-up |
| `/admin` | Admin dashboard |
| `/admin/clean_ups` | Manage clean-up events |
| `/qr` | Generate QR code for sharing |
| `/farewell` | Thank you page after participation |

### Event Status Workflow

1. **created**: Event is set up but not visible to public
2. **registration_enabled**: Participants can register; auto-starts at `starts_at` time
3. **started**: Event is active; participants can track cigarette collection
4. **ended**: Event is complete; final statistics are locked

## Deployment

The application uses Docker for containerized deployment with GitHub Actions CI/CD:

- **Production**: Deploys on push to `main` branch
- **Staging**: Deploys on push to `staging` branch

### CI Pipeline

1. **Security Scan**: Brakeman security analysis
2. **Lint**: RuboCop code style checks
3. **Test**: Full test suite including system tests
4. **Deploy**: Docker build and deployment (if all checks pass)

### Environment Variables

| Variable | Description |
|----------|-------------|
| `SECRET_KEY_BASE` | Rails secret key |
| `RAILS_MASTER_KEY` | Credentials master key |
| `RAILS_ENV` | Environment (development/staging/production) |

## Configuration

- **Database**: `config/database.yml` - SQLite for all environments
- **Routes**: `config/routes.rb`
- **Credentials**: `config/credentials.yml.enc` (encrypted)
- **Tailwind**: `tailwind.config.js`

## Contributing

1. Create a feature branch from `main`
2. Make your changes
3. Ensure tests pass: `bin/rails test test:system`
4. Ensure linting passes: `bin/rubocop`
5. Open a pull request
 
