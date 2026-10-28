import CoreData
import Observation
import os

/// The Core Data stack and every change the app makes to it.
///
/// The store is the 2011 app's own file, `Documents/DataModel.sqlite`, opened with the unchanged
/// `DataModel` model, so an update from 1.2 finds all its scopes and occupations where they were.
@MainActor
@Observable
final class Planner {
    @ObservationIgnored let container: NSPersistentContainer
    var context: NSManagedObjectContext { container.viewContext }

    private static let log = Logger(subsystem: "net.shtykhno.BeIrrational", category: "store")

    static var storeURL: URL {
        URL.documentsDirectory.appending(path: "DataModel.sqlite")
    }

    convenience init(inMemory: Bool = false) {
        self.init(storeURL: inMemory ? URL(filePath: "/dev/null") : Self.storeURL)
    }

    init(storeURL: URL) {
        container = NSPersistentContainer(name: "DataModel", managedObjectModel: Self.model)
        let description = NSPersistentStoreDescription(url: storeURL)
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error {
                Self.log.error("cannot open the store: \(error.localizedDescription)")
            }
        }
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }

    /// One model for the whole process: tests make many planners, and Core Data warns when two
    /// models claim the same entity classes.
    private static let model: NSManagedObjectModel = {
        guard let url = Bundle(for: Planner.self).url(forResource: "DataModel", withExtension: "momd"),
            let model = NSManagedObjectModel(contentsOf: url)
        else { fatalError("DataModel.momd is missing from the app bundle") }
        return model
    }()

    func save() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            Self.log.error("cannot save: \(error.localizedDescription)")
            context.rollback()
        }
    }

    // MARK: - Scopes

    func scopes() -> [Domain] {
        (try? context.fetch(Domain.fetchNow())) ?? []
    }

    @discardableResult
    func addScope(title: String, note: String) -> Domain {
        let order = scopes().count
        let domain = Domain(context: context)
        domain.text = title
        domain.note = note
        domain.date = .now
        domain.status = Status.now.rawValue
        domain.order = Int16(order)
        save()
        return domain
    }

    func update(_ domain: Domain, title: String, note: String) {
        domain.text = title
        domain.note = note
        save()
    }

    func has(_ suggestion: SuggestedScope) -> Bool {
        scopes().contains { $0.text == suggestion.title && $0.note == suggestion.note }
    }

    /// Deletes the scope and everything in it, wherever it lives.
    func delete(_ domain: Domain) {
        for occupation in domain.occupations ?? [] {
            context.delete(occupation)
        }
        context.delete(domain)
        renumber(scopes().filter { $0 != domain })
        save()
    }

    func moveScopes(from source: IndexSet, to destination: Int) {
        var list = scopes()
        list.move(fromOffsets: source, toOffset: destination)
        renumber(list)
        save()
    }

    /// Moves every occupation still on the Now list of this scope to another place.
    func moveAll(in domain: Domain, to status: Status) {
        let active = occupations(in: domain, status: .now)
        var next = occupations(in: domain, status: status).count
        for occupation in active {
            occupation.status = status.rawValue
            occupation.order = Int16(next)
            next += 1
        }
        save()
    }

    // MARK: - Occupations

    func occupations(in domain: Domain, status: Status) -> [Occupation] {
        (try? context.fetch(Occupation.fetch(in: domain, status: status))) ?? []
    }

    @discardableResult
    func addOccupation(to domain: Domain, title: String, note: String, status: Status = .now) -> Occupation {
        let order = occupations(in: domain, status: status).count
        let occupation = Occupation(context: context)
        occupation.text = title
        occupation.note = note
        occupation.date = .now
        occupation.status = status.rawValue
        occupation.order = Int16(order)
        occupation.domain = domain
        save()
        return occupation
    }

    func update(_ occupation: Occupation, title: String, note: String) {
        occupation.text = title
        occupation.note = note
        save()
    }

    /// Puts the occupation at the end of its new place and closes the gap it leaves.
    func move(_ occupation: Occupation, to status: Status) {
        guard let domain = occupation.domain, occupation.place != status else { return }
        let from = occupation.place
        occupation.order = Int16(occupations(in: domain, status: status).count)
        occupation.status = status.rawValue
        renumber(occupations(in: domain, status: from).filter { $0 != occupation })
        save()
    }

    func moveOccupations(in domain: Domain, from source: IndexSet, to destination: Int) {
        var list = occupations(in: domain, status: .now)
        list.move(fromOffsets: source, toOffset: destination)
        renumber(list)
        save()
    }

    /// Progress is kept in whole percent; reaching 100 stamps the day it was done.
    func setProgress(_ occupation: Occupation, to percent: Int) {
        let value = min(max(percent, 0), 100)
        occupation.progress = Int16(value)
        occupation.completedDate = value == 100 ? (occupation.completedDate ?? .now) : nil
        save()
    }

    func emptyTrash() {
        let request = Occupation.fetch(status: .trash)
        for occupation in (try? context.fetch(request)) ?? [] {
            context.delete(occupation)
        }
        save()
    }

    private func renumber(_ objects: [NSManagedObject]) {
        for (index, object) in objects.enumerated() {
            object.setValue(Int16(index), forKey: "order")
        }
    }
}
