//
//  TaskDataProvider.swift
//  ToDoApp
//
//  Created by Danil Otmakhov on 26.05.2025.
//

import CoreData

struct TaskStoreUpdate {
    enum ChangeType {
        case insert(IndexPath)
        case delete(IndexPath)
        case move(from: IndexPath, to: IndexPath)
        case update(IndexPath)
    }

    let changes: [ChangeType]
}

protocol TaskListDataProviderProtocol {
    var delegate: TaskListDataProviderDelegate? { get set }
    var numberOfRows: Int { get }
    func task(at indexPath: IndexPath) -> Task?
    func fetchTasks(with query: String)
    func save(_ tasks: [Task], completion: @escaping (Result<Void, Error>) -> Void)
    func toggleCompletion(for task: Task, completion: @escaping (Result<Void, Error>) -> Void)
    func delete(_ task: Task, completion: @escaping (Result<Void, Error>) -> Void)
}

protocol TaskEditorDataProviderProtocol {
    func add(_ task: Task, completion: @escaping (Result<Void, Error>) -> Void)
    func edit(_ task: Task, with newTask: Task, completion: @escaping (Result<Void, Error>) -> Void)
}

protocol TaskListDataProviderDelegate: AnyObject {
    func didUpdate(_ update: TaskStoreUpdate)
    func didFail(with error: Error)
}

final class TaskDataProvider: NSObject {
    
    // MARK: - Internal Properties
    
    weak var delegate: TaskListDataProviderDelegate?
    
    // MARK: - Private Properties
    
    private let store: TaskStoreProtocol
    private let context: NSManagedObjectContext
    private let operationQueue: DispatchQueue
    private var changes: [TaskStoreUpdate.ChangeType] = []
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TaskEntity> = {

        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    // MARK: - Initialization
    
    init(
        store: TaskStoreProtocol,
        context: NSManagedObjectContext = CoreDataStack.shared.viewContext,
        operationQueue: DispatchQueue = DispatchQueue(label: "com.ToDoApp.TaskStore.queue", qos: .userInitiated)
    ) {
        self.store = store
        self.context = context
        self.operationQueue = operationQueue
    }
    
}

// MARK: - TaskListDataProviderProtocol

extension TaskDataProvider: TaskListDataProviderProtocol {
    
    var numberOfRows: Int {
        fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func task(at indexPath: IndexPath) -> Task? {
        let entity = fetchedResultsController.object(at: indexPath)
        return Task(from: entity)
    }
    
    func fetchTasks(with query: String = "") {
        operationQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.context.performAndWait {
                do {
                    if query.isEmpty {
                        self.fetchedResultsController.fetchRequest.predicate = nil
                    } else {
                        self.fetchedResultsController.fetchRequest.predicate = NSPredicate(
                            format: "title CONTAINS[cd] %@ OR descriptionText CONTAINS[cd] %@",
                            query, query
                        )
                    }
                    
                    try self.fetchedResultsController.performFetch()
                    DispatchQueue.main.async {
                        self.delegate?.didUpdate(TaskStoreUpdate(changes: []))
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.delegate?.didFail(with: error)
                    }
                }
            }
        }
    }
    
    func save(_ tasks: [Task], completion: @escaping (Result<Void, Error>) -> Void) {
        store.save(tasks) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    self?.delegate?.didFail(with: error)
                    completion(.failure(error))
                }
            }
        }
    }
    
    func toggleCompletion(for task: Task, completion: @escaping (Result<Void, Error>) -> Void) {
        store.toggleCompletion(for: task) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    self?.delegate?.didFail(with: error)
                    completion(.failure(error))
                }
            }
        }
    }
    
    func delete(_ task: Task, completion: @escaping (Result<Void, Error>) -> Void) {
        store.delete(task) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    self?.delegate?.didFail(with: error)
                    completion(.failure(error))
                }
            }
        }
    }
    
}

// MARK: - TaskEditorDataProviderProtocol

extension TaskDataProvider: TaskEditorDataProviderProtocol {
    
    func add(_ task: Task, completion: @escaping (Result<Void, Error>) -> Void) {
        store.add(task) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    self?.delegate?.didFail(with: error)
                    completion(.failure(error))
                }
            }
        }
    }
    
    func edit(_ task: Task, with newTask: Task, completion: @escaping (Result<Void, Error>) -> Void) {
        store.edit(task, with: newTask) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    self?.delegate?.didFail(with: error)
                    completion(.failure(error))
                }
            }
        }
    }
    
}

// MARK: - NSFetchedResultsControllerDelegate

extension TaskDataProvider: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        changes.removeAll()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                changes.append(.insert(newIndexPath))
            }
        case .delete:
            if let indexPath = indexPath {
                changes.append(.delete(indexPath))
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                changes.append(.move(from: indexPath, to: newIndexPath))
            }
        case .update:
            if let indexPath = indexPath {
                changes.append(.update(indexPath))
            }
        @unknown default:
            break
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let update = TaskStoreUpdate(changes: changes)
        DispatchQueue.main.async {
            self.delegate?.didUpdate(update)
        }
    }
}
