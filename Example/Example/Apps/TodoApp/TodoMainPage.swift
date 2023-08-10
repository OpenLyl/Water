//
//  TodoMainPage.swift
//  Example
//

import SwiftUI
import Water

// MARK: - Model

struct Todo: Identifiable {
    let id = UUID()
    var name: String = ""
    var completed: Bool = false
}

// MARK: - Origin

//class TodoListViewModel: ObservableObject {
//    @Published var todos: [Todo] = [
//        .init(name: "123", completed: false),
//        .init(name: "456", completed: true),
//    ]
//
//    func addTodo(name: String) {
//        var newTodo = Todo()
//        newTodo.name = name
//        todos.append(newTodo)
//    }
//
//    func removeTodo(indexSet: IndexSet) {
//        todos.remove(atOffsets: indexSet)
//    }
//
//    func toggleTodoCompletion(todo: Todo) {
//        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
//            todos[index].completed.toggle()
//        }
//    }
//}
//
//struct TodoMainPage: View {
//    @StateObject var todoListViewModel = TodoListViewModel()
//    @State private var newTodoName = ""
//
//    var body: some View {
//        VStack {
//            List {
//                ForEach($todoListViewModel.todos) { $todo in
//                    TodoItemView(todo: $todo)
//                }
//                .onDelete(perform: deleteTodoItem)
//            }
//            .listStyle(.plain)
//            VStack {
//                HStack {
//                    TextField("input your todo item", text: $newTodoName)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                    Spacer()
//                }
//                .padding()
//                HStack {
//                    Button("add todo") {
//                        addTodoItem()
//                    }
//                    Button("clear all todos") {
//                        clearTodos()
//                    }
//                    Text("total todo count = \(todoListViewModel.todos.count)")
//                }
//                .padding()
//            }
//            Spacer()
//        }
//    }
//
//    func addTodoItem() {
//        if newTodoName.isEmpty { return }
//
//        todoListViewModel.addTodo(name: newTodoName)
//
//        newTodoName = ""
//        dismissKeyboard()
//    }
//
//    func deleteTodoItem(at offsets: IndexSet) {
//        todoListViewModel.removeTodo(indexSet: offsets)
//    }
//
//
//    func clearTodos() {
//        todoListViewModel.todos.removeAll()
//    }
//}
//
//struct TodoItemView: View {
//    @Binding var todo: Todo
//
//    var body: some View {
//        Button {
//            todo.completed.toggle()
//        } label: {
//            HStack {
//                Image(systemName: todo.completed ? "checkmark.circle.fill" : "circle")
//                Text(todo.name)
//                    .strikethrough(todo.completed, color: .gray)
//            }
//        }
//    }
//}

// MARK: - defHooks

func TodoMainPage() -> some View {
    let todos = defReactive([
        Todo(name: "123", completed: false),
        Todo(name: "456", completed: true),
    ])
    let newTodoName = defValue("")

    func addTodoItem() {
        if newTodoName.value.isEmpty { return }

        var newTodo = Todo()
        newTodo.name = newTodoName.value
        todos.append(newTodo)

        newTodoName.value = ""
        dismissKeyboard()
    }

    func deleteTodoItem(at indexSet: IndexSet) {
        todos.remove(atOffsets: indexSet)
    }

    func clearTodos() {
        todos.removeAll()
    }

    return View {
        VStack {
            List {
                ForEach(todos.bindable) { todo in
                    TodoItemView($todo: todo)
                }
                .onDelete(perform: deleteTodoItem)
            }
            VStack {
                HStack {
                    TextField("input your todo item", text: newTodoName.bindable)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Spacer()
                }
                .padding()
                HStack {
                    Button("add todo") {
                        addTodoItem()
                    }
                    Button("clear all todos") {
                        clearTodos()
                    }
                    Text("total todo count = \(todos.count)")
                }
                .padding()
            }
            Spacer()
        }
    }
}

func TodoItemView(@Binding todo: Todo) -> some View {
    Button {
        todo.completed.toggle()
    } label: {
        HStack {
            Image(systemName: todo.completed ? "checkmark.circle.fill" : "circle")
            Text(todo.name)
                .strikethrough(todo.completed, color: .gray)
        }
    }
}
