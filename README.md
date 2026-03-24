# Cigarette Cleanup Tracker

A Rails application designed to track cigarette cleanup events, manage participants, and visualize cleanup statistics.

## Key Features

*   **CleanUps**: Organize and manage cleanup events with details like location, start time, and status.
*   **Participation Tracking**: Track participants joining specific cleanup events.
*   **Statistics**: Record the number of cigarettes collected and steps taken.
*   **Admin Interface**: Manage cleanups and participations securely.
*   **Public Access**: Allow users to register for cleanups and view their participation details.

## Technology Stack

*   **Ruby**: 3.4.7
*   **Framework**: Rails 8.0.1
*   **Database**: SQLite (Production & Development)
*   **Styling**: Tailwind CSS (via `tailwindcss-rails`)
*   **Deployment**: Kamal
*   **Frontend**: Hotwire (Turbo & Stimulus), Importmaps

## Setup & Development

### Prerequisites

Ensure you have Ruby 3.4.7 installed.

### Installation

1.  Clone the repository.
2.  Run the setup script to install dependencies and prepare the database:

    ```bash
    bin/setup
    ```

### Running the Server

Start the extensive development server (Rails + Tailwind watcher, etc.):

```bash
bin/dev
```

Visit `http://localhost:3000` to view the application.

## Usage

*   **Admin Access**: Navigate to `/admin` (redirects to `/admin/clean_ups`) to manage cleanup events.
*   **Public Registration**: Users can access participation links (e.g., `/go`) to register for an event.
*   **QR Codes**: Generate QR codes for easy event access via `/qr`.

## Deployment

The application is configured for deployment using [Kamal](https://kamal-deploy.org/). Refer to `config/deploy.yml` for specific deployment configurations.
