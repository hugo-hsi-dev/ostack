# Live run

Use to exercise a running app, service, or CLI through its real user path and keep proof of the result. Inputs are the journeys to drive, the project's launch, doctor, drive, and cleanup instructions, and where evidence goes.

1. **Launch to a usable state.** Follow the project's launch model: one long-lived instance driven serially for servers and UIs, or a fresh isolated session per drive for short-lived CLIs. Ready means usable, not just a process that answers. Drive only instances you started; never double-drive a shared one.
2. **Doctor before driving.** Run the read-only health check before the first drive, on each fresh session, and again after any failed or surprising drive. When the check cannot see the failure, such as a wedged UI on a healthy process, reset to a known state or relaunch.
3. **Drive the real path.** Use the user-facing interface, not internal setters or test-only endpoints. Capture the action and the resulting state, and check side effects (files, rows, messages) as well as what is visible.
4. **Keep the evidence.** Store proof at a named location and confirm it still exists after every cleanup.
5. **Clean up what you started.** Remove failed-iteration residue as you go, whether the session is stuck, exited, or shared; for a shared instance, clean the residue, not the instance. Tear down after the last drive, including re-drives after fixes. Never kill by process name.
6. **Classify each failure.** Wrong or missing description of the user path is doc drift. Working behavior the harness cannot drive is a harness gap. Broken app behavior is a product defect. A journey blocked by auth, entitlement, OS, or external state is unreachable only when you name the prerequisite and the route attempted. Re-drive anything a correction touched.

Report each journey as verified, failed, or blocked, with evidence locations and the failure class.
