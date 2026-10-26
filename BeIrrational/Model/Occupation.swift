import CoreData

/// One thing to do within a scope: the `Occupation` entity of the 2011 data model.
@objc(Occupation)
final class Occupation: NSManagedObject {
    @NSManaged var text: String?
    @NSManaged var note: String?
    @NSManaged var date: Date?
    @NSManaged var completedDate: Date?
    @NSManaged var order: Int16
    @NSManaged var progress: Int16
    @NSManaged var status: Int16
    @NSManaged var domain: Domain?

    var title: String { text ?? "" }

    var place: Status { Status(rawValue: status) ?? .now }

    /// Days from the start to completion, or to today while it is not complete.
    func days(now: Date = .now, calendar: Calendar = .current) -> Int {
        guard let date else { return 0 }
        let end = completedDate ?? now
        let from = calendar.startOfDay(for: date)
        let to = calendar.startOfDay(for: end)
        return calendar.dateComponents([.day], from: from, to: to).day ?? 0
    }
}

extension Occupation {
    static func fetch(in domain: Domain, status: Status) -> NSFetchRequest<Occupation> {
        let request = NSFetchRequest<Occupation>(entityName: "Occupation")
        request.predicate = NSPredicate(format: "domain == %@ AND status == %d", domain, status.rawValue)
        request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        return request
    }

    /// Everything in one place, grouped by scope title as the 2011 lists were.
    static func fetch(status: Status) -> NSFetchRequest<Occupation> {
        let request = NSFetchRequest<Occupation>(entityName: "Occupation")
        request.predicate = NSPredicate(format: "status == %d", status.rawValue)
        request.sortDescriptors = [
            NSSortDescriptor(key: "domain.text", ascending: true),
            NSSortDescriptor(key: "order", ascending: true),
        ]
        return request
    }
}

extension Occupation: Identifiable {}
