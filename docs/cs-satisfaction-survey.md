# Case Study: Satisfaction Survey

> **Quick Start**: A Satisfaction Survey is a chat message the backend can send when a case is configured to collect
> customer feedback. The SDK delivers it as a proactive-action event carrying a prompt and a survey URL; the UI module or your app
> presents it (typically in a blocking WebView) and the survey page itself handles submission. **Note**: Delivery
> works in both Live Chat and Messaging. Missed-survey recovery — replaying a survey that arrived while your app was
> disconnected — is currently **Live Chat only**.

## What is a Satisfaction Survey?

A Satisfaction Survey is a proactive feature that:

- **Arrives as a chat message** configured by the backend (an "Automation Trigger" job), not something your app requests
- **Carries a prompt, a URL and its thread** — `SatisfactionSurvey.prompt` and `SatisfactionSurvey.url` for a survey page presented, typically in a WebView, and `SatisfactionSurvey.threadId` identifying the conversation it belongs to
- **Is excluded from the regular chat transcript** — it's delivered as an event, not as a message in `ChatThread.messages`
- **Is delivered once, and only once, per thread and per device** — see [Delivery and Recovery Semantics](#delivery-and-recovery-semantics) below, this is the single most important behavior to understand before integrating

The SDK is not in the survey's data path: there is no JavaScript bridge, no submit hook, and no callback. The survey
page posts its own results directly to the backend.

## How It Works

1. **Backend Trigger**: An Automation Trigger job configured with a "Satisfaction Survey" action sends the survey as a chat message when a case is closed (or another configured condition is met)
2. **SDK Processing**: The SDK parses the message, excludes it from the transcript, and creates a `SatisfactionSurvey` object
3. **Event Delivery**: The SDK emits `ChatEvent.proactiveActionReceived(.satisfactionSurvey(survey))` to every active `chatProvider.events()` subscriber
4. **UI Display**: The UI module presents the survey automatically, or your app presents it (backend has no further role — see [Integration Options](#integration-options))
5. **Submission**: The customer submits the survey directly on the survey page. The SDK is never told the result — there is no answer event and no completion callback

**Recovery**: if a survey arrives (or was already the thread's last message) while your app is disconnected, the SDK
re-emits it the next time the Live Chat thread is recovered — but only if it has not already recorded that thread's
survey as delivered. See [Delivery and Recovery Semantics](#delivery-and-recovery-semantics).

## Prerequisites

Before using this feature, ensure that:

1. **Portal Configuration**: a Satisfaction Survey Automation Trigger job must be configured for the channel (Settings → Automation Triggers → a trigger with a "Satisfaction Survey" job)
2. **SDK Connection**: your app must be connected to the CXone service
3. **Live Chat, for recovery**: recovering a survey missed while disconnected is currently supported for Live Chat only

**Note**: no code changes or server API calls are needed to enable delivery — the survey type (Standard survey, 3rd
party provider, or Custom integration — see [Payload Variants](#payload-variants)) is entirely a portal configuration
choice.

## Confirmed Behavior

A few product decisions worth knowing before you build a custom presentation:

- **Loading**: the survey loads immediately when your presentation opens — there is no intermediate native button
  that has to be tapped first.
- **Closing**: presentation must offer an explicit close control (e.g. an X button). There is no auto-dismiss —
  the customer either closes the survey or submits it on the page itself.
- **Storage**: the SDK does not clear, snapshot, restore, or isolate the survey WebView's cookies or browser
  storage. The survey provider owns whatever it stores; your app performs no cleanup around it.
- **SDK boundary**: the SDK is not in the survey's data path. There is no JavaScript bridge, no submit hook, and no
  callback — the survey page posts its own results directly to the backend, and the SDK never sees the outcome.

## Integration Options

### Option 1: Use the UI Module (Recommended)

Using the UI module (`ChatCoordinator`) requires no additional setup:

```swift
let chatCoordinator = ChatCoordinator(chatProvider: chatProvider)

let content = chatCoordinator.content(threadId: nil, presentModally: true) { [weak self] in
    self?.dismiss(animated: true)
}

present(UIHostingController(rootView: content), animated: true)
```

The UI module:

- Receives satisfaction survey events internally
- Presents the survey in a blocking sheet hosting a WebView loaded with the survey URL, with the prompt as its heading
- Provides an explicit Cancel control — the survey does not auto-dismiss and cannot be swiped away
- Waits for a pre-chat or transcript form that is currently open to close before presenting the survey
- Recovers a missed Live Chat survey and presents it as soon as the chat UI is ready to show it
- Restricts the WebView's top-level navigation to the original survey origin, blocks HTTP/mixed content, and denies camera/microphone access
- In multithread Messaging, presents a survey only with its own conversation: a survey for a thread the customer is
  not viewing is held until they open that thread, the thread is marked unread in the thread list, and a local
  notification that opens the thread is scheduled. A held survey lasts for the current chat session only.

Don't also present the survey yourself when using `ChatCoordinator` — your app would show it a second time.

### Option 2: Custom UI Implementation

If you build your own chat UI on `CXoneChatSDK` directly, handle presentation yourself by subscribing to
`chatProvider.events()`. This is where the delivery contract in
[Delivery and Recovery Semantics](#delivery-and-recovery-semantics) matters most: your app is the only thing
standing between a delivered survey and losing it permanently.

#### Step 1: Handle the Survey Event

```swift
Task { [chatProvider] in
    for await event in chatProvider.events() {
        if case .proactiveActionReceived(.satisfactionSurvey(let survey)) = event {
            // Present your custom survey UI right away - or, in multithread, keep it until survey.threadId
            // is on screen. Never drop it: see the delivery warning below
            presentCustomSatisfactionSurvey(survey)
        }
    }
}
```

**Subscribe before connecting.** As with any proactive-action event, a survey emitted with no active subscriber is
lost — `EventBroadcaster` does not replay past events to a subscriber that joins later. Subscribe via `events()`
before calling `connect()`.

#### Step 2: Present the Survey

**Example using a WebView** (you can implement any custom UI approach):

```swift
func presentCustomSatisfactionSurvey(_ survey: SatisfactionSurvey) {
    // Load survey.url in your WebView, with survey.prompt as the popup's title/heading.
    // In multithread channels, use survey.threadId to present it with its own conversation.
    // Recommended navigation policy, mirroring the UI module's own posture:
    //   - accept only `https` requests
    //   - keep top-level navigation on the original survey origin; block navigation away
    //   - allow normal cross-origin HTTPS subresources the survey page itself loads
    //   - deny camera and microphone access
    // The URL is supplied by the backend and is not validated or sanitised by the SDK.
}
```

There is no `dismiss`, `submit`, or completion callback to call afterward — closing your presentation is the entire
integration surface. The survey page posts its own results directly.

## Payload Variants

The Automation Trigger job's "Satisfaction survey type" setting has three options — **Standard survey**, **3rd party
provider**, and **Custom integration** — but all three produce the identical underlying payload shape. Only how the
survey URL is populated differs (a NICE-generated page, a templated 3rd-party URL, or a tenant-defined custom
endpoint). No special handling is needed per type: `SatisfactionSurvey.url` is whatever the configured type resolved
to, and the SDK's parsing is URL-shape-agnostic.

## Delivery and Recovery Semantics

This is the part most likely to surprise integrators moving from other proactive-action events, so it's worth being
explicit:

- **"Delivered" means the SDK emitted the event to your app — not that your app presented it, and not that the
  customer saw or answered it.** The SDK records delivery, keyed by thread, the moment it emits the event.
- **There is no second delivery for that thread, for all practical purposes.** Unlike some other proactive events, a
  satisfaction survey that your app fails to present does not come back on a later recovery, a later app launch, or
  a retry of any kind. If your integration drops it, treat it as gone — delivery state is tracked per-thread in a
  bounded, capacity-50 store, so on a long-lived install the oldest entries can eventually be evicted and a survey
  could theoretically be re-delivered, but don't rely on that as a recovery path; it exists to bound local storage,
  not to give you a second chance.
- **There is no confirmation call back to the SDK.** Your app does not tell the SDK it presented the survey — there
  is nothing to call. Recording happens purely on emission.
- **Recovery is Live Chat only, for now.** If a survey was the last message on a Live Chat thread — whether it was
  sent while your app was disconnected or was already the thread's newest message before that — the SDK re-emits
  it once the thread is next recovered, as long as it hasn't already recorded that thread's survey as delivered.
  Messaging recovery is not yet supported; don't rely on a missed Messaging survey being replayed.
- **Delivery state is local to the device.** It's cleared on sign-out along with the rest of the SDK's local storage.
  As a consequence, the same survey can be delivered again on a second device signed into the same account — this is
  an accepted, known limitation, not a bug.
- **There is no analytics event.** The SDK does not report a survey as displayed or clicked to the backend.

**Practical takeaway for custom UI integrators**: present the survey as soon as you receive the event — or, in
multithread, keep it until the customer opens the thread `survey.threadId` identifies, then present it. There is no
safety net if you drop it.

## Troubleshooting

### Survey Not Showing?

**If you're using the UI module (`ChatCoordinator`)**:
1. **Multithread**: the survey appears only once the customer opens the thread it belongs to — check the thread list
   for the unread thread or the local notification
2. **Already delivered**: a survey is presented once per thread and device — see [Delivery and Recovery Semantics](#delivery-and-recovery-semantics)
3. **Check portal configuration**: a Satisfaction Survey Automation Trigger job must be configured for the channel

**For Custom UI implementation:**
1. **Check events subscription**: ensure your `for await event in chatProvider.events()` loop is running, started
   *before* `connect()`, and handles `.proactiveActionReceived(.satisfactionSurvey(...))`
2. **Verify connection**: make sure the SDK is connected
3. **Check portal configuration**: a Satisfaction Survey Automation Trigger job must be configured for the channel

### Survey Recovered Once, Then Never Again on the Same Thread?

This is expected, not a bug — see [Delivery and Recovery Semantics](#delivery-and-recovery-semantics). Once the SDK
has emitted a thread's survey, it will not emit it again on that device.

### Survey Missing After a Messaging Recovery?

Also expected for now — recovery is Live Chat only. A survey missed while disconnected on a Messaging thread is not
currently replayed.

## Summary

The satisfaction survey feature lets integrators present backend-configured feedback surveys. The UI module handles
presentation, recovery, multithread routing, and navigation security automatically with no additional code required,
and is the recommended approach for most integrators. Custom UI integrators get the same delivery guarantee, but take
on full responsibility for presenting the survey the moment it arrives — the SDK provides no second chance.

## Sample Implementation

For a complete implementation reference, see:

- [Sample Application](https://github.com/nice-devone/nice-cxone-mobile-sample-ios)
- [UI Module](https://github.com/nice-devone/nice-cxone-mobile-ui-ios)
