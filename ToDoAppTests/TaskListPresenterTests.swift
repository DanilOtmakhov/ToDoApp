//
//  TaskListPresenterTests.swift
//  ToDoAppTests
//
//  Created by Danil Otmakhov on 27.05.2025.
//

import XCTest
@testable import ToDoApp

final class MockTaskListView: TaskListViewProtocol {
    var applyUpdateCalled = false
    var applyUpdateParameter: TaskStoreUpdate?
    var showErrorCalled = false
    var showErrorMessage: String?
    
    func applyUpdate(_ update: TaskStoreUpdate) {
        applyUpdateCalled = true
        applyUpdateParameter = update
    }
    
    func showError(_ message: String) {
        showErrorCalled = true
        showErrorMessage = message
    }
}

final class MockTaskListInteractor: TaskListInteractorProtocol {
    var numberOfTasks: Int = 0
    var tasks: [Task] = []
    var loadTasksCalled = false
    var loadTasksQuery: String?
    var toggleCompletionCalled = false
    var toggleCompletionIndex: Int?
    var deleteTaskCalled = false
    var deleteTaskIndex: Int?
    
    func loadTasks(with query: String) {
        loadTasksCalled = true
        loadTasksQuery = query
    }
    
    func toggleCompletionForTask(at index: Int) {
        toggleCompletionCalled = true
        toggleCompletionIndex = index
    }
    
    func deleteTask(at index: Int) {
        deleteTaskCalled = true
        deleteTaskIndex = index
    }
    
    func task(at index: Int) -> Task? {
        return index < tasks.count ? tasks[index] : nil
    }
}

final class MockTaskListRouter: TaskListRouterProtocol {
    var showTaskEditorCalled = false
    var showTaskEditorParameter: Task?
    
    func showTaskEditor(task: Task?) {
        showTaskEditorCalled = true
        showTaskEditorParameter = task
    }
}

final class TaskListPresenterTests: XCTestCase {
    
    var sut: TaskListPresenter!
    var mockView: MockTaskListView!
    var mockInteractor: MockTaskListInteractor!
    var mockRouter: MockTaskListRouter!
    
    override func setUpWithError() throws {
        mockView = MockTaskListView()
        mockInteractor = MockTaskListInteractor()
        mockRouter = MockTaskListRouter()
        sut = TaskListPresenter(interactor: mockInteractor)
        sut.view = mockView
        sut.router = mockRouter
    }
    
    override func tearDownWithError() throws {
        sut = nil
        mockView = nil
        mockInteractor = nil
        mockRouter = nil
    }
    
    // MARK: - TaskListPresenterProtocol Tests
    
    func testNumberOfTasksReturnsInteractorValue() {
        // Arrange
        mockInteractor.numberOfTasks = 5
        
        // Act
        let count = sut.numberOfTasks
        
        // Assert
        XCTAssertEqual(count, 5)
    }
    
    func testTaskAtIndexReturnsTaskCellViewModel() {
        // Arrange
        let task = Task(id: UUID(), title: "Test Task", description: "Description", createdAt: Date(), isCompleted: false)
        mockInteractor.tasks = [task]
        
        // Act
        let viewModel = sut.task(at: 0)
        
        // Assert
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel?.title, "Test Task")
        XCTAssertEqual(viewModel?.description, "Description")
    }
    
    func testTaskAtInvalidIndexReturnsNil() {
        // Arrange
        mockInteractor.tasks = []
        
        // Act
        let viewModel = sut.task(at: 0)
        
        // Assert
        XCTAssertNil(viewModel)
    }
    
    func testLoadTasksCallsInteractorWithEmptyQuery() {
        // Act
        sut.loadTasks()
        
        // Assert
        XCTAssertTrue(mockInteractor.loadTasksCalled)
        XCTAssertEqual(mockInteractor.loadTasksQuery, "")
    }
    
    func testDidTapCompleteButtonCallsInteractor() {
        // Act
        sut.didTapCompleteButton(at: 2)
        
        // Assert
        XCTAssertTrue(mockInteractor.toggleCompletionCalled)
        XCTAssertEqual(mockInteractor.toggleCompletionIndex, 2)
    }
    
    func testDidTapAddTaskCallsRouterWithNilTask() {
        // Act
        sut.didTapAddTask()
        
        // Assert
        XCTAssertTrue(mockRouter.showTaskEditorCalled)
        XCTAssertNil(mockRouter.showTaskEditorParameter)
    }
    
    func testDidTapEditTaskCallsRouterWithTask() {
        // Arrange
        let task = Task(id: UUID(), title: "Test Task", description: nil, createdAt: Date(), isCompleted: false)
        mockInteractor.tasks = [task]
        
        // Act
        sut.didTapEditTask(at: 0)
        
        // Assert
        XCTAssertTrue(mockRouter.showTaskEditorCalled)
        XCTAssertEqual(mockRouter.showTaskEditorParameter?.id, task.id)
    }
    
    func testDidTapEditTaskWithInvalidIndexDoesNotCallRouter() {
        // Arrange
        mockInteractor.tasks = []
        
        // Act
        sut.didTapEditTask(at: 0)
        
        // Assert
        XCTAssertFalse(mockRouter.showTaskEditorCalled)
    }
    
    func testDidTapDeleteTaskCallsInteractor() {
        // Act
        sut.didTapDeleteTask(at: 1)
        
        // Assert
        XCTAssertTrue(mockInteractor.deleteTaskCalled)
        XCTAssertEqual(mockInteractor.deleteTaskIndex, 1)
    }
    
    func testDidTapShareTaskDoesNothing() {
        // Act
        sut.didTapShareTask(at: 0)
        
        // Assert
        XCTAssertTrue(true)
    }
    
    func testDidChangeSearchQueryCallsInteractorWithQuery() {
        // Act
        sut.didChangeSearchQuery("test query")
        
        // Assert
        XCTAssertTrue(mockInteractor.loadTasksCalled)
        XCTAssertEqual(mockInteractor.loadTasksQuery, "test query")
    }
    
    // MARK: - TaskListInteractorOutput Tests
    
    func testDidReceiveUpdateCallsViewApplyUpdate() {
        // Arrange
        let update = TaskStoreUpdate(changes: [.insert(IndexPath(row: 0, section: 0))])
        
        // Act
        sut.didReceiveUpdate(update)
        
        // Assert
        XCTAssertTrue(mockView.applyUpdateCalled)
        XCTAssertEqual(mockView.applyUpdateParameter?.changes.count, 1)
    }
    
    func testDidFailCallsViewShowError() {
        // Arrange
        let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        
        // Act
        sut.didFail(error)
        
        // Assert
        XCTAssertTrue(mockView.showErrorCalled)
        XCTAssertEqual(mockView.showErrorMessage, "Test error")
    }
}
