/***
 * This transformation allows events to reach a downstream destination only if a specific property
 * contains certain values, e.g., allow only View, or Purchase events, or send
 * certain event types to a particular destination, e.g., identify or track, or only send events that do not have
 * tracking plan to a specific destination
***/

export function transformEvent(event, metadata) {
    const type = event.type;
    console.log(type);
    const allowlist2 = ["identify", "track"]; // Edit allowlist contents
    if (!type || !allowlist2.includes(type)) return;

    const property = event.event; // Edit event name
    const allowlist = ["View", "Purchase"]; // Edit allowlist contents
    if (!property || !allowlist.includes(property)) return;

    // use anonymousid as userid if userid is blank
    if (event.userId === '') {
        event.userId = event.anonymousId;
    }
    return event;
}