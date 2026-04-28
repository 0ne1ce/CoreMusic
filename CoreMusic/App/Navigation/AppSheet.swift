import Foundation

enum AppSheet: Identifiable, Hashable {
    case player(songID: String)
    
    var id: Self { self }
}
