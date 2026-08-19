# PostsCohort10

## Overview

PostsCohort10 is a SwiftUI content-and-careers app built for the revised networking assignment. It uses two free public APIs, follows MVVM, performs real network calls with `URLSession`, decodes JSON with `Codable`, and presents downloaded data in a professional three-tab interface.

## Tabs

- `Posts`: JSONPlaceholder social-style posts feed with post search and detail navigation.
- `Jobs`: Arbeitnow job board feed with search, remote filtering, and job details.
- `API`: Read-only API demonstration console for manually triggering each endpoint.

## APIs and Endpoints

JSONPlaceholder posts:

```text
https://jsonplaceholder.typicode.com/posts
```

JSONPlaceholder post by ID:

```text
https://jsonplaceholder.typicode.com/posts/{id}
```

Arbeitnow jobs:

```text
https://www.arbeitnow.com/api/job-board-api
```

Arbeitnow requires no API key.

## Guaranteed Network Calls

The normal root workflow starts both main API requests:

```text
RootTabView.task
→ PostsViewModel.loadPosts()
→ PostService.fetchPosts()
→ APIClient.fetch()

RootTabView.task
→ JobsViewModel.loadJobs()
→ JobService.fetchJobs()
→ APIClient.fetch()
```

`RootTabView` uses structured concurrency so posts and jobs load together without fake delays.

## Assignment Compliance

| Requirement | Evidence |
| ----------- | -------- |
| Free API data | JSONPlaceholder and Arbeitnow |
| MVVM | Separate models, services, ViewModels, and views |
| First network call | `PostService.fetchPosts()` |
| Second network call | `JobService.fetchJobs()` |
| Additional network call | `PostService.fetchPost(id:)` |
| URLSession | Shared `APIClient` |
| Codable | Post, Job, and JobResponse |
| Error handling | APIError and screen error states |
| Slow connection loading | Independent Posts and Jobs loading states |
| Retry support | Retry actions on both tabs |
| Data display | Posts feed and Jobs feed |

## MVVM Structure

```text
Models
├── Post.swift
├── Job.swift
└── JobResponse.swift

Networking
└── APIClient.swift

Services
├── PostService.swift
└── JobService.swift

ViewModels
├── PostsViewModel.swift
├── JobsViewModel.swift
└── APIConsoleViewModel.swift

Views
├── RootTabView.swift
├── PostsView.swift
├── PostRowView.swift
├── PostDetailView.swift
├── JobsView.swift
├── JobRowView.swift
├── JobDetailView.swift
└── APIConsoleView.swift

Documentation
└── Implementation Report.md
```

## Shared API Client

`APIClient` performs shared HTTP work for every endpoint. It uses `URLSession.shared.data(from:)`, validates HTTP responses, accepts only 200 through 299 status codes, rejects empty data, and decodes the requested `Decodable` type.

`APIError` distinguishes invalid URLs, request failures, invalid responses, unsuccessful status codes, decoding failures, invalid post IDs, and empty responses.

## Posts Features

- Loads all posts during normal app startup.
- Retries failed all-post requests.
- Supports pull-to-refresh.
- Searches title/body locally after keyboard Search submission.
- Searches exact numeric post IDs through `/posts/{id}` after keyboard Search submission.
- Does not call the API while the user is typing.
- Shows separate states for initial loading, initial failure, API empty response, numeric search loading, search failure, and text no-results.

## Jobs Features

- Loads Arbeitnow jobs during normal app startup.
- Shows total jobs and remote jobs.
- Supports local search by title, company, location, tags, and job type.
- Supports a remote-only filter.
- Cleans HTML descriptions into readable text without third-party packages.
- Opens validated original job URLs with `View Original Job`.
- Provides independent loading, error, empty, retry, refresh, and pull-to-refresh behavior.

## API Console

The API tab is a read-only demonstration console. It provides controls for:

- Load All Posts
- Load Post by ID
- Load Jobs
- Refresh All Endpoints

It displays endpoint name, HTTP method, loading status, success status, decoded record count, last successful refresh time, and readable errors. It does not claim administrative privileges and does not perform writes.

## Accessibility and Appearance

The app uses semantic colors, SF Symbols, readable cards, labels and hints for important controls, Dynamic Type-friendly layouts, and Light Mode/Dark Mode support.

## Running the Project

1. Open `PostsCohort10.xcodeproj` in Xcode.
2. Select an iOS Simulator.
3. Build and run.
4. Confirm the Posts and Jobs tabs load automatically.
5. Use the API tab to manually trigger each public endpoint.

## Screenshot Placeholders

Add screenshots before submission:

- Posts feed loaded
- Jobs feed loaded
- Numeric Post #25 search
- Local text post search
- Job search and remote filter
- API Console success statuses
- Error or retry state if available
- Light Mode and Dark Mode examples

## Known Issues

No known compile, API decoding, or view-model workflow issues after verification. Full manual Simulator interaction and screenshots remain to be completed before submission.
