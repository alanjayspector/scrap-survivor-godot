# Device Support Matrix

**Last Updated**: 2025-11-22
**Status**: Approved by Product Owner
**Decision Source**: [Expert Panel Consultation](expert-consultations/device-compatibility-matrix-consultation.md)

---

## Supported Devices

### Minimum Requirements

- **Minimum Device**: iPhone 12 (2020)
- **Minimum iOS**: iOS 15.0
- **Market Coverage**: ~88% of active iOS devices
- **Support Window**: 5 years (2020-2025)

### Supported iPhone Models

| Generation | Models | Screen Size | Priority |
|------------|--------|-------------|----------|
| **iPhone 17** (2025) | 17, 17 Pro, 17 Pro Max | 6.1-6.9" | High |
| **iPhone 16** (2024) | 16, 16 Pro, 16 Pro Max | 6.1-6.9" | High |
| **iPhone 15** (2023) | 15, 15 Pro, 15 Pro Max | 6.1-6.7" | High |
| **iPhone 14** (2022) | 14, 14 Pro, 14 Pro Max | 6.1-6.7" | High |
| **iPhone 13** (2021) | 13, 13 mini, 13 Pro, 13 Pro Max | 5.4-6.7" | High |
| **iPhone 12** (2020) | 12, 12 mini, 12 Pro, 12 Pro Max | 5.4-6.7" | High |

**Total Supported**: 6 device generations (2020-2025)

---

## Unsupported Devices

### Not Supported (Pre-2020)

❌ iPhone 11 and older (2019 and earlier)
❌ iPhone XS/XR (2018)
❌ iPhone X/8 (2017)
❌ iPhone 7 and older

**Rationale**: Only ~12% of market, high development burden, performance compromises. See [expert consultation](expert-consultations/device-compatibility-matrix-consultation.md) for full analysis.

---

## Test Matrix

### Primary Test Devices

**Physical Devices**:
1. **iPhone 15 Pro Max** (6.7") - Current flagship, primary development device

**Simulators**:
1. **iPhone 12 mini** (5.4") - Smallest supported device
2. **iPhone 13** (6.1") - Most common size (optional)

### Screen Size Coverage

| Category | Size | Representative Device | Test Priority |
|----------|------|----------------------|---------------|
| **Compact** | 5.4" | iPhone 12/13 mini | High (smallest) |
| **Standard** | 6.1" | iPhone 12/13/14/15/16 | Medium |
| **Large** | 6.7-6.9" | iPhone 15/16/17 Pro Max | High (largest) |

**Minimum**: Test on 5.4" (iPhone 12 mini) and 6.7" (iPhone 15 Pro Max)

---

## Performance Targets

### Frame Rate

- **Target**: 60 FPS
- **Minimum**: 60 FPS on all supported devices
- **Guaranteed**: Yes (all devices have sufficient GPU power)

### Load Times

- **Game Launch**: < 3 seconds
- **Scene Transition**: < 1 second
- **Character Selection**: Instant

### Battery Life

- **Target**: 3-4 hours continuous gameplay
- **Expected**: All devices meet target (efficient Metal rendering)

---

## Feature Requirements

### Hardware Features (All Supported Devices Have)

✅ **Haptic Engine** - Full tactile feedback support
✅ **Metal 3** - Advanced GPU features
✅ **A14 Bionic or newer** - Performance headroom
✅ **Face ID or Touch ID** - Secure authentication
✅ **Modern screen ratio** (19.5:9) - Consistent layouts

### iOS API Requirements

✅ **iOS 15+ APIs** - All modern frameworks available
✅ **GameController framework** - MFi controller support
✅ **CoreHaptics** - Advanced haptic patterns
✅ **Metal 3** - Shader features, optimizations

---

## Safe Area Specifications

### Notch/Dynamic Island Handling

| Device Type | Safe Area Top | Safe Area Bottom | Notes |
|-------------|---------------|------------------|-------|
| **Notch** (iPhone 12-14) | 47pt | 34pt | Standard notch |
| **Dynamic Island** (15 Pro+) | 59pt | 34pt | Larger cutout |
| **No Notch** (iPhone 12 mini) | 47pt | 34pt | Standard |

**Strategy**: Design for 59pt top safe area (largest constraint)

---

## App Store Requirements

### Metadata

**Compatibility**:
```
Requires iOS 15.0 or later.
Compatible with iPhone 12 and newer.
```

**Description**:
```
System Requirements:
- iPhone 12 or newer
- iOS 15.0 or later
- 500MB free storage
```

### Export Settings (Godot)

**iOS Export Preset**:
```
[ios]
minimum_version = "15.0"
targeted_device_family = "1"  # iPhone only
architectures = "arm64"
```

---

## Decision Rationale

### Why iPhone 12+ (iOS 15+)?

**Market Coverage**: 88% of active iOS devices
- Optimal balance between reach and development effort
- Industry standard for premium mobile games (2025)

**Performance**: Guaranteed 60fps
- A14 Bionic or newer (ample headroom)
- Metal 3 full support
- No thermal throttling concerns

**Development Efficiency**: Manageable test matrix
- 6 device generations (not 10+)
- Consistent screen ratios (19.5:9)
- Full feature parity across all devices

**Quality**: No compromises needed
- All devices support full feature set
- Premium experience on all supported devices
- No performance tuning for legacy hardware

**Industry Alignment**: Matches competitors
- Brotato: 7-year support (iPhone XS+)
- Slay the Spire: 6-year support (iPhone 11+)
- Hades: 5-year support (iPhone 12+) ← **Our approach**

---

## Version History

| Date | Decision | Rationale |
|------|----------|-----------|
| 2025-11-22 | iPhone 12+ (iOS 15+) | Expert panel recommendation, industry standard |

---

## Related Documents

- **Expert Consultation**: [device-compatibility-matrix-consultation.md](expert-consultations/device-compatibility-matrix-consultation.md)
- **Mobile UI Spec**: [mobile-ui-spec.md](ui-standards/mobile-ui-spec.md)
- **Testing Guide**: [week16-phase3.5-validation-guide.md](week16-phase3.5-validation-guide.md)

---

**Approved By**: Alan (Product Owner)
**Consultation**: Sr. Product Manager + Sr. Mobile Game Designer
**Confidence**: 95/100
**Status**: Active
