import SwiftUI

struct Task: Identifiable {
    let id = UUID()
    var title: String
    var category: TaskCategory
    var isCompleted: Bool
}

enum TaskCategory: String, CaseIterable {
    case work = "Work"
    case home = "Home"
    case personal = "Personal"
    
    var color: Color {
        switch self {
        case .work: return .blue
        case .home: return .green
        case .personal: return .orange
        }
    }
}

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    
    func addTask(title: String, category: TaskCategory) {
        let newTask = Task(title: title, category: category, isCompleted: false)
        withAnimation {
            tasks.append(newTask)
        }
    }
    
    func toggleTaskCompletion(task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            withAnimation(.easeInOut) {
                tasks[index].isCompleted.toggle()
            }
        }
    }
    
    func removeTask(task: Task) {
        withAnimation {
            tasks.removeAll { $0.id == task.id }
        }
    }
    
    var completionRate: Double {
        let completedTasks = tasks.filter { $0.isCompleted }.count
        return tasks.isEmpty ? 0 : Double(completedTasks) / Double(tasks.count)
    }
}

struct ContentView: View {
    @StateObject private var viewModel = TaskViewModel()
    @State private var newTaskTitle = ""
    @State private var selectedCategory: TaskCategory = .work

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Enter task...", text: $newTaskTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Picker("", selection: $selectedCategory) {
                        ForEach(TaskCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Button(action: {
                        if !newTaskTitle.isEmpty {
                            viewModel.addTask(title: newTaskTitle, category: selectedCategory)
                            newTaskTitle = ""
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                    .padding()
                }
                
                ProgressView(value: viewModel.completionRate)
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding()
                
                List {
                    ForEach(viewModel.tasks) { task in
                        HStack {
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(task.isCompleted ? .green : .gray)
                                .onTapGesture {
                                    viewModel.toggleTaskCompletion(task: task)
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                }
                            
                            VStack(alignment: .leading) {
                                Text(task.title)
                                    .strikethrough(task.isCompleted, color: .gray)
                                    .foregroundColor(task.isCompleted ? .gray : .primary)
                                    .animation(.easeInOut)
                                
                                Text(task.category.rawValue)
                                    .font(.caption)
                                    .foregroundColor(task.category.color)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 6)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBackground)).shadow(radius: 1))
                        .swipeActions {
                            Button(role: .destructive) {
                                viewModel.removeTask(task: task)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .padding(.horizontal, 10)
            .navigationTitle("Task Manager")
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
}
