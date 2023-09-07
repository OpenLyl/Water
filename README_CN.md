<h1 align="center">Water</h1>

<p align="center">
<a href="https://bmc.link/creatormetasky"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" height="20px"></a>
<a href="https://developer.apple.com/swift"><img alt="Swift5" src="https://img.shields.io/badge/language-Swift5-orange.svg"></a>
<a href="https://developer.apple.com"><img alt="Platform" src="https://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C-green.svg"></a>
<a href="https://swift.org/package-manager/"><img src="https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat"></a>
<a href="https://discord.gg/rr5PFXEF4n"><img src="https://img.shields.io/discord/942890966652694619?logo=discord" alt="chat on Discord"></a>
</p>

<h5 align="center"><a href="https://github.com/OpenLyl/Water/blob/main/README.md">English</a> | 简体中文</h5>

**Water** - 帮助你渐进式的组合函数式 SwiftUI 

```swift
func CounterView() -> some View {
    let count = defValue(0)

    return View {
        Text("\(count.value)")
        HStack {
            Button("+1") {
                count.value += 1
            }
            Button("-1") {
                count.value -= 1
            }
        }
    }
}
```

---

* [Water 起源](#Water-起源)
* [安装](#安装)
* [基本用法](#基本用法)
* [组合](#组合)
* [插件](#插件)
* [中间件](#中间件)
* [项目集成](#项目集成)
* [示例代码](#示例代码)
* [与其他库进行对比](#与其他库进行对比)
* [社区](#社区)
* [贡献](#贡献)
* [鸣谢](#鸣谢)
* [开源协议](#开源协议)

---

## Water 起源

众所周知，`SwiftUI` 是一个数据驱动的响应式 UI 框架，自从发布以来，`Apple` 提供了许多属性包装器来帮助开发者管理状态，例如：`@State`、`@StateObject`、`@Binding`、`@Observable` 等。但是这些属性包装器对于初学者来说使用起来非常迷惑，到底什么时候该用哪一个呢？当不断探索掌握了它们的使用时机后，又会发现不同的属性包装器之间切换也是有成本的，例如：要把 `@State` 转换成 `@Published`，最终，随着项目复杂度提升，会发现代码中充斥着 `@` 和 `$` 符号，让代码难于阅读和维护。

个人认为 `Swift` 语法已经过于复杂，让我们来看看一个 `@` 符号在 Swift 有哪些语法特性：

- *特性*: `@main`、`@objc`, `@autoclosure`
- *属性包装器*: `@State`, `@StateObject`
- *宏*: `@Observable`

对于开发者来说，要区分这些符号不同的含义并且还要适时的去理解它们背后的逻辑，是有心智负担的。

基于上述情况，便开发了 `Water` 这个框架(库)。

当你真正开始使用 `Water` 的时候，你会发现 `Water` 不仅解决了上面的问题，更重要的是会引导你用渐进式的方式来编写 `SwiftUI` 代码，最终帮你一步步的开发出自己的独立项目。

**Water** 设计理念如下:

- **清爽**: 状态管理不依赖 `@` 符号，符号不参与代码逻辑
- **清晰**: 更关注代码逻辑而非代码风格
- **组合**: 使用组合的方式来复用代码 (支持 `MVVM`，但不推荐)
- **自由**: 不约束编写代码的方式 (支持 `Redux` 风格，但不推荐)
- **可维护**: 方便、可视化的测试状态逻辑


## 安装

**Xcode**

从 `Xcode` 菜单栏，选择 `File > Add Packages...`，搜索如下地址即可:

```
https://github.com/OpenLyl/Water
```

**Swift Package Manager**

在 `Package.swift` 中添加库地址，配置文件参考如下：

```swift
let package = Package(
  name: "Target",
  dependencies: [
    .package(url: "https://github.com/OpenLyl/Water", .branch("main")),
  ],
  targets: [
    .target(name: "Target", dependencies: [
      .product(name: "Water", package: "Water"),
    ]),
  ]
)
```

**Cocoapods**

首先, 在 `Podfile` 中添加如下依赖描述：

```ruby
pod 'Water'
```

然后运行 `pod install`.

**导入**

上面所有的安装步骤完成后, 别忘了在代码中用 `import Water` 导入。

## 基本用法

当使用 **Water** 时，只需要考虑状态是`数值`、`对象`还是`数组`，定义状态如同定义变量，非常简单。

**定义数值**

定义数值使用 `defValue`，这时候数值被包装了一层，所以获取和赋值的时候，要使用 `.value`，示例如下：

```swift
func UserView() -> some View {
    let name = defValue("jack")
    let age = defValue(20)
    
    return View {
        Text("\(name.value)'s age = \(age.value)")
        Button("change age") {
            age.value += 1
        }
        TextField("input your name", text: name.bindable)
    }
}
```

**定义对象**

定义对象使用 `defReactive`，这里的对象可以是 `结构体` 或 `类`，两种对象的定义方式都是支持的。

```swift
struct User {
    var name: String
    var age: Int
}
```

```swift
func UserView() -> some View {
    let user = defReactive(User(name: "jack", age: 20))
    
    return View {
        VStack {
            Text("user.name = \(user.name)")
            Text("user.age = \(user.age)")
            VStack {
                Button("change name") {
                    user.name = "rose"
                }
                Button("change age") {
                    user.age += 1
                }
            }
        }
    }
}
```

**定义数组**

定义数组也使用 `defReactive`，就跟定义对象一样简单。

```swift
func NumberListView() -> some View {
    let array = ["1", "2", "3"]
    var nextIndex = array.count + 1

    let items = defReactive(array)

    return View {
        VStack {
            LazyVStack {
                ForEach(items, id: \.self) { item in
                    Text("the item = \(item)")
                }
                Text("combined value = \(items.joined(separator: "-|"))")
            }
            HStack(spacing: 16) {
                Button("add item") {
                    nextIndex += 1
                    items.append("\(nextIndex)")
                }
                Button("remove all") {
                    nextIndex = 0
                    items.removeAll()
                }
                Button("clean item") {
                    nextIndex = 3
                    items.replace(with: ["1", "2", "3"])
                }
            }
        }
    }
}
```

**状态监听**

**Water** 具备监听数据状态变化的能力，这样方便有选择的进行数据响应式处理，使用 `defWatch` 来定义。

```swift
func WatchEffectView() -> some View {
    let count = defValue(0)
    let name = defValue("some name")
    
    defWatchEffect { _ in
        // declare a side effect
        print("trigger watch effect")
    }
    
    defWatch(name) { value, oldValue, _ in
        // when name change do something
        print("name changed = \(value), old name = \(oldValue)")
    }
    
    return View {
        Text("the count = \(count.value)")
        Button("click me change count") {
            count.value += 1
        }
        Text("the name = \(name.value)")
        TextField("name", text: name.bindable)
    }
}
```

**计算属性**

通常情况下，直接使用 `Swift` 原生的计算属性就可以获取 `UI` 需要的状态数据。

```swift
let user = defineReactive(User(name: "hello", age: 18))

var displayName: String {
    "name is \(user.name)"
}

var displayAge: String {
    "\(user.age) years old"
}
```

除此之外，**Water** 还提供了可缓存的计算属性，用于处理复杂的数据筛选操作，使用 `defComputed`。

```swift
func FilterNumbersView() -> some View {
    let showEven = defValue(false)
    let items = defReactive([1, 2, 3, 4, 5, 6])
    
    let evenNumbers = defComputed {
        items.filter { !showEven.value || $0 % 2 == 0}
    }
    
    return View {
        VStack {
            Toggle(isOn: showEven.bindable) {
                Text("Only show even numbers")
            }
            Button("dynamic insert num") {
                let newNumbers = [7, 8, 9, 10]
                items.append(contentsOf: newNumbers)
            }
        }
        .padding(.horizontal, 15)
        List(evenNumbers.value, id: \.self) { num in
            Text("the num = \(num)")
        }
    }
}
```

**状态嵌套**

`编写中`

## 组合

一旦所有的状态都原子化且可响应，用组合的方式来抽离代码逻辑就变得顺理成章，**Water** 会把组合代码的辅助函数封装起来，它们都以 `use` 开头。

**useReducer**

`useReducer` 会让你方便的写出 `Redux` 风格的代码，非常类似于 **TCA**。

```swift
struct CountState {
    var count: Int = 0
}

enum CountAction {
    case increase
    case decrease
}

func countReducer(state: inout CountState, action: CountAction) {
    switch action {
    case .increase:
        state.count += 1
    case .decrease:
        state.count -= 1
    }
}

func ReducerCounterView() -> some View {
    let (useCountState, dispatch) = useReducer(CountState(), countReducer)

    return View {
        Text("the count = \(useCountState().count)")
        HStack {
            Button("+1") {
                dispatch(.increase)
            }
            Button("-1") {
                dispatch(.decrease)
            }
        }
    }
}
```

**useStore**

`useStore` 将会是 `userReducer` 的增强版，而且支持 `Store` 的拆分和组合, 还在开发中。

```swift
let useCounterStore = defStore("counter") {
    let count = defValue(0)

    func increment() {
        count.value += 1
    }

    func decrement() {
        count.value -= 1
    }

    return (count, increment, decrement)
}

func StoreCountView() -> some View {
    let store = useCounterStore()

    return View {
        Text("the count = \(store().count)")
        HStack {
            Button("+1") {
                store.increment()
            }
            Button("-1") {
                store.decrement()
            }
        }
    }
}
```

**useFetch**

`useFetch` 提供了发送 `resultful` 风格 `http` 请求的能力，方便从网络动态获取数据进行展示。当前是一个开发中的版本。

```swift
func UseFetchUseCasesView() -> some View {
    let (isFetching, result, error, _) = useFetch(url: "https://httpbin.org/get")
    
    return View {
        VStack {
            Text(isFetching.value ? "is fetching" : "fetch completed")
            if let error = error.value {
                Text("error = \(error.errorDescription ?? "no error")")
            }
            if let result = result.value, let responseString = result.mapString() {
                Text("data is \(responseString)")
            }
        }
    }
}
```

`useFetch` 还支持手动触发执行时机

```swift
let (isFetching, result, error, execute) = useFetch({ "http://www.numbersapi.com/\(count.value)" }, immediate: false)

func sendRequest() {
    Task {
        await execute()
    }
}
```

**useAsyncState**

`useAsyncState` 能够将已有的通过异步方式获取的状态转变成响应式的状态，在很多情况下，它要比 `useFetch` 更有用。

```swift
struct Todo: Codable {
    let id: Int
    let todo: String
    let completed: Bool
}

func fetchTodos() async -> [Todo] {
    ...
}

func UseAsyncStateView() -> some View {
    let (state, isLoading) = useAsyncState(fetchTodos, [] as [Todo])
    
    var todos: [Todo] {
        state.value
    }

    return View {
        if isLoading.value {
            Text("loading...")
        } else {
            List(todos, id: \.id) { todo in
                Text(todo.todo)
            }
        }
    }
}
```

**useEnvironment**

以下代码展示了如何按需获取 `SwiftUI` 系统变量，等价于 `@Environment(\.dismiss) private var dismiss`。

```swift
func UseEnvironmentView() -> some View {
    let dismiss = useEnvironment(\.dismiss)
    let count = defValue(0)
    
    return View {
        VStack {
            Text("new value = \(count.value)")
            Button("+1") {
                count.value += 1
            }
            Button("-1") {
                count.value -= 1
            }
            Button("dismiss") {
                dismiss.value?()
            }
        }
    }
    .useEnvironment(\.dismiss)
}
```

也可以使用 `.bindable` 与系统变量保持同步。

```swift
func UseEditModeEnvironmentView() -> some View {
    let name = defValue("hello word edit mode")
    let editMode = defValue(EditMode.inactive)
    
    return View {
        Form {
            if editMode.value.isEditing == true {
                TextField("Name", text: name.bindable)
            } else {
                Text(name.value)
            }
        }
        .animation(nil, value: editMode.value)
        .toolbar {
            EditButton()
        }
        .environment(\.editMode, editMode.bindable)
    }
}
```

**useRouter**

`开发中`

**Build your own composable**

`编写中`


## 插件

`开发中`

## 中间件

`开发中`

## 项目集成

**与标准写法代码集成**

``` swift
struct CountereView: View {
    let count = defValue(0)

    var body: some View {
        Water.View { // will change in future
            Text("current count = \(count.value)")
            HStack {
                Button("+") {
                    count.value += 1
                }
                Button("-") {
                    count.value -= 1
                }
            }
        }
    }
}
```

**与其他风格代码集成**

`编写中`

## 示例代码

- [UseCases](./Example/Example/UseCases)
    - ValueUseCases
    - ReactivityUseCases
    - WatchUseCases
    - ReducerUseCases
    - StoreUseCases
    - ComputedUseCases
    - ComposableUseCases
    - MemoUseCases
    - EnvironmentUseCases
    - NavigationUseCases
    - EffectScopeUseCases
    - UseFetchUseCasesView
- [Todos](./Example/Example/Apps/TodoApp)
- [SwiftUI Essentials](./Apps/Landmarks)
- Garden (Mastodon client) - under development
- Other TCA examples - under development

## 与其他库进行对比

**对比 TCA**

`编写中`

## 社区

如果想讨论、交流 **Water**，可以加入 `discord` 频道：

[![Discord](https://discordapp.com/api/guilds/942890966652694619/widget.png?style=banner2)](https://discord.gg/rr5PFXEF4n)

## 贡献

**Water** 目前只实现了一个基本的 `MVP`，不建议直接在线上产品中使用，后续工作方向如下：

- 为响应式提供更多的辅助函数
- `组合` 只是刚刚开始，还有很多场景和逻辑要处理
- 提供更多的示例代码和教程
- 为代码编写完备的注释
- 添加更多的单元测试，提高测试覆盖率
- 为测试用例提供快照测试
- 性能测试

如果大家对这个项目感兴趣，欢迎加入我们，一起来做一些有意思的事情！

## 鸣谢

此项目灵感来源于以下项目，在此表示感谢：

- [react](https://github.com/facebook/react)
- [vue](https://github.com/vuejs/core)
- [vueuse](https://github.com/vueuse/vueuse)
- [swiftui-hooks](https://github.com/ra1028/swiftui-hooks)

## 开源协议

此库在 MIT 协议下开源。参见 [LICENSE](https://github.com/OpenLyl/Water/blob/main/LICENSE)。