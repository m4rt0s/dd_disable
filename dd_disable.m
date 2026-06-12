#include <CoreGraphics/CoreGraphics.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

extern CGError CGSConfigureDisplayEnabled(CGDisplayConfigRef config,
                                          CGDirectDisplayID display,
                                          bool enabled);

static CGDirectDisplayID find_builtin_display(void) {
    CGDirectDisplayID online[32];
    uint32_t count = 0;
    CGGetOnlineDisplayList(32, online, &count);

    for (uint32_t i = 0; i < count; i++) {
        if (CGDisplayIsBuiltin(online[i])) {
            return online[i];
        }
    }
    return kCGNullDirectDisplay;
}

static bool disable_display(CGDirectDisplayID did) {
    CGDisplayConfigRef config;
    CGError err = CGBeginDisplayConfiguration(&config);
    if (err != kCGErrorSuccess) {
        fprintf(stderr, "CGBeginDisplayConfiguration -> %d\n", err);
        return false;
    }

    err = CGSConfigureDisplayEnabled(config, did, false);
    if (err != kCGErrorSuccess) {
        fprintf(stderr, "CGSConfigureDisplayEnabled -> %d\n", err);
        CGCancelDisplayConfiguration(config);
        return false;
    }

    err = CGCompleteDisplayConfiguration(config, kCGConfigureForSession);
    if (err != kCGErrorSuccess) {
        fprintf(stderr, "CGCompleteDisplayConfiguration -> %d\n", err);
        CGCancelDisplayConfiguration(config);
        return false;
    }

    return true;
}

static bool enable_display(CGDirectDisplayID did) {
    CGDisplayConfigRef config;
    CGError err = CGBeginDisplayConfiguration(&config);
    if (err != kCGErrorSuccess) {
        fprintf(stderr, "CGBeginDisplayConfiguration -> %d\n", err);
        return false;
    }

    err = CGSConfigureDisplayEnabled(config, did, true);
    if (err != kCGErrorSuccess) {
        fprintf(stderr, "CGSConfigureDisplayEnabled -> %d\n", err);
        CGCancelDisplayConfiguration(config);
        return false;
    }

    err = CGCompleteDisplayConfiguration(config, kCGConfigureForSession);
    if (err != kCGErrorSuccess) {
        fprintf(stderr, "CGCompleteDisplayConfiguration -> %d\n", err);
        CGCancelDisplayConfiguration(config);
        return false;
    }

    return true;
}

static void display_changed(CGDirectDisplayID display,
                            CGDisplayChangeSummaryFlags flags,
                            void *userInfo) {
    (void)flags;
    (void)userInfo;
    CGDirectDisplayID bid = find_builtin_display();
    if (bid != kCGNullDirectDisplay) {
        disable_display(bid);
    }
}

static void print_displays(void) {
    CGDirectDisplayID online[32];
    uint32_t count = 0;
    CGGetOnlineDisplayList(32, online, &count);

    printf("Displays (%u):\n", count);
    for (uint32_t i = 0; i < count; i++) {
        CGRect bounds = CGDisplayBounds(online[i]);
        printf("  [0x%X] %s %s %s — %.0fx%.0f\n",
               online[i],
               CGDisplayIsBuiltin(online[i]) ? "built-in" : "external",
               CGDisplayIsActive(online[i]) ? "active" : "inactive",
               CGDisplayIsMain(online[i]) ? "main" : "",
               bounds.size.width, bounds.size.height);
    }
}

int main(int argc, char **argv) {
    if (argc > 1 && strcmp(argv[1], "list") == 0) {
        print_displays();
        return 0;
    }

    if (argc > 1 && strcmp(argv[1], "enable") == 0) {
        CGDirectDisplayID did;
        if (argc > 2) {
            did = (CGDirectDisplayID)strtoul(argv[2], NULL, 0);
        } else {
            did = find_builtin_display();
        }
        if (did == kCGNullDirectDisplay) {
            fprintf(stderr, "No display specified and no built-in found.\n");
            return 1;
        }
        if (enable_display(did)) {
            printf("Enabled display 0x%X\n", did);
            return 0;
        }
        return 1;
    }

    if (argc > 1 && strcmp(argv[1], "watch") == 0) {
        CGDirectDisplayID did = find_builtin_display();
        if (did != kCGNullDirectDisplay) {
            disable_display(did);
        }
        CGDisplayRegisterReconfigurationCallback(display_changed, NULL);
        CFRunLoopRun();
        return 0;
    }

    CGDirectDisplayID did = find_builtin_display();
    if (did == kCGNullDirectDisplay) {
        printf("No built-in display found.\n");
        return 0;
    }

    if (disable_display(did)) {
        printf("Disabled built-in display 0x%X\n", did);
    } else {
        fprintf(stderr, "Failed to disable display 0x%X\n", did);
        return 1;
    }

    return 0;
}
