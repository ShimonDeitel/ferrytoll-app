import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchaseManager: PurchaseManager

    @State private var showingAdd = false
    @State private var showingSettings = false
    @State private var showingPaywall = false
    @State private var editingItem: Crossing?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                if store.items.isEmpty {
                    ContentUnavailableView(
                        "No entries yet",
                        systemImage: "tray",
                        description: Text("Tap + to add your first entry.")
                    )
                    .foregroundStyle(Theme.textPrimary)
                } else {
                    List {
                        ForEach(store.items) { item in
                            Button {
                                editingItem = item
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.route)
                                        .font(Theme.bodyFont.weight(.semibold))
                                        .foregroundStyle(Theme.textPrimary)
                    if let amountText = self.amountText(item) {
                        Text(amountText)
                            .font(Theme.numberFont)
                            .foregroundStyle(Theme.accent)
                    }
                    Text(item.date, style: .date)
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                                }
                                .padding(.vertical, 4)
                            }
                            .accessibilityIdentifier("row_\(item.id.uuidString)")
                            .listRowBackground(Theme.cardBackground)
                        }
                        .onDelete { offsets in
                            store.delete(at: offsets)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Ferrytoll")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                EntryFormView(mode: .add)
            }
            .sheet(item: $editingItem) { item in
                EntryFormView(mode: .edit(item))
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
        .tint(Theme.accent)
    }

    private func amountText(_ item: Crossing) -> String? {
        String(format: "$%.2f", item.fare)
    }
}

enum FormMode: Identifiable {
    case add
    case edit(Crossing)

    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let item): return item.id.uuidString
        }
    }
}

struct EntryFormView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss

    let mode: FormMode
    @State private var draft: Crossing

    init(mode: FormMode) {
        self.mode = mode
        switch mode {
        case .add:
            _draft = State(initialValue: Crossing())
        case .edit(let item):
            _draft = State(initialValue: item)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Route", text: $draft.route)
                        .accessibilityIdentifier("field_route")
                    TextField("Fare", value: $draft.fare, format: .number)
                        .keyboardType(.decimalPad)
                        .accessibilityIdentifier("field_fare")
                    DatePicker("Date", selection: $draft.date, displayedComponents: .date)
                        .accessibilityIdentifier("field_date")
                }

                if case .edit = mode {
                    Section {
                        Button("Delete Entry", role: .destructive) {
                            store.delete(draft)
                            dismiss()
                        }
                        .accessibilityIdentifier("deleteButton")
                    }
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
            .navigationTitle(isAdding ? "Add Entry" : "Edit Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if isAdding {
                            store.add(draft)
                        } else {
                            store.update(draft)
                        }
                        dismiss()
                    }
                    .accessibilityIdentifier("saveButton")
                }
            }
        }
    }

    private var isAdding: Bool {
        if case .add = mode { return true }
        return false
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
