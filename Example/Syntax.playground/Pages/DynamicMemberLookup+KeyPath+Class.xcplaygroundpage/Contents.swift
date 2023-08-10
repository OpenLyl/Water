import Foundation

//https://www.swiftbysundell.com/tips/combining-dynamic-member-lookup-with-key-paths/

@dynamicMemberLookup
struct Settings {
    var colorTheme = "modern"
    var itemPageSize = 25
    var keepUserLoggedIn = true

    subscript(dynamicMember member: String) -> Any? {
        switch member {
        case "colorTheme":
            return colorTheme
        case "itemPageSize":
            return itemPageSize
        case "keepUserLoggedIn":
            return keepUserLoggedIn
        default:
            return nil
        }
    }
}

let settings = Settings()
print(settings.colorTheme)
print(settings.itemPageSize)

@dynamicMemberLookup
class Reference<Value> {
    private(set) var value: Value

    init(value: Value) {
        self.value = value
    }

//    subscript<T>(dynamicMember keyPath: KeyPath<Value, T>) -> T {
//        value[keyPath: keyPath]
//    }
}

extension Reference {
    subscript<T>(dynamicMember keyPath: WritableKeyPath<Value, T>) -> T {
        get { value[keyPath: keyPath] }
        set { value[keyPath: keyPath] = newValue }
    }
}

let reference = Reference(value: Settings())
print(reference.colorTheme)
print(reference.itemPageSize)
print(reference.keepUserLoggedIn)

struct Blog {
    var title: String
    var url: URL
}

let blog = Blog(title: "hello", url: URL(string: "https://www.baidu.com")!)
let refBlog = Reference(value: blog)
print(refBlog.title)
print(refBlog.url)
refBlog.title = "new title"
print(refBlog.title)
