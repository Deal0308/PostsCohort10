# PostsCohort10

PostsCohort10 is a SwiftUI content-and-careers app for the revised networking assignment. It displays downloaded data from two free public APIs, follows MVVM, uses `URLSession` and `Codable`, and presents the data in a polished three-tab interface.

## What the App Does

The app loads a social-style posts feed from JSONPlaceholder and a careers feed from The Muse Jobs API during the normal startup workflow. Users can search posts, look up an exact post number from the API, browse The Muse job listings, open detail screens, refresh failed requests, and use a read-only API Console to trigger each endpoint manually.

## APIs

JSONPlaceholder posts:

```text
https://jsonplaceholder.typicode.com/posts
```

JSONPlaceholder post by ID:

```text
https://jsonplaceholder.typicode.com/posts/{id}
```

The Muse jobs:

```text
https://www.themuse.com/api/public/jobs?page=1
```

No API key, token, secret, or authentication header is required.

## Guaranteed Network Calls

The root tab view starts the two required primary API requests together:

```text
RootTabView
→ PostsViewModel.loadPosts()
→ PostService.fetchPosts()
→ APIClient.fetch()
→ URLSession

RootTabView
→ JobsViewModel.loadJobs()
→ JobService.fetchJobs()
→ APIClient.fetch()
→ URLSession
```

Numeric post search adds an extra request only after the user submits a search, such as `/posts/25`. Text search remains local and does not call the network while typing.

## Assignment Compliance

| Requirement | Evidence |
| ----------- | -------- |
| Free API data | JSONPlaceholder and The Muse |
| MVVM | Separate models, services, ViewModels, and views |
| First network call | `PostService.fetchPosts()` |
| Second network call | `JobService.fetchJobs()` |
| Additional call | `PostService.fetchPost(id:)` |
| URLSession | Shared `APIClient` |
| Codable | Post, Job, JobResponse, and supporting models |
| Error handling | `APIError` and screen-specific states |
| Rate limiting | Dedicated HTTP 429 handling |
| Slow connection loading | Independent loading states |
| Retry controls | Posts and Jobs retry actions |
| Data display | Posts feed and The Muse jobs feed |

## Features

- Three-tab interface: Posts, Jobs, and API Console.
- JSONPlaceholder posts feed with modern cards and post details.
- Post search by title and body, plus exact post-number API lookup.
- The Muse jobs feed with job cards, search, details, cleaned HTML descriptions, and external links.
- Read-only API Console with buttons for all posts, post by ID, jobs, and refresh all endpoints.
- Independent loading, error, empty, and retry states for Posts and Jobs.
- HTTP 429 rate-limit handling with a readable wait message when `Retry-After` is available.
- Pull-to-refresh on data feeds.
- Light Mode and Dark Mode support using semantic colors.
- Accessibility labels, hints, readable ordering, and Dynamic Type-friendly layouts.

## MVVM Structure

- Model: `Post`, `Job`, `JobResponse`, `JobAttribute`, `JobReferences`, and `JobCompany` represent decoded API data.
- Networking: `APIClient` performs shared `URLSession` requests, HTTP validation, rate-limit handling, empty-response checks, and JSON decoding.
- Service: `PostService` and `JobService` define endpoint-specific API calls.
- ViewModel: `PostsViewModel`, `JobsViewModel`, and `APIConsoleViewModel` own screen state and call services.
- View: SwiftUI views display state, handle user interaction, and never perform networking directly.

## Project Structure

```text
PostsCohort10
├── Models
│   ├── Post.swift
│   ├── Job.swift
│   └── JobResponse.swift
├── Networking
│   └── APIClient.swift
├── Services
│   ├── PostService.swift
│   └── JobService.swift
├── ViewModels
│   ├── PostsViewModel.swift
│   ├── JobsViewModel.swift
│   └── APIConsoleViewModel.swift
├── Views
│   ├── RootTabView.swift
│   ├── PostsView.swift
│   ├── PostRowView.swift
│   ├── PostDetailView.swift
│   ├── JobsView.swift
│   ├── JobRowView.swift
│   ├── JobDetailView.swift
│   └── APIConsoleView.swift
├── Assets.xcassets
├── ContentView.swift
├── PostsCohort10App.swift
└── README.md
```

## Search and Filtering

Posts support two search paths. Text queries search already-downloaded post titles and body content locally. Numeric queries are submitted explicitly with the keyboard Search action or search button and request the exact post from JSONPlaceholder by ID.

Jobs search is fully local. It searches The Muse job title, company name, location names, category names, experience level names, and tag names without making extra API requests.

## Error and Loading Behavior

`APIClient` distinguishes invalid URLs, transport failures, invalid responses, HTTP 429 rate limits, other non-2xx status codes, empty responses, decoding failures, and invalid post IDs. Each feed has its own loading and error state so one API failure does not erase successful data from the other tab.

If content already exists during a refresh, the app keeps the current content visible and disables duplicate refresh actions while the request is running.

## API Console

The API Console is a read-only demonstration screen. It provides controls for:

- Load All Posts
- Load Post by ID
- Load Jobs
- Refresh All Endpoints

It reports endpoint names, HTTP method, URL, loading status, success counts, last successful refresh time, and readable errors. It does not provide admin access and does not perform write operations.

## Opening and Running

1. Open `PostsCohort10.xcodeproj` in Xcode.
2. Select an iOS Simulator destination.
3. Build and run the app.
4. Confirm the Posts and Jobs tabs load downloaded API data.
5. Use the API Console tab to manually trigger each endpoint.

## Screenshots

Add simulator screenshots before submission:

- Posts feed in Light Mode
- Posts feed in Dark Mode
- Post search or post-number lookup
- Jobs feed
- Job detail screen
- API Console
- Error or loading state if required by the instructor

No screenshots are included in this repository yet.

## Known Issues

No known functional issues. Public APIs can still fail because of connectivity problems, temporary service outages, rate limiting, or changed response formats. The app shows readable error states and retry controls for those cases.
