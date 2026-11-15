# Beadlane preview

This is a provisional preview of a fork of [Beadazzle](https://github.com/Mosnar/beadazzle).
The Kanban, automatic sync, and preview packaging changes are separate commits;
the `feature/kanban-board` branch contains the standalone upstream-facing board.

Run `./script/build_beadlane_preview.sh` to create `dist/Beadlane Preview.app`.
It has its own bundle identifier and preferences, so it can run alongside the
installed Beadazzle app. Open a project explicitly the first time. This local
ad-hoc build has no update feed or signing key and does not auto-update.

The app's name and icon remain under discussion; some screens still identify
the original Beadazzle project. Its original license and attribution are included.

## Try the board

Open a Beads project, then use the list/board control above the issue list.
The board respects the current filters and sorting. Select a card to show its
details, or drag it to another status column. Status changes use Beadazzle's
existing confirmation and Beads command paths. The Gates view remains a list.

## Automatic sync

In a project, open Settings → Sync & Backup to choose an automatic sync mode.
The choice is saved per project and defaults to **Off**:

- **Pull only** periodically pulls remote changes without pushing local changes.
- **Pull and push** pulls, then pushes local changes to the configured Dolt remote.

When the workspace is active and ready to sync, the app checks approximately
every five minutes. A failed automatic sync pauses further attempts; review the
error and use **Resume** in Sync & Backup after resolving it. The setting also
shows the last successful automatic sync. Changing the mode stops a pending
automatic push when possible.

Automatic pushing to a Git-protocol Dolt remote should be used with a single
writer: concurrent pushes can damage shared history. Check the selected remote
and your team's workflow before enabling it. Manual sync remains available when
automatic sync is off.
