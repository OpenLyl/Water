<h1 align="center">Water</h1>

<p align="center">
<a href="https://bmc.link/creatormetasky"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" height="20px"></a>
<a href="https://developer.apple.com/swift"><img alt="Swift5" src="https://img.shields.io/badge/language-Swift5-orange.svg"></a>
<a href="https://developer.apple.com"><img alt="Platform" src="https://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C-green.svg"></a>
<a href="https://swift.org/package-manager/"><img src="https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat"></a>
<a href="https://discord.gg/rr5PFXEF4n"><img src="https://img.shields.io/discord/942890966652694619?logo=discord" alt="chat on Discord"></a>
</p>

<h5 align="center">English | <a href="https://github.com/OpenLyl/Water/blob/main/README_CN.md">简体中文</a></h5>

**Water** - help you to progressively write functional SwiftUI.

```swift
func CounterView() -> some View {
    let count = def(value: 0)

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

* [Why use Water?](#why-use-Water)
* [Installation](#installation)
* [Usage](#usage)
* [Composables](#composables)
* [Plugins](#plugins)
* [Middlewares](#middlewares)
* [Integration with existing projects](#integration-with-existing-projects)
* [Examples](#examples)
* [Compare with X](#compare-with-x)
* [Community](#community)
* [Contribution](#contribution)
* [Thanks](#thanks)
* [License](#license)

---

## Why use Water?

As we all know, `SwiftUI` is a data-driven responsive UI framework. Apple provides a lot of state management tools, such as: `@State`、`@StateObject`、`@Binding`、`@Observable` ..., but these tools can be very confusing for a newbie to SwiftUI, what tool to use when exactly? when master all these tools, switch between them also has a big const. finally, when the project gets complex, the screen full of `@` and `$` symbols make the code difficult to maintain and read.

Now, let's see what `@` means in Swift:

- *Attribute*: `@main`、`@objc`, `@autoclosure`
- *PropertyWrapper*: `@State`, `@StateObject`
- *Macro*: `@Observable`

For developers, all those `@` usages will place a heavy burden on the development mind.

So I am trying to develop this library - **Water**. 

Of course, Water not only solves the above problems, but more importantly guides you through a progressive approach to writing `SwiftUI` code that will help you step-by-step towards your own standalone project.

**Water** design for the following purposes:

- **Clear**: not require confusing `@` symbols
- **Clean**: focus on code logic rather than code style
- **Composable**: reuse your code use `Composable` (support `MVVM`, not recommend)
- **Freedom**: not constrain the way you write code (support `Redux` style, not recommend)
- **Maintainable**: easy and visual testing the state logic

## Installation

**Xcode**

From Xcode menu: `File > Add Packages...`:

```
https://github.com/OpenLyl/Water
```

**Swift Package Manager**

Add the Package url to `Package.swift`, finally your `Package.swift` manifest should like below:

```swift
let package = Package(
  name: "MyApp",
  dependencies: [
    .package(url: "https://github.com/OpenLyl/Water", .branch("main")),
  ],
  targets: [
    .target(name: "MyApp", dependencies: [
      .product(name: "Water", package: "Water"),
    ]),
  ]
)
```

**Cocoapods**

First, add the following entry in your `Podfile`:

```ruby
pod 'Water', :git => 'https://github.com/OpenLyl/Water.git', :branch => 'main'
```

Then run `pod install`.

**Import**

Finally, don't forget to import the framework with `import Water`.

## Usage

When using **Water**, you only need to consider whether your state is a `value`、 `object` or an `array`, define state is like defining variable, so simple.

**define value**

use `def(value: )` to define a value state, because the value is wrapped in a box, so use `.value` to get or set the value:

```swift
func UserView() -> some View {
    let name = def(value: "jack")
    let age = def(value: 20)
    
    return View {
        Text("\(name.value)'s age = \(age.value)")
        Button("change age") {
            age.value += 1
        }
        TextField("input your name", text: name.bindable)
    }
}
```

**define object**

use `def(object: )` to change object reactivity, support `struct` and `class`.

```swift
struct User {
    var name: String
    var age: Int
}
```

```swift
func UserView() -> some View {
    let user = def(object: User(name: "jack", age: 20))
    
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

**define array**

To make array reactivity use `def(array: )`, as simple as define object.

```swift
func NumberListView() -> some View {
    let array = ["1", "2", "3"]
    var nextIndex = array.count + 1

    let items = def(array: array)

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

**define watch**

**Water** also has the ability to listen for data changes and quickly select useful states by using `defWatch`.

```swift
func WatchEffectView() -> some View {
    let count = def(value: 0)
    let name = def(value: "some name")
    
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

**define computed**

In most cases, you can use Swift native computed property directly to pick the defined states.

```swift
let user = def(object: User(name: "hello", age: 18))

var displayName: String {
    "name is \(user.name)"
}

var displayAge: String {
    "\(user.age) years old"
}
```

outside of this，**Water** also provide the cacheable computed property, when there are complex data processing, use `defComputed`.

```swift
func FilterNumbersView() -> some View {
    let showEven = def(value: false)
    let items = def(array: [1, 2, 3, 4, 5, 6])
    
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

**nested state**

`under writing`

## Composables

Once all the states become reactive, use composable way to extract the data logic is so natural.

**useReducer**

`useReducer` allow you code `SwiftUI` in `Redux` style, very similar to **TCA**.

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

`useStore` will be more powerful than `useReducer`, it's still under development.

```swift
let useCounterStore = defStore("counter") {
    let count = def(value: 0)

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

`useFetch` provides the ability to send http restful requests and final fetch the network result data, now is a simple version, it will be more flexible and powerful in the future.

```swift
func UseFetchView() -> some View {
    let (isFetching, error, data) = useFetch(url: "https://httpbin.org/get")
    
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

`useFetch` also support manual trigger send request.

```swift
let (isFetching, result, error, execute) = useFetch({ "http://www.numbersapi.com/\(count.value)" }, immediate: false)

func sendRequest() {
    Task {
        await execute()
    }
}
```

**useAsyncState**

`useAsyncState` provides the ability to use state from existing async context. sometimes, it's more useful than `useFetch`.

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

The following code shows how to get the system environment on demand, it's equivalent to `@Environment(\.dismiss) private var dismiss`.

```swift
func UseEnvironmentView() -> some View {
    let dismiss = useEnvironment(\.dismiss)
    let count = def(value: 0)
    
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

can also use `.bindable` to keep sync with system bindable environment.

```swift
func UseEditModeEnvironmentView() -> some View {
    let name = def(value: "hello word edit mode")
    let editMode = def(value: EditMode.inactive)
    
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

`under development`

## Build your own composable

`under writing`

## Plugins

`under development`

## Middlewares

`under development`

## Integration

**use official struct view style**

``` swift
struct CountereView: View {
    let count = def(value: 0)

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

**integrate with other SwfitUI views**

`under writing`

## Examples

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

## Compare with X

**compare with TCA**

`under writing`

## Community

If you want to discuss **Water** or have a question about how to use it to solve a particular problem, you can join the discord channel:

[![Discord](https://discordapp.com/api/guilds/942890966652694619/widget.png?style=banner2)](https://discord.gg/rr5PFXEF4n)

## Contribution

**Water** is only a basic MVP at this point and is not recommended for online products, there are still some areas that need to be worked on, as follows:

- need more util functions to handle reactivity system
- `Composables` is just getting started, need more logic to handle complex situations
- add more unit test and improve the test coverage
- write more use cases with snapshot test
- write more example apps and tutorials
- code with more comments
- performance test

so if you are interested in this project, please join us for something fun!

## Thanks

This project is heavily inspired by the following awesome projects.

- [react](https://github.com/facebook/react)
- [vue](https://github.com/vuejs/core)
- [vueuse](https://github.com/vueuse/vueuse)
- [swiftui-hooks](https://github.com/ra1028/swiftui-hooks)

## License

This library is released under the MIT license. See [LICENSE](https://github.com/OpenLyl/Water/blob/main/LICENSE) for details.
