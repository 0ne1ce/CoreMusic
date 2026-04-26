import SwiftUI

@Observable
@MainActor
final class AppRouter {
    // MARK: - Internal types

    enum Tab: Hashable, CaseIterable {
        case home
        case library
        case memories
    }

    // MARK: - Properties

    var selectedTab: Tab = .home
    var homePath = NavigationPath()
    var libraryPath = NavigationPath()
    var memoriesPath = NavigationPath()

    var presentedCover: AppCover?
    // 0ne1ce: stack inside cover
    var coverPath = NavigationPath()
    var presentedSheet: AppSheet?

    // MARK: - Public methods

    func push(_ route: AppPushRoute) {
        if presentedCover != nil {
            coverPath.append(route)
        }
        else {
            switch selectedTab {
            case .home: homePath.append(route)
            case .library: libraryPath.append(route)
            case .memories: memoriesPath.append(route)
            }
        }
    }

    func pop() {
        if presentedCover != nil {
            popLast(&coverPath)
        }
        else {
            switch selectedTab {
            case .home: popLast(&homePath)
            case .library: popLast(&libraryPath)
            case .memories: popLast(&memoriesPath)
            }
        }
    }

    func popToRoot() {
        if presentedCover != nil {
            clear(&coverPath)
        }
        else {
            switch selectedTab {
            case .home: clear(&homePath)
            case .library: clear(&libraryPath)
            case .memories: clear(&memoriesPath)
            }
        }
    }

    func select(_ tab: Tab) {
        selectedTab = tab
    }

    func presentCover(_ cover: AppCover) {
        presentedCover = cover
    }

    func dismissCover() {
        coverPath = NavigationPath()
        presentedCover = nil
    }

    func closeCurrent() {
        if presentedCover != nil {
            if coverPath.isEmpty {
                dismissCover()
            }
            else {
                popLast(&coverPath)
            }
        }
        else {
            pop()
        }
    }

    func presentSheet(_ sheet: AppSheet) {
        presentedSheet = sheet
    }

    func dismissSheet() {
        presentedSheet = nil
    }

    // MARK: - Private methods

    private func popLast(_ path: inout NavigationPath) {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    private func clear(_ path: inout NavigationPath) {
        guard !path.isEmpty else { return }
        path.removeLast(path.count)
    }
}
