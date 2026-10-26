/// The ready-made scopes offered when adding one, as in the 2011 app.
struct SuggestedScope: Hashable, Sendable {
    let title: String
    let note: String

    static let all: [SuggestedScope] = [
        SuggestedScope(title: "Sort out my finances", note: "total income, savings, debt repayment"),
        SuggestedScope(
            title: "Take up career and business",
            note: "new projects, partnerships, expansion, new products/services"),
        SuggestedScope(
            title: "Take care of my health", note: "weight loss/gain, training, eating habits, medicine, sports"),
        SuggestedScope(
            title: "Develop myself", note: "education, training, public speaking, counseling, spiritual values"),
        SuggestedScope(title: "Improve family relationship", note: "family, children, parents, friends, partners"),
        SuggestedScope(title: "Arrange my free time", note: "holidays, travel, clubs, hobbies, activities"),
        SuggestedScope(title: "Participate in public life", note: "charity, public affairs, church, coaching"),
        SuggestedScope(title: "Improve foreign languages", note: "reading books, magazines, writing articles"),
    ]
}
