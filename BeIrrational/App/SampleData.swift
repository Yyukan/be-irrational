#if DEBUG
    import Foundation

    /// Sample scopes and occupations for UI tests and App Store screenshots (debug builds only).
    @MainActor
    enum SampleData {
        static func fill(_ planner: Planner) {
            let family = planner.addScope(
                title: "Improve family relationship", note: "family, children, parents, friends, partners")
            add(planner, to: family, "Arrange a family picnic", "Saturday, by the lake if the weather holds", 90, 12)
            add(planner, to: family, "Visit grandparents", "Bring the photo album", 0, 3)
            add(planner, to: family, "Make a family diary", "One page a week, everyone writes", 20, 30)
            add(planner, to: family, "Organize a family weekend", "", 60, 21)
            add(planner, to: family, "Play baseball with my son", "", 40, 8)

            let career = planner.addScope(
                title: "Take up career and business", note: "new projects, partnerships, expansion")
            add(planner, to: career, "Launch the side project", "Landing page first", 35, 40)
            add(planner, to: career, "Find a mentor", "", 10, 15)
            add(planner, to: career, "Learn to say no", "", 50, 60)

            let health = planner.addScope(
                title: "Take care of my health", note: "training, eating habits, sports")
            add(planner, to: health, "Run a 10K", "Three runs a week", 70, 45)
            add(planner, to: health, "Sleep before midnight", "", 30, 10)

            let time = planner.addScope(title: "Arrange my free time", note: "holidays, travel, clubs, hobbies")
            add(planner, to: time, "Learn to play guitar", "Ten minutes a day", 25, 90)
            add(planner, to: time, "Weekend in Lisbon", "", 0, 5)
            add(planner, to: time, "Read one book a month", "", 80, 120)

            let languages = planner.addScope(
                title: "Improve foreign languages", note: "reading books, magazines, writing articles")
            add(planner, to: languages, "Read a novel in Spanish", "", 15, 25)

            let money = planner.addScope(title: "Sort out my finances", note: "total income, savings, debt repayment")
            add(planner, to: money, "Save for a new car", "", 45, 200)

            // someday, completed, trash
            let someday1 = add(planner, to: time, "Sail across the Atlantic", "", 0, 300)
            let someday2 = add(planner, to: career, "Write a book", "About the side project", 5, 150)
            let someday3 = add(planner, to: family, "Plant a tree with the kids", "", 0, 20)
            for occupation in [someday1, someday2, someday3] { planner.move(occupation, to: .someday) }

            let done1 = add(planner, to: health, "Quit sugar in coffee", "", 100, 40, doneAfter: 18)
            let done2 = add(planner, to: family, "Call mom every Sunday", "", 100, 70, doneAfter: 35)
            let done3 = add(planner, to: languages, "Pass the B1 exam", "", 100, 200, doneAfter: 160)
            for occupation in [done1, done2, done3] { planner.move(occupation, to: .completed) }

            let trash1 = add(planner, to: career, "Answer every email at once", "", 10, 12)
            let trash2 = add(planner, to: health, "Buy a treadmill", "", 0, 9)
            for occupation in [trash1, trash2] { planner.move(occupation, to: .trash) }
        }

        @discardableResult
        private static func add(
            _ planner: Planner, to domain: Domain, _ title: String, _ note: String, _ progress: Int,
            _ daysAgo: Int, doneAfter: Int? = nil
        ) -> Occupation {
            let occupation = planner.addOccupation(to: domain, title: title, note: note)
            let start = Calendar.current.date(byAdding: .day, value: -daysAgo, to: .now) ?? .now
            occupation.date = start
            occupation.progress = Int16(progress)
            if let doneAfter {
                occupation.completedDate = Calendar.current.date(byAdding: .day, value: doneAfter, to: start)
            }
            planner.save()
            return occupation
        }
    }
#endif
