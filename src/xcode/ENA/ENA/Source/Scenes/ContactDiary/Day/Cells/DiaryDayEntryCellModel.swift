////
// 🦠 Corona-Warn-App
//

import UIKit

struct DiaryDayEntryCellModel {

	// MARK: - Init

	init(
		entry: DiaryEntry,
		dateString: String,
		store: DiaryStoringProviding
	) {
		self.entry = entry
		self.dateString = dateString
		self.store = store

		image = entry.isSelected ? UIImage(named: "Diary_Checkmark_Selected") : UIImage(named: "Diary_Checkmark_Unselected")
		text = entry.name

		entryType = entry.type
		parametersHidden = !entry.isSelected

		if entry.isSelected {
			accessibilityTraits = [.button, .selected]
		} else {
			accessibilityTraits = [.button]
		}
	}

	// MARK: - Internal

	let entry: DiaryEntry
	let store: DiaryStoringProviding
	let dateString: String

	let image: UIImage?
	let text: String

	let entryType: DiaryEntryType
	let parametersHidden: Bool

	let accessibilityTraits: UIAccessibilityTraits

	func toggleSelection() {
		entry.isSelected ? deselect() : select()
	}

	func updateContactPersonEncounter(
		duration: ContactPersonEncounter.Duration? = nil,
		maskSituation: ContactPersonEncounter.MaskSituation? = nil,
		setting: ContactPersonEncounter.Setting? = nil,
		circumstances: String? = nil
	) {
		guard case .contactPerson(let contactPerson) = entry, let encounter = contactPerson.encounter else {
			fatalError("Cannot update non-existent encounter.")
		}

		store.updateContactPersonEncounter(
			id: encounter.id,
			date: encounter.date,
			duration: duration ?? encounter.duration,
			maskSituation: maskSituation ?? encounter.maskSituation,
			setting: setting ?? encounter.setting,
			circumstances: circumstances ?? encounter.circumstances
		)
	}

	func updateLocationVisit(
		durationInMinutes: Int? = nil,
		circumstances: String? = nil
	) {
		guard case .location(let location) = entry, let visit = location.visit else {
			fatalError("Cannot update non-existent visit.")
		}

		store.updateLocationVisit(
			id: visit.id,
			date: visit.date,
			durationInMinutes: durationInMinutes ?? visit.durationInMinutes,
			circumstances: circumstances ?? visit.circumstances
		)
	}

	// MARK: - Private

	private func select() {
		switch entry {
		case .location(let location):
			store.addLocationVisit(locationId: location.id, date: dateString)
		case .contactPerson(let contactPerson):
			store.addContactPersonEncounter(contactPersonId: contactPerson.id, date: dateString)
		}
	}

	private func deselect() {
		switch entry {
		case .location(let location):
			guard let visit = location.visit else {
				Log.error("Trying to deselect unselected location", log: .contactdiary)
				return
			}
			store.removeLocationVisit(id: visit.id)
		case .contactPerson(let contactPerson):
			guard let encounter = contactPerson.encounter else {
				Log.error("Trying to deselect unselected contact person", log: .contactdiary)
				return
			}
			store.removeContactPersonEncounter(id: encounter.id)
		}
	}
    
}
