import Foundation

//https://www.avanderlee.com/swift/dynamic-member-lookup/

struct Blog {
    var title: String
    var url: URL
}

@dynamicMemberLookup
struct Blogger {
    let name: String
    private let blog: Blog
    
    init(name: String, blog: Blog) {
        self.name = name
        self.blog = blog
    }
    
    subscript<T>(dynamicMember keyPath: KeyPath<Blog, T>) -> T {
        return blog[keyPath: keyPath]
    }
}

@dynamicMemberLookup
struct MutableBlogger {
    let name: String
    private var blog: Blog
    
    init(name: String, blog: Blog) {
        self.name = name
        self.blog = blog
    }
    
    subscript<T>(dynamicMember keyPath: WritableKeyPath<Blog, T>) -> T {
        return blog[keyPath: keyPath]
    }
}

let blog = Blog(title: "hello", url: URL(string: "https://www.baidu.com")!)

// read blog info (title and url)
let blogger = Blogger(name: "new name", blog: blog)
print(blogger.title)
print(blogger.url)
//blogger.title = "new title" // it's compile failed

// write blog info
var mutableBlogger = MutableBlogger(name: "new name", blog: blog)
print(mutableBlogger.title)
print(mutableBlogger.url)
//mutableBlogger.title = "new title" // change to WritableKeyPath also compile failed
