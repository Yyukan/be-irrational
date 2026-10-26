import CoreData

/// A scope of life ("Take care of my health"): the `Domain` entity of the 2011 data model.
@objc(Domain)
final class Domain: NSManagedObject {
    @NSManaged var text: String?
    @NSManaged var note: String?
    @NSManaged var date: Date?
    @NSManaged var order: Int16
    @NSManaged var status: Int16
    @NSManaged var occupations: Set<Occupation>?

    var title: String { text ?? "" }

    /// The occupations still on the Now list.
    var activeCount: Int {
        occupations?.count { $0.status == Status.now.rawValue } ?? 0
    }
}

extension Domain {
    static func fetchNow() -> NSFetchRequest<Domain> {
        let request = NSFetchRequest<Domain>(entityName: "Domain")
        request.predicate = NSPredicate(format: "status == %d", Status.now.rawValue)
        request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        return request
    }
}

extension Domain: Identifiable {}
