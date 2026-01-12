struct SourceSpan: Equatable {
    let start: SourceLocation
    let end: SourceLocation
}

struct SourceLocation: Equatable {
    let line: Int
    let column: Int
}
