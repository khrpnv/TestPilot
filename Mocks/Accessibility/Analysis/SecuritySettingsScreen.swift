import SwiftUI

struct SecuritySettingsScreen: View {
    @State private var biometricsOn = true
    @State private var alertsOn = false
    @State private var selectedMethod = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Security")
                    .font(.largeTitle.weight(.bold))

                Text("Manage how your account stays protected.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 16) {
                    Text("Sign in")
                        .font(.headline)

                    HStack {
                        Image(systemName: "faceid")
                            .font(.title2)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Biometric login")
                                .font(.subheadline.weight(.medium))

                            Text(biometricsOn ? "On" : "Off")
                                .font(.caption)
                                .foregroundStyle(biometricsOn ? .green : .secondary)
                        }

                        Spacer()

                        ZStack(alignment: biometricsOn ? .trailing : .leading) {
                            Capsule()
                                .fill(biometricsOn ? Color.green : Color.gray.opacity(0.3))
                                .frame(width: 56, height: 32)

                            Circle()
                                .fill(Color.white)
                                .frame(width: 28, height: 28)
                                .padding(2)
                        }
                        .onTapGesture {
                            biometricsOn.toggle()
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Backup method")
                            .font(.subheadline.weight(.medium))

                        HStack(spacing: 10) {
                            methodChip("SMS", index: 0)
                            methodChip("App", index: 1)
                            methodChip("Email", index: 2)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                )

                VStack(alignment: .leading, spacing: 16) {
                    Text("Payments")
                        .font(.headline)

                    HStack {
                        Image(systemName: "bell.badge")
                            .font(.title3)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Transaction alerts")
                                .font(.subheadline.weight(.medium))

                            Text(alertsOn ? "Enabled" : "Disabled")
                                .font(.caption)
                                .foregroundStyle(alertsOn ? .green : .secondary)
                        }

                        Spacer()

                        Circle()
                            .fill(alertsOn ? Color.green : Color.gray)
                            .frame(width: 14, height: 14)
                    }
                    .onTapGesture {
                        alertsOn.toggle()
                    }

                    HStack {
                        Text("Transfer limit")
                            .font(.subheadline.weight(.medium))

                        Spacer()

                        Text("$2,000")
                            .font(.subheadline)

                        Image(systemName: "chevron.right")
                            .foregroundStyle(.tertiary)
                    }
                    .onTapGesture {
                        selectedMethod = (selectedMethod + 1) % 3
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                )
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }

    private func methodChip(_ title: String, index: Int) -> some View {
        Text(title)
            .font(.subheadline.weight(.medium))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(selectedMethod == index ? Color.blue.opacity(0.18) : Color(.tertiarySystemFill))
            )
            .foregroundStyle(selectedMethod == index ? .blue : .primary)
            .onTapGesture {
                selectedMethod = index
            }
    }
}

#Preview {
    NavigationStack {
        SecuritySettingsScreen()
    }
}
