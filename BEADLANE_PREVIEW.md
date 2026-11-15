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
