import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var timer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupPopover()
        updateMenuBarTitle()
        scheduleUpdates()

        // Listen for wake notifications to update on system wake
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(systemDidWake),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.action = #selector(togglePopover)
            button.target = self
            button.title = "..." // Loading indicator
        }
    }

    private func setupPopover() {
        popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 400)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: MenuBarView())
    }

    @objc private func togglePopover() {
        if popover.isShown {
            popover.performClose(nil)
        } else if let button = statusItem.button {
            updateMenuBarTitle()
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)

            // Ensure popover closes when clicking outside
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    func updateMenuBarTitle() {
        guard let location = LocationStore.shared.primaryLocation else {
            statusItem.button?.title = "No location"
            return
        }

        Task {
            let comparison = await SolarService.shared.getComparison(for: location)
            await MainActor.run {
                statusItem.button?.title = comparison.menuBarText
            }
        }
    }

    private func scheduleUpdates() {
        // Update every hour
        timer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            self?.updateMenuBarTitle()
        }
    }

    @objc private func systemDidWake() {
        updateMenuBarTitle()
    }

    deinit {
        timer?.invalidate()
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }
}
